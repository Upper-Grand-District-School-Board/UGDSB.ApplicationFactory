function Set-AppFactoryAppInstall {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$appGUID,
    [Parameter(Mandatory = $true)][ValidateSet("None","Script", "PowerShell", "ECNO", "EXE", "MSI")][string]$Type,
    [Parameter()][string]$argumentList, 
    [Parameter()][string]$additionalArgumentList, 
    [Parameter()][bool]$secureArgumentList, 
    [Parameter()][int[]]$successExitCodes,
    [Parameter()][int[]]$rebootExitCodes,
    [Parameter()][int[]]$ignoreExitCodes,
    [Parameter()][String[]]$conflictingProcessStart,
    [Parameter()][String[]]$conflictingProcessEnd,
    [Parameter()][ValidateNotNullOrEmpty()][string]$installer,
    [Parameter()][ValidateNotNullOrEmpty()][string]$transforms,  
    [Parameter()][bool]$SkipMSIAlreadyInstalledCheck,
    [Parameter()][string[]]$script,
    [Parameter()][bool]$wim,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )  
  # Get the application Config
  $configfile = Get-AppFactoryApp -appGUID $appGUID -LogLevel $LogLevel
  if (-not ($configfile)) {
    throw "Application with GUID $($GUID) does not exist."
  } 
  if ($PSBoundParameters.ContainsKey("type")) { $configfile.install.type = $type } 
  if ($PSBoundParameters.ContainsKey("argumentList")) { $configfile.install.argumentList = $argumentList } 
  if ($PSBoundParameters.ContainsKey("additionalArgumentList")) { $configfile.install.additionalArgumentList = $additionalArgumentList } 
  if ($PSBoundParameters.ContainsKey("secureArgumentList")) { $configfile.install.secureArgumentList = $secureArgumentList } 
  if ($PSBoundParameters.ContainsKey("successExitCodes")) { $configfile.install.successExitCodes = $successExitCodes } 
  if ($PSBoundParameters.ContainsKey("rebootExitCodes")) { $configfile.install.rebootExitCodes = $rebootExitCodes } 
  if ($PSBoundParameters.ContainsKey("ignoreExitCodes")) { $configfile.install.ignoreExitCodes = $ignoreExitCodes } 
  if ($PSBoundParameters.ContainsKey("conflictingProcessStart")) { $configfile.install.conflictingProcessStart = $conflictingProcessStart } 
  if ($PSBoundParameters.ContainsKey("conflictingProcessEnd")) { $configfile.install.conflictingProcessEnd = $conflictingProcessEnd } 
  if ($PSBoundParameters.ContainsKey("installer")) { $configfile.install.installer = $installer } 
  if ($PSBoundParameters.ContainsKey("transforms")) { $configfile.install.transforms = $transforms } 
  if ($PSBoundParameters.ContainsKey("SkipMSIAlreadyInstalledCheck")) { $configfile.install.SkipMSIAlreadyInstalledCheck = $SkipMSIAlreadyInstalledCheck } 
  if ($PSBoundParameters.ContainsKey("script")) { $configfile.install.script = $script -split "`n" } 
  if ($PSBoundParameters.ContainsKey("wim")) { $configfile.install.wim = $wim } 
  # Create the configuration for the application
  try{
    Write-AppConfiguration -configfile $configfile -LogLevel $LogLevel
  }
  catch{
    Write-PSFMessage -Message "Error Encountered: $($_)" -Level "Error" -Tag "Application", "$($configfile.Information.displayName)", "$($configFIle.GUID)" -Target "Application Factory Service"
    throw $_     
  }    
}