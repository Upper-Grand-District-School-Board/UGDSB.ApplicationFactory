function Add-AppFactoryClientESPAssignment {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(  
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$intuneid,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  )
  # Loop through applications
  if ($application.espprofiles) {
    foreach ($esp in $application.espprofiles) {
      if ($script:AppFactoryClientLogging) {
        Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Assigning application to ESP Porfile $($esp)" -Level $LogLevel -Tag "Applications", "Intune", "$($application.IntuneAppName)" -Target "Application Factory Client"
      }
      Add-GraphIntuneAppAddToESP -displayName $esp -applicationid $intuneid
    }
  }
}