function Get-AppFactoryECNOAppItem{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose" 
  )
  if($script:AppFactoryLogging){
    Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Looking for Sharepoint application."  -Level $LogLevel -Tag "Application","$($application.Information.DisplayName)","PSADT" -Target "Application Factory Service" 
  }
  # The PFX used to connect to the Sharepoint Configured
  $pfxPath = Join-Path -Path $script:AppFactoryLocalSupportFiles -ChildPath $script:AppFactorySharepointCertificate
  # Configuration for the PnP PowerShell Module
  $sharepointConfig = @{
    "url"                 = "$($script:AppFactorysharepointurl)/sites/$($script:AppFactorysharepointsite)"
    "CertificatePath"     = $pfxPath
    "CertificatePassword" = $script:AppFactorySharepointCertificateSecret.Password
    "ClientId"            = $script:AppFactorySharepointClientID
    "Tenant"              = $script:AppFactorySharepointTenant
  }
  try { Connect-PnPOnline @sharepointConfig }
  catch {
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "Failed to connect to Sharepoint. Error: $($_)" -Level "Error" -Tag "Process","Sharepoint" -Target "Application Factory Service"
    }
    throw $_
  }
  $listItems = Get-PnPListItem -List $script:AppFactorySharepointDocumentLibrary -PageSize 1000 | Where-Object {$_["FileDirRef"] -like "*$($application.SourceFiles.StorageAccountContainerName)"}
  $listItems = $listItems | Select-Object -Property @(@{name="FileLeafRef"; expr={$_["FileLeafRef"]}},@{name="FileRef"; expr={$_["FileRef"]}},@{name="FileDirRef"; expr={$_["FileDirRef"]}},@{name="Modified"; expr={$_["Modified"]}}) | Sort-Object -Property Modified -Descending
  $PSObject = [PSCustomObject]@{
    "Version" = ($listItems[0].FileLeafRef -replace ".7z","").Trim()
    "URI" = $listItems[0].FileRef
  }
  return $PSObject    
}