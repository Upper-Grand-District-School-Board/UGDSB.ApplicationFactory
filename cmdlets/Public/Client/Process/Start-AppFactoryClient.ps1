function Start-AppFactoryClient {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$ClientServicePath,
    [Parameter()][ValidateNotNullOrEmpty()][string]$configuration = "Configuration.json",
    [Parameter()][string]$LocalModule = $null,
    [Parameter()][switch]$EnableLogging,
    [Parameter()][int]$retries = 5,
    [Parameter()][switch]$testmode,
    [Parameter()][string]$appGUID,
    [Parameter()][switch]$Force,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  # Start the Application Factory Process
  $init = @{
    ClientServicePath = $ClientServicePath
    EnableLogging     = $EnableLogging.IsPresent
    configuration     = $configuration
    retries           = $retries
    LocalModule       = $LocalModule
  }
  try {
    $CurrentProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'    
    Initialize-AppFactoryClientProcess @init
    Write-PSFMessage -Message "Getting list of applications configurations from service." -Level  $LogLevel -Tag "Process" -Target "Application Factory Client"
    # Clean Up Old Configuration Files that may remain
    Get-ChildItem -Path (Join-Path -Path $script:AppFactoryClientSourceDir -ChildPath "Apps") -filter "*.json" | Remove-Item -Force
    Get-AppFactoryClientAppList -LogLevel $LogLevel
    # Clean old credential that is set to global by third party module
    $PublishedApplications = [System.Collections.Generic.List[PSCustomObject]]@()
    for ($x = 0; $x -lt $retries; $x++) {
      try {
        $params = @{
          "AddToIntune" = $true
          "LogLevel"    = $LogLevel
        }
        # Keep track of packaged applications
        if($PSBoundParameters.ContainsKey("appGUID")){
          $params.Add("GUID", $appGUID)
        }
        $applicationList = Get-AppFactoryClientApp @params
        Write-PSFMessage -Message "There are <c='green'>$($applicationList.count)</c> application set to be configured in intune" -Level  $LogLevel -Tag "Process" -Target "Application Factory Client"
        if ($applicationList.count -eq 0) {
          Write-PSFMessage -Message "No applications found to process" -Level  $LogLevel -Tag "Process" -Target "Application Factory Client"
          return $PublishedApplications
        }
        $intuneApplications = Get-AppFactoryClientGraphApp -LogLevel $LogLevel
        $params = @{
          applicationList = $applicationList
          intuneapplications = $intuneApplications
          LogLevel = $LogLevel
        }
        if($force.IsPresent){
          $params.Add("force", $true)
        }
        $publish = Compare-AppFactoryClientAppVersions @params
        Write-PSFMessage -Message "There are <c='green'>$($publish.count)</c> application set to be configured in intune" -Level  $LogLevel -Tag "Process" -Target "Application Factory Client" 
        if ($publish.count -eq 0) {
          return $PublishedApplications
        }
        # Make a note of how many applications we are expecting to update
        $originalCount = $publish.count
        # Get application SAS tokens
        Get-AppFactoryClientSAS  
        foreach ($application in $publish) {
          try {
            Get-AppFactoryClientAppFiles -applications $application -LogLevel $LogLevel
            Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Downloaded files." -Level $LogLevel -Tag "Applications", "$($application.IntuneAppName)" -Target "Application Factory Client"
            if (-not $testmode.IsPresent) {
              $PublishedApp = $null
              $PublishedApp = Publish-AppFactoryClientApp -application $application -LogLevel $LogLevel
              Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Pausing to ensure replication." -Level $LogLevel -Tag "Applications", "$($application.IntuneAppName)" -Target "Application Factory Client"
              Start-Sleep -Seconds 30
              if ($PublishedApp.UploadState -eq 0) {
                throw "Failed to upload files."
              }
              Add-AppFactoryClientAppAssignments -application $application -intuneid $PublishedApp.id -LogLevel $LogLevel
              if ($intuneApplications) {
                Copy-AppFactoryClientAppAssignments -application $application -intuneid $PublishedApp.id -intuneApplications $intuneApplications -LogLevel $LogLevel
                Remove-AppFactoryClientApp -application $application -intuneApplications $intuneApplications -LogLevel $LogLevel
              }
              Add-AppFactoryClientESPAssignment -application $application -intuneid $PublishedApp.id -LogLevel $LogLevel
              Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Completed." -Level $LogLevel -Tag "Applications", "$($application.IntuneAppName)" -Target "Application Factory Client"
            }
            $PublishedApplications.Add($application) | Out-Null
          }
          catch {
            if (-not $testmode.IsPresent) {
              if ($PublishedApp) {
                Remove-GraphIntuneApp -applicationid $PublishedApp.id
              }
              else {
                $intune = Get-GraphIntuneApp -type "microsoft.graph.win32LobApp" -displayName "$($script:AppFactoryClientPrefix)$($application.IntuneAppName) $($application.AppVersion)"
                if ($intune.uploadState -eq 0) {
                  Remove-GraphIntuneApp -applicationid $intune.id
                }
              }
              Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Unable to complete process for application, please review the logs to what has failed. Error: $($_)" -Level Error -Tag "Applications", "$($application.IntuneAppName)" -Target "Application Factory Client"
              continue
            }
          }
          finally {
            if (-not $testmode.IsPresent) {
              Remove-AppFactoryClientAppFiles -applications $application -LogLevel $LogLevel
            }
          }
        } 
        if ($originalCount -ne $PublishedApplications.Count) {
          throw
        }
        return $PublishedApplications
      }
      catch {
        Write-PSFMessage -Message "==========================================================================================" -Level  "Error" -Tag "Process", "IntuneError" -Target "Application Factory Client"
        Write-PSFMessage -Message "An Error Occured and not all applications where published. We will try again in 5." -Level  "Error" -Tag "Process", "IntuneError" -Target "Application Factory Client"
        Write-PSFMessage -Message "==========================================================================================" -Level  "Error" -Tag "Process", "IntuneError" -Target "Application Factory Client"
        Remove-Variable -Name AccessToken -Scope Global -ErrorAction SilentlyContinue
        Remove-Variable -Name AccessTokenTenantID -Scope Global -ErrorAction SilentlyContinue
        Remove-Variable -Name graphAccessToken -Scope Script -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 300
      }
    }
  }
  catch {}
  finally {
    $ProgressPreference = $CurrentProgressPreference
  }  
}