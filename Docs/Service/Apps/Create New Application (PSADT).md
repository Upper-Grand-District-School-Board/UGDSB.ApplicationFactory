```ps
$Application = @{
  displayName                    = "Telnet Client"
  publisher                      = "Microsoft"
  description                    = "Install the built in windows Telnet Client"
  notes                          = ""
  owner                          = "ECNO"
  AppSource                      = "PSADT"
  informationURL                 = ""
  privacyURL                     = ""
  AppVersion                     = "1.0"
}
$application = New-AppFactoryApp @Application
$Detection = @{
  appGUID                        = $application.GUID
  Type                           = "Script"
}
Set-AppFactoryAppDetectionRule @Detection
$Install = @{
  appGUID                        = $application.GUID
  Type                           = "Script"
  Script                         = "Enable-WindowsOptionalFeature -FeatureName ""TelnetClient"" -All -Online -NoRestart"
}
Set-AppFactoryAppInstall @Install
$Uninstall = @{
  appGUID                        = $application.GUID
  Type                           = "Script"
  Script                         = "Disable-WindowsOptionalFeature -FeatureName ""TelnetClient"" -Online -NoRestart"
}
Set-AppFactoryAppUninstall @Uninstall
```