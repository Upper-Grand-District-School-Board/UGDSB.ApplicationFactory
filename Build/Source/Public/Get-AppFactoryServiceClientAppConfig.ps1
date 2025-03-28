function Get-AppFactoryServiceClientAppConfig{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$orgGUID,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$appGUID,
    [Parameter()][ValidateSet("Output","Verbose")][string]$LogLevel = "Verbose"
  )
  $appConfigPath = Join-Path -Path $script:AppFactoryClientConfigDir -ChildPath "$($orgGUID)\$($appGUID).json"  
  if(-not (Test-Path $appConfigPath)){
    return $false
  }
  return (Get-Content -Path $appConfigPath | ConvertFrom-JSON)
}