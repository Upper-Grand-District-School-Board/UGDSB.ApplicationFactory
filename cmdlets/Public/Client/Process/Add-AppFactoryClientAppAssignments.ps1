function Add-AppFactoryClientAppAssignments {
  [CmdletBinding()]
  param(  
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$intuneid,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  )  
  if ($script:AppFactoryClientLogging) {
    Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Adding Application Assignments" -Level $LogLevel -Tag "Applications", "Intune", "$($application.IntuneAppName)" -Target "Application Factory Client"
  }
  $commonVariables = @{
    "applicationid" = $intuneid
    "filters"       = $application.filters
  }
  try {
    if ($application.AvailableAssignments -ne "") { Add-GraphIntuneAppAssignment @commonVariables -intent available -groups $application.AvailableAssignments -foreground $application.foreground }
    if ($application.AvailableExceptions -ne "") { Add-GraphIntuneAppAssignment @commonVariables -intent available -groups $application.AvailableExceptions -exclude }
    if ($application.RequiredAssignments -ne "") { Add-GraphIntuneAppAssignment @commonVariables -intent required -groups $application.RequiredAssignments -foreground $application.foreground }
    if ($application.RequiredExceptions -ne "") { Add-GraphIntuneAppAssignment @commonVariables -intent required -groups $application.RequiredExceptions -exclude }
    if ($application.UninstallAssignments -ne "") { Add-GraphIntuneAppAssignment @commonVariables -intent uninstall -groups $application.UninstallAssignments -foreground $application.foreground }
    if ($application.UninstallExceptions -ne "") { Add-GraphIntuneAppAssignment @commonVariables -intent uninstall -groups $application.UninstallExceptions -exclude }
  }
  catch {
    $_
  }
}