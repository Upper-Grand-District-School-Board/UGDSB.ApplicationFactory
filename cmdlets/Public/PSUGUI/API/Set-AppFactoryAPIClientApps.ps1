function Set-AppFactoryAPIClientApps {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][Guid]$Id,
    [Parameter(Mandatory = $true)][PSCustomObject]$appdata
  )
  if ($Identity -ne $InternalAPICalls -and $Identity -ne $Id) {
    New-PSUApiResponse -StatusCode 403 -Body ("Forbidden" | ConvertTo-JSON)
    return
  }  
  try {
    Initialize-AppFactoryProcess -ApplicationServicePath $AppFactory_ApplicationPath
    Set-AppFactoryServiceClientAppConfig @appdata
    New-PSUApiResponse -StatusCode 204
  }
  catch {
    New-PSUApiResponse -StatusCode 500 -Body ("Internal Server Error: " + $_.Exception.Message | ConvertTo-Json)
  }  
}