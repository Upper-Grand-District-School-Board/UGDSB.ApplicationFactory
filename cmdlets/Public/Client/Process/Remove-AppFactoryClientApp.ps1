function Remove-AppFactoryClientApp {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(  
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][System.Collections.Generic.List[PSCustomObject]]$intuneApplications,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  )
  # Loop through the applications and remove ones that are no longer required
  if ($script:AppFactoryClientLogging) {
    Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Removing Previous Applications" -Level $LogLevel -Tag "Applications", "Intune", "$($application.IntuneAppName)" -Target "Application Factory Client"
  }
  $applications = $intuneApplications | Where-Object { $_.Notes -match "STSID:$($application.GUID)" }  | Select-Object id, displayname, @{Label = "Version"; expression = { [version]$_.displayversion } } |  Sort-Object -Property "Version"
  $keepApplications = 0
  if($application.KeepPrevious){
    $keepApplications = $application.KeepPrevious
  }
  if ($applications.count -gt $($keepApplications)) {
    $removalCount = $applications.count - $keepApplications
    if ($script:AppFactoryClientLogging) {
      Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Based on keeping $($keepApplications) previous versions there are $($removalCount) applications to remove." -Level $LogLevel -Tag "Applications", "Intune", "$($application.IntuneAppName)" -Target "Application Factory Client"
    }
    for ($i = 0; $i -lt $removalCount; $i++) {
      Remove-GraphIntuneApp -applicationid $applications[$i].id
    }
  }
  else {
    if ($script:AppFactoryClientLogging) {
      Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Based on keeping $($keepApplications) previous versions there are no applications to remove." -Level $LogLevel -Tag "Applications", "Intune", "$($application.IntuneAppName)" -Target "Application Factory Client"
    }
  }
}