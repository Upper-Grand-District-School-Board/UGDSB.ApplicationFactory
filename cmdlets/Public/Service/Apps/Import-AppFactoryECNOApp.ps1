function Import-AppFactoryECNOApp {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$applicationName,
    [Parameter()][String[]]$publishTo = @(),
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  # First download the application from sharepoint so that we can inspect it
  $application = [PSCustomObject]@{
    "Information" = [PSCustomObject]@{
      "DisplayName" = $applicationName
    }
    "SourceFiles" = [PSCustomObject]@{
      "StorageAccountContainerName" = $applicationName
    }
  }
  $details = Get-AppFactoryECNOAppItem -application $application -LogLevel $LogLevel
  $AppSetupFolderPath = Join-Path -Path $script:AppFactoryWorkspace -ChildPath "Installers" -AdditionalChildPath $applicationName
  # Create path if it doesn't exist
  if (-not(Test-Path -Path $AppSetupFolderPath -PathType "Container")) {
    try {
      New-Item -Path $AppSetupFolderPath -ItemType "Container" -ErrorAction "Stop" | Out-Null
    }
    catch [System.Exception] {
      throw "[$($application.Information.DisplayName)] Failed to create '$($Path)' with error message: $($_.Exception.Message)"
    }
  }  
  $Application.SourceFiles | Add-Member -MemberType NoteProperty -Name "PackageVersion" -Value $details.Version -Force
  $Application.SourceFiles | Add-Member -MemberType NoteProperty -Name "PackageSource" -Value $details.URI -Force  
  Get-AppFactoryECNOFile -application $application -Destination $AppSetupFolderPath -LogLevel $LogLevel
  # Read the config file to get details
  $configFile = Join-Path -Path $AppSetupFolderPath -ChildPath "_win32app.txt"
  $file = Get-Content -Path $configFile
  $publisherName = $file[45].trim()
  $informationURL = $file[53].trim()
  $privacyURL = $file[55].trim()
  $Description = $file[43].trim()
  $Notes = $file[61].trim()
  # Create application cinfig
  $NewApplication = @{
    displayName                    = $applicationName
    publisher                      = $publisherName
    description                    = $Description
    notes                          = $Notes
    owner                          = "ECNO"
    AppSource                      = "ECNO"
    StorageAccountContainerName    = $applicationName
    informationURL                 = $informationURL
    PrivacyURL                     = $privacyURL
    publishTo                      = $publishTo
  }
  $NewApplication = New-AppFactoryApp @NewApplication
  $Detection = @{
    appGUID                        = $NewApplication.GUID
    Type                           = "Script"
  }
  Set-AppFactoryAppDetectionRule @Detection
  $Install = @{
    appGUID                        = $NewApplication.GUID
    Type                           = "ECNO"
  }
  Set-AppFactoryAppInstall @Install
  Set-AppFactoryAppUninstall @Install  
  $iconFolder = Join-Path -Path $AppSetupFolderPath -ChildPath "osi"
  $icon = Get-ChildItem -Path $iconFolder -Filter "*.png" -Recurse
  $scriptFile = Join-Path -Path $AppSetupFolderPath -ChildPath "_detect.ps1"
  $appDestination = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath $applicationName
  Remove-Item -Path "$($appDestination)\detection.ps1" -Force
  Remove-Item -Path "$($appDestination)\Icon.png" -Force
  Copy-Item -Path $icon.FullName -Destination $appDestination -Force
  Copy-Item -Path $scriptFile -Destination $appDestination -Force  
  Rename-Item -Path "$($appDestination)\$($icon.Name)" -NewName "Icon.png" -Force
  Rename-Item -Path "$($appDestination)\_detect.ps1" -NewName "detection.ps1" -Force  
  Remove-Item -Path $AppSetupFolderPath -Recurse -Force -Confirm:$false
}