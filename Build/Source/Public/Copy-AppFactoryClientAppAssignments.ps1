function Copy-AppFactoryClientAppAssignments {
  [CmdletBinding()]
  param(  
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$intuneid,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][System.Collections.Generic.List[PSCustomObject]]$intuneApplications,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  )  
  if ($application.CopyPrevious) {
    if ($script:AppFactoryClientLogging) {
      Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Copying Application Assignments" -Level $LogLevel -Tag "Applications", "Intune", "$($application.IntuneAppName)" -Target "Application Factory Client"
    }
    $applications = $intuneApplications | Where-Object { $_.Notes -match "STSID:$($application.GUID)" }  | Select-Object id, displayname, @{Label = "Version"; expression = { [version]$_.displayversion } } |  Sort-Object -Property "Version" -Descending
    if ($applications.count -gt 0) {
      Copy-GraphIntuneAppAssignments -applicationid $intuneid -copyapplicationid $applications[0].id
    }
  }    
}