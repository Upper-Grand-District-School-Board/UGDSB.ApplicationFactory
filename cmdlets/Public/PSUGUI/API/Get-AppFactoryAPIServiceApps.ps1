function Get-AppFactoryAPIServiceApps {
  [CmdletBinding()]
  param(
  )
  Initialize-AppFactoryProcess -ApplicationServicePath $AppFactory_ApplicationPath
  $ClientList = Get-AppFactoryServiceClient
  $TableData = Get-AppFactoryApp | Select-Object -Property @{Label = "ID"; expression = { $_.GUID } }, @{Label = "Name"; expression = { $_.Information.DisplayName } }, @{Label = "Availability"; expression = { 
      if ($_.SourceFiles.publishTo.count -eq 0) {
        "All"
      }
      else {
        $orgList = [System.Collections.Generic.List[String]]::new()
        foreach ($obj in $_.SourceFiles.publishTo) {
          $orgList.Add(($ClientList | Where-Object { $_.GUID -eq $obj }).Name) | Out-Null
        }
        $orgList -join ", "
      }
    }
  }, @{Label = "AppVersions"; expression = {
    Get-PSUGUIAppFactoryAppVersions -appGUID $_.GUID
  }},
  @{Label = "Active"; expression = { $_.SourceFiles.Active } }, @{Label = "Source"; expression = { $_.SourceFiles.AppSource } }, @{Label = "Updated"; expression = { (Get-Date -Date $_.SourceFiles.LastUpdate).ToString("yyyy/MM/dd HH:mm:ss") } }, Information, SourceFiles, Install, Uninstall, RequirementRule, Program, DetectionRule  
  New-PSUApiResponse -StatusCode 200 -Body ($tableData | ConvertTo-JSON -Depth 10)
}