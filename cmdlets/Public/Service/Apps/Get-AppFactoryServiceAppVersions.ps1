function Get-AppFactoryServiceAppVersions{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[Version]])]
  param(  
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$appGUID,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject[]]$AllAppList,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  )  
  $AppList = (($AllAppList | Select-Object -Property Values).Values).Name | Sort-Object -Unique | Where-Object { $_ -like "$($appGUID)/*/App.json" } 
  if (-not [String]::IsNullOrWhiteSpace($AppList)) {
    [System.Collections.Generic.List[Version]]$AppVersions = ([regex]::Matches($AppList , "/(.*?)/App.json")).Groups.Value | Where-Object { $_ -notlike "*App.json" }
  }
  return $AppVersions 
}