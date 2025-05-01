function Compare-AppFactoryClientAppVersions {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(  
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][System.Collections.Generic.List[PSCustomObject]]$applicationList,
    [Parameter(Mandatory = $true)][System.Collections.Generic.List[PSCustomObject]]$intuneApplications,
    [Parameter()][switch]$force,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  )
  # Create blank list to store the applications that we will be moving forward with.
  $applications = [System.Collections.Generic.List[PSCustomObject]]@()
  # Loop through the applications 
  foreach ($application in $applicationList) {
    if ($script:AppFactoryClientLogging) {
      Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Comparing Version (<c='green'>$($application.AppVersion)</c>) between expected and published" -Level $LogLevel -Tag "Applications", "$($application.IntuneAppName)" -Target "Application Factory Client"
    }
    $intuneApplication = $intuneApplications | Where-Object { $_.Notes -match "STSID:$($application.GUID)" }
    if($null -eq $intuneApplication.displayVersion -or $application.AppVersion -notin $intuneApplication.displayVersion){
      if ($script:AppFactoryClientLogging) {
        Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Current Published Versions: <c='green'>$($intuneApplication.displayVersion -join ",")</c>" -Level $LogLevel -Tag "Applications", "$($application.IntuneAppName)" -Target "Application Factory Client"
        Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Current Expected Version: <c='green'>$($application.AppVersion)</c>" -Level $LogLevel -Tag "Applications", "$($application.IntuneAppName)" -Target "Application Factory Client"
      }
      $applications.Add($application) | Out-Null
    }
    else{
      Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Application version <c='green'>$($intuneApplication.displayVersion -join ",")</c> already published" -Level $LogLevel -Tag "Applications", "$($application.IntuneAppName)" -Target "Application Factory Client"
    }
  }
  return $applications 
}