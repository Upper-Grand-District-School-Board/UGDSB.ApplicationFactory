function Get-AppFactoryAPIClientApps {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][Guid]$Id
  )
  if ($Identity -ne $InternalAPICalls -and $Identity -ne $Id) {
    New-PSUApiResponse -StatusCode 403 -Body ("Forbidden" | ConvertTo-JSON)
    return
  }
  try {  
    Initialize-AppFactoryProcess -ApplicationServicePath $AppFactory_ApplicationPath
    $applist = Get-AppFactoryApp -Active | Where-Object { [String]::IsNullOrWhiteSpace($_.SourceFiles.publishTo) -or (-not [String]::IsNullOrWhiteSpace($_.SourceFiles.publishTo) -and $_.SourceFiles.publishTo -contains $Id) }
    $tableData = [System.Collections.Generic.List[PSCustomObject]]@()
    foreach ($item in $applist) {
      $AppDetails = Get-AppFactoryServiceClientAppConfig -orgGUID $Id -appGUID $item.GUID
      $AppVersions = Get-PSUGUIAppFactoryAppVersions -appGUID $item.GUID
      if ([String]::IsNullOrWhiteSpace($AppDetails.AddToIntune)) { $AddToIntune = "False" }
      else { $AddToIntune = "True" }
      $obj = [PSCustomObject]@{
        id               = $item.GUID
        Name             = $item.Information.DisplayName
        Description      = $item.Information.Description
        Enabled          = $AddToIntune
        Updated          = $item.SourceFiles.LastUpdate
        ClientDetails    = ($AppDetails | ConvertTo-Json -Depth 5)
        InformationURL   = $item.information.InformationURL
        PrivacyURL       = $item.Information.PrivacyURL
        AppVersions      = $AppVersions
        RequirementRules = $item.RequirementRule
        InstallType      = $item.Program.InstallExperience
        Publisher        = $item.Information.Publisher
      }
      $tableData.Add($obj) | Out-Null
    }  
    New-PSUApiResponse -StatusCode 200 -Body ($tableData | ConvertTo-JSON)
  }
  catch {
    New-PSUApiResponse -StatusCode 500 -Body ("Internal Server Error: " + $_.Exception.Message | ConvertTo-JSON)
  }
}