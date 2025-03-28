```ps
$Application = @{
  displayName                    = "FortiClient (UGDSB)"
  publisher                      = "Fortinet"
  description                    = "FortiClient comes in several levels of capabilities, with increasing levels of protection. It integrates with many key components of the Fortinet Security Fabric and is centrally managed by the Endpoint Management Server (EMS)"
  notes                          = ""
  owner                          = "ECNO"
  AppSource                      = "Sharepoint"
  StorageAccountContainerName    = "FortiClient"
  appSetupName                   = "FortiClient.zip"
  informationURL                 = "https://www.fortinet.com/"
  PrivacyURL                     = "https://www.fortinet.com/corporate/about-us/privacy"
  publishTo                      = @("a6734147-a0d0-41d4-a5b3-91062a4d83bc","ac595b44-01bc-4490-971c-723093d653fb")
}
$application = New-AppFactoryApp @Application
$Detection = @{
  appGUID                        = $application.GUID
  Type                           = "Script"
}
Set-AppFactoryAppDetectionRule @Detection
$Install = @{
  appGUID                        = $application.GUID
  Type                           = "MSI"
  installer                      = "Forticlient.msi"  
  transforms                     = "Forticlient.mst"
}
Set-AppFactoryAppInstall @Install
$Uninstall = @{
  appGUID                        = $application.GUID
  Type                           = "Name"
  name                           = "FortiClient"
}
Set-AppFactoryAppUninstall @Uninstall
```