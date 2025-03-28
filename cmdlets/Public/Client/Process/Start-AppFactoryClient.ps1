function Start-AppFactoryClient {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$ClientServicePath,
    [Parameter()][ValidateNotNullOrEmpty()][string]$configuration = "Configuration.json",
    [Parameter()][string]$LocalModule = $null,
    [Parameter()][switch]$EnableLogging,
    [Parameter()][int]$retries = 5,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  # Start the Application Factory Process
  $init = @{
    ClientServicePath = $ClientServicePath
    EnableLogging = $EnableLogging.IsPresent
    configuration = $configuration
    retries = $retries
    LocalModule = $LocalModule
  }
  Initialize-AppFactoryClientProcess @init
  Write-PSFMessage -Message "Getting list of applications configurations from service." -Level  $LogLevel -Tag "Process" -Target "Application Factory Client"
  Get-AppFactoryClientAppList -LogLevel $LogLevel
  # Clean old credential that is set to global by third party module
  $PublishedApplications = [System.Collections.Generic.List[PSCustomObject]]@()
  for($x = 0; $x -lt $retries; $x++){
    # Keep track of packaged applications
    $applicationList = Get-AppFactoryClientApp -AddToIntune $true -LogLevel $LogLevel
    Write-PSFMessage -Message "There are <c='green'>$($applicationList.count)</c> application set to be configured in intune" -Level  $LogLevel -Tag "Process" -Target "Application Factory Client"
    if($applicationList.count -eq 0){
      Write-PSFMessage -Message "No applications found to process" -Level  $LogLevel -Tag "Process" -Target "Application Factory Client"
      return
    }
    $intuneApplications = Get-AppFactoryClientGraphApp -LogLevel $LogLevel
    $publish = Compare-AppFactoryClientAppVersions -applicationList $applicationList -intuneapplications $intuneApplications -LogLevel $LogLevel
    Write-PSFMessage -Message "There are <c='green'>$($publish.count)</c> application set to be configured in intune" -Level  $LogLevel -Tag "Process" -Target "Application Factory Client"
    if($publish.count -eq 0){break}
    # Make a note of how many applications we are expecting to update
    $originalCount = $publish.count
    # Get application SAS tokens
    Get-AppFactoryClientSAS
    foreach($application in $publish){
      try{
        Get-AppFactoryClientAppFiles -applications $application -LogLevel $LogLevel
        Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Downloaded files." -Level $LogLevel -Tag "Applications","$($application.IntuneAppName)" -Target "Application Factory Client"
        $PublishedApp = Publish-AppFactoryClientApp -application $application -LogLevel $LogLevel
        Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Pausing to ensure replication." -Level $LogLevel -Tag "Applications","$($application.IntuneAppName)" -Target "Application Factory Client"
        Start-Sleep -Seconds 30
        if($PublishedApp.UploadState -eq 0){
          Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Failed to upload files. Removing." -Level Error -Tag "Applications","$($application.IntuneAppName)" -Target "Application Factory Client"
          Remove-GraphIntuneApp -applicationid $PublishedApp.id
          continue
        }
        Add-AppFactoryClientAppAssignments -application $application -intuneid $PublishedApp.id -LogLevel $LogLevel
        Copy-AppFactoryClientAppAssignments -application $application -intuneid $PublishedApp.id -intuneApplications $intuneApplications -LogLevel $LogLevel
        Remove-AppFactoryClientApp -application $application -intuneApplications $intuneApplications -LogLevel $LogLevel
        Add-AppFactoryClientESPAssignment -application $application -intuneid $PublishedApp.id -LogLevel $LogLevel
        Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Completed." -Level $LogLevel -Tag "Applications","$($application.IntuneAppName)" -Target "Application Factory Client"
        $PublishedApplications.Add($application) | Out-Null
        Remove-AppFactoryClientAppFiles -applications $application -LogLevel $LogLevel
      }
      catch{
        Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Unable to complete process for application, please review the logs to what has failed. Error: $($_)" -Level Error -Tag "Applications","$($application.IntuneAppName)" -Target "Application Factory Client"
        throw $_
      }
    }
    if ($PublishedApplications.count -eq $originalCount) {
      Write-PSFMessage -Message "All applicable applications has been completed." -Level $LogLevel -Tag "Applications" -Target "Application Factory Client"
      foreach($app in $PublishedApplications){
        Write-PSFMessage -Message "[<c='green'>$($app.IntuneAppName)</c>] Published version <c='green'>$($app.AppVersion)</c>." -Level $LogLevel -Tag "Applications","$($app.IntuneAppName)" -Target "Application Factory Client"
      }
      break
    }
    else{
      Write-Host "==========================================================================================" -ForegroundColor Red
      Write-Host "Some applications failed to import into intune. Waiting 2 minutes to run the process again" -ForegroundColor Red
      Write-Host "==========================================================================================" -ForegroundColor Red
      Start-Sleep -Seconds 120  
    }
  }
}