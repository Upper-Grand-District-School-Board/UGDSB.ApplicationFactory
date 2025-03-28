```ps
$Application = @{
  displayName                    = "7-Zip"
  publisher                      = "Igor Pavlov"
  description                    = "7-Zip is a application used to archive/unarchive 7z files."
  notes                          = "7-Zip is a application used to archive/unarchive 7z files."
  owner                          = "ECNO"
  AppSource                      = "Winget"
  appID                          = "7zip.7Zip"
  appSetupName                   = "setup_7zip.exe"
}
$application = New-AppFactoryApp @Application
$Detection = @{
  appGUID                        = $application.GUID
  Type                           = "Script"
}
Set-AppFactoryAppDetectionRule @Detection
$Install = @{
  appGUID                        = $application.GUID
  conflictingProcessStart        = "7zFM"
  Type                           = "EXE"
  argumentList                   = "/S"
}
Set-AppFactoryAppInstall @Install
$Uninstall = @{
  appGUID                        = $application.GUID
  Type                           = "Name"
  name                           = "7-Zip"
}
Set-AppFactoryAppUninstall @Uninstall
```