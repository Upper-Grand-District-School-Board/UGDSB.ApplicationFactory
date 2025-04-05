<#
  .DESCRIPTION
  This cmdlet is designed to download contacts from Azure Storage Account
  .PARAMETER application
  The application object that we are working for so that we can ensure that get the correct and current data 
  .PARAMETER storageContext
  The azure storage context that has permissions to upload to the Azure Storage Account
  .PARAMETER workingFolder
  Path to the working folder for the process
  .PARAMETER LogLevel
  If logging is enabled, what level of logging do we want, default is verbose.
#>
function Get-AppFactoryPSADTAppItem {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose" 
  )
  if($script:AppFactoryLogging){
    Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Looking for PSADT application."  -Level $LogLevel -Tag "Application","$($application.Information.DisplayName)","PSADT" -Target "Application Factory Service" 
  }  
  if($null -eq $application.Information.AppVersion -or $application.Information.AppVersion -eq "<replaced_by_build>"){
    $version = "1.0"
  }
  else{
    $version = $application.Information.AppVersion
  }
  $AppItem = [PSCustomObject]@{
    "Version" = $version
    "URI" = $null
  }
  return $AppItem
}