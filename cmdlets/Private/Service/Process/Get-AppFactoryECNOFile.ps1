function Get-AppFactoryECNOFile{
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
  $fullpath = "$($script:AppFactorysharepointurl)$($application.SourceFiles.PackageSource)"
  $filename = "$($application.SourceFiles.PackageVersion).7z"
  Get-PnPFile -Url $fullpath -AsFile -Path $destination -Filename $filename -Force
  $7ZipPath = Join-Path -Path $script:AppFactorySupportFiles -ChildPath "7zr.exe"
  $7ZipFile = Join-Path -Path $destination -ChildPath $filename
  $vars = @{
    "FilePath" = $7zipPath
    "ArgumentList" = "x `"$($7ZipFile)`" -aoa -o`"$($destination)`""
    "Wait" = $true
  }
  Start-Process @vars
  $detectionScript = Join-Path -Path $destination -ChildPath "_detect.ps1"
  $detectionScriptPath = Join-Path $script:AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath $application.Information.AppFolderName,"detection.ps1"
  Copy-Item -Path $detectionScript -Destination $detectionScriptPath -Force
  $appdetailsPath = Join-Path $destination -ChildPath "_win32app.txt"
  $file = Get-Content -Path $appdetailsPath
  $details = @{
    "MinimumMemoryInMB" = $file[89].trim()
    "MinimumFreeDiskSpaceInMB" = $file[87].trim()
    "MinimumSupportedWindowsRelease" = $file[85].trim()
  }
  foreach($item in $details.GetEnumerator()){
    $params = @{
      $item.key = $item.value
    }
    try{
      Set-AppFactoryApp -appguid $application.guid @params | Out-Null
    }
    catch{}
  }
  Remove-Item -Path $7ZipFile -Force
}