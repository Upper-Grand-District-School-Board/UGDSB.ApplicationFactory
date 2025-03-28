function Get-AppFactoryAppUninstall{
  [CmdletBinding()]
  [OutputType([Hashtable])]
  param(  
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$appGUID,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  )
  # Get the application Config
  $configfile = Get-AppFactoryApp -appGUID $appGUID -LogLevel $LogLevel
  if (-not ($configfile)) {
    throw "Application with GUID $($GUID) does not exist."
  } 
  return $configfile.uninstall    
}