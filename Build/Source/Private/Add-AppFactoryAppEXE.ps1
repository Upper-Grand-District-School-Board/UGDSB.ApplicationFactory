function Add-AppFactoryAppEXE{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[String[]]])]
  param(
    [Parameter()][String]$directory,    
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String]$AppSetupFileName,
    [Parameter()][string]$argumentList,
    [Parameter()][bool]$secureArgumentList,
    [Parameter()][int[]]$SuccessExitCodes,
    [Parameter()][int[]]$rebootExitCodes,
    [Parameter()][int[]]$ignoreExitCodes,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  $ApplicationScriptLines = [System.Collections.Generic.List[String[]]]@()
  # Set the Path that we should be working with
  if($directory -ne ""){
    $executePath = "`"`$($($directory))\`$(`$AppSetupFileName)`""
  }
  else{
    $executePath = "`"`$(`$AppSetupFileName)`""
  }
  $execute = "Start-ADTProcess -FilePath $($executePath) -ArgumentList `"`$(`$argumentList)`""
  if ($PSBoundParameters.ContainsKey("secureArgumentList") -and $secureArgumentList) {$execute = "$($execute) -secureArgumentList"}  
  if ($PSBoundParameters.ContainsKey("SuccessExitCodes") -and $SuccessExitCodes) {$execute = "$($execute) -SuccessExitCodes $($SuccessExitCodes -join ",")"}  
  if ($PSBoundParameters.ContainsKey("rebootExitCodes") -and $rebootExitCodes) {$execute = "$($execute) -rebootExitCodes $($rebootExitCodes -join ",")"}  
  if ($PSBoundParameters.ContainsKey("ignoreExitCodes") -and $ignoreExitCodes) {$execute = "$($execute) -ignoreExitCodes $($ignoreExitCodes -join ",")"}  
  $ApplicationScriptLines.Add("`t`$AppSetupFileName = `"$($AppSetupFileName)`"") | Out-Null
  $ApplicationScriptLines.Add("`t`$argumentList = `"$($argumentList)`"") | Out-Null
  $ApplicationScriptLines.Add("`t$($execute)") | Out-Null
  return @(,$ApplicationScriptLines)  		  
}