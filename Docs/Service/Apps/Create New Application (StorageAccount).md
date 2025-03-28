```ps
$Application = @{
  displayName                    = "Connectwise Control (UGDSB)"
  publisher                      = "Connectwise"
  description                    = "Let IT save the day by solving problems fast. Our secure and reliable solutions turn potential chaos into productivity. Get instant access to any device, fix issues in a flash, and keep your team stress-free, no matter where they are. "
  notes                          = ""
  owner                          = "ECNO"
  AppSource                      = "StorageAccount"
  StorageAccountContainerName    = "connectwisecontrol"
  appSetupName                   = "ConnectWiseControl.ClientSetup.msi"
  informationURL                 = "https://www.screenconnect.com/"
  PrivacyURL                     = "https://www.connectwise.com/company/privacy-policy"
  publishTo                      = @("a6734147-a0d0-41d4-a5b3-91062a4d83bc","ac595b44-01bc-4490-971c-723093d653fb")
}
$application = New-AppFactoryApp @Application
$Detection = @{
  appGUID                        = $application.GUID
  Type                           = "Registry"
  DetectionMethod                = "VersionComparison"
  Operator                       = "greaterThanOrEqual"
  Check32BitOn64System           = $true
}
Set-AppFactoryAppDetectionRule @Detection
$Install = @{
  appGUID                        = $application.GUID
  Type                           = "MSI"
}
Set-AppFactoryAppInstall @Install
$Uninstall = @{
  appGUID                        = $application.GUID
  Type                           = "Name"
  name                           = "ScreenConnect Client"
}
Set-AppFactoryAppUninstall @Uninstall
```