function Get-AppFactoryClientGraphApp{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter()][ValidateSet("Output","Verbose")][string]$LogLevel = "Verbose"
  )
  Get-GraphAccessToken -clientID $script:AppFactoryClientClientID -tenantID $script:AppFactoryClientTenantID  -clientSecret $script:AppFactoryClientAppRegSecret | Out-Null
  $intuneApplications = Get-GraphIntuneApp -type "microsoft.graph.win32LobApp"
  return $intuneApplications
}