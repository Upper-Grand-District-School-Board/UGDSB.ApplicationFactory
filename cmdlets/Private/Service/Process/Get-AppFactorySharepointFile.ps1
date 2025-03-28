function Get-AppFactorySharepointFile{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$destination,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose" 
  )
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
  $listItems = Get-PnPListItem -List $script:AppFactorySharepointDocumentLibrary -PageSize 1000 | Where-Object {$_["FileDirRef"] -eq "$($application.SourceFiles.PackageSource)"}
  $listItems = $listItems | Select-Object -Property @(@{name="FileLeafRef"; expr={$_["FileLeafRef"]}},@{name="FileRef"; expr={$_["FileRef"]}})
  foreach($item in $listItems){
    $fullpath = "$($script:AppFactorysharepointurl)$($application.SourceFiles.PackageSource)/$($item.FileLeafRef)"
    Get-PnPFile -Url $fullpath -AsFile -Path $destination -Filename $item.FileLeafRef -Force
  }
}