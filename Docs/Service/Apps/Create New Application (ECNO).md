```ps
$Application = @{
  displayName                    = "Acid Xpress"
  publisher                      = "Test"
  description                    = "Test"
  notes                          = ""
  owner                          = "ECNO"
  AppSource                      = "ECNO"
  StorageAccountContainerName    = "Acid Xpress"
  appSetupName                   = "Test.msi"
  informationURL                 = "https://www.fortinet.com/"
  PrivacyURL                     = "https://www.fortinet.com/corporate/about-us/privacy"
}
$application = New-AppFactoryApp @Application
$Detection = @{
  appGUID                        = $application.GUID
  Type                           = "Script"
}
Set-AppFactoryAppDetectionRule @Detection
$Install = @{
  appGUID                        = $application.GUID
  Type                           = "ECNO"
}
Set-AppFactoryAppInstall @Install
$Uninstall = @{
  appGUID                        = $application.GUID
  Type                           = "ECNO"
}
Set-AppFactoryAppUninstall @Uninstall
```