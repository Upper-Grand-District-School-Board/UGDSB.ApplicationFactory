function Add-AppFactoryAppWIM{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[String[]]])]
  param(
    [Parameter(Mandatory = $true)][ValidateSet("start","end")][string]$section,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$MountPath,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  ) 
  $ApplicationScriptLines = [System.Collections.Generic.List[String[]]]@() 
  # If this to mount the WIM add the following lines
  if($section -eq "start"){
    $ApplicationScriptLines.Add("`t`$mountPath = `"$($MountPath)`"")  | Out-Null
    $ApplicationScriptLines.Add("`t`$wimFile = Get-Childitem -Path `"`$(`$adtSession.dirFiles)`" -Filter `"*.wim`"")  | Out-Null
    $ApplicationScriptLines.Add("`t`$wimPath = Join-Path `$adtSession.dirFiles -ChildPath `$wimFile")  | Out-Null
    $ApplicationScriptLines.Add("`tMount-ADTWimFile -ImagePath `$wimPath -Path `$mountPath -Index 1")  | Out-Null 
  }
  else{
    $ApplicationScriptLines.Add("`tDismount-ADTWimFile -Path `"$($MountPath)`"")  | Out-Null 
  }
  return @(,$ApplicationScriptLines)
}