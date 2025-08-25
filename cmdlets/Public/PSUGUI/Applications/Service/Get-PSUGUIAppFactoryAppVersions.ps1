function Get-PSUGUIAppFactoryAppVersions{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[Version]])]
  param(  
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$appGUID,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  )  
  $AppList = (($script:PublishedAppList  | Select-Object -Property Values).Values).Name | Sort-Object -Unique | Where-Object { $_ -like "$($appGUID)/*/App.json" } 
  if (-not [String]::IsNullOrWhiteSpace($AppList)) {
    $stringVersion = ([regex]::Matches($AppList , "/(.*?)/App.json")).Groups.Value | Where-Object { $_ -notlike "*App.json" }
  }
  return $stringVersion
}