function Set-AppFactoryAppUninstall {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$appGUID,
    [Parameter(Mandatory = $true)][ValidateSet("None", "MSI", "EXE", "Name", "GUID", "ECNO", "Script")][string]$type,
    [Parameter()][string]$name,
    [Parameter()][ValidateSet('Contains','Exact','Wildcard','Regex')][string]$nameMatch,
    [Parameter()][string]$productCode,
    [Parameter()][string]$filterScript,
    [Parameter()][string]$argumentList, 
    [Parameter()][string]$additionalArgumentList, 
    [Parameter()][bool]$secureArgumentList, 
    [Parameter()][string[]]$script,
    [Parameter()][string]$installer,
    [Parameter()][bool]$wim,
    [Parameter()][bool]$dirFiles,
    [Parameter()][int[]]$ignoreExitCodes,
    [Parameter()][String[]]$conflictingProcessStart,
    [Parameter()][String[]]$conflictingProcessEnd,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose" 
  )
  # Get the application Config
  $configfile = Get-AppFactoryApp -appGUID $appGUID -LogLevel $LogLevel
  if (-not ($configfile)) {
    throw "Application with GUID $($GUID) does not exist."
  } 
  if ($PSBoundParameters.ContainsKey("type")) { $configfile.Uninstall.type = $type } 
  if ($PSBoundParameters.ContainsKey("name")) { $configfile.Uninstall.name = $name } 
  if ($PSBoundParameters.ContainsKey("nameMatch")) { $configfile.Uninstall.nameMatch = $nameMatch } 
  if ($PSBoundParameters.ContainsKey("productCode")) { $configfile.Uninstall.productCode = $productCode } 
  if ($PSBoundParameters.ContainsKey("filterScript")) { $configfile.Uninstall.filterScript = $filterScript } 
  if ($PSBoundParameters.ContainsKey("argumentList")) { $configfile.Uninstall.argumentList = $argumentList } 
  if ($PSBoundParameters.ContainsKey("additionalArgumentList")) { $configfile.Uninstall.additionalArgumentList = $additionalArgumentList } 
  if ($PSBoundParameters.ContainsKey("secureArgumentList")) { $configfile.Uninstall.secureArgumentList = $secureArgumentList } 
  if ($PSBoundParameters.ContainsKey("script")) { $configfile.Uninstall.script = $script -split "`n" } 
  if ($PSBoundParameters.ContainsKey("installer")) { $configfile.Uninstall.installer = $installer } 
  if ($PSBoundParameters.ContainsKey("wim")) { $configfile.Uninstall.wim = $wim } 
  if ($PSBoundParameters.ContainsKey("dirFiles")) { $configfile.Uninstall.dirFiles = $dirFiles } 
  if ($PSBoundParameters.ContainsKey("ignoreExitCodes")) { $configfile.Uninstall.ignoreExitCodes = $ignoreExitCodes } 
  if ($PSBoundParameters.ContainsKey("conflictingProcessStart")) { $configfile.Uninstall.conflictingProcessStart = $conflictingProcessStart } 
  if ($PSBoundParameters.ContainsKey("conflictingProcessEnd")) { $configfile.Uninstall.conflictingProcessEnd = $conflictingProcessEnd } 
  # Create the configuration for the application
  try{
    Write-AppConfiguration -configfile $configfile -LogLevel $LogLevel
  }
  catch{
    Write-PSFMessage -Message "Error Encountered: $($_)" -Level "Error" -Tag "Application", "$($configfile.Information.displayName)", "$($configFIle.GUID)" -Target "Application Factory Service"
    throw $_     
  }  
}
