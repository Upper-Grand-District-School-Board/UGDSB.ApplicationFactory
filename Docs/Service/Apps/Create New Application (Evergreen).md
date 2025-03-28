```ps
$Application = @{
  displayName                    = "Airtame App"
  publisher                      = "Airtame"
  description                    = "Airtame creates a simpler, smarter and more engaging shared screen experience, offering solutions for hybrid conferencing, screen sharing and digital signage."
  notes                          = ""
  owner                          = "ECNO"
  AppSource                      = "Evergreen"
  appID                          = "AirTameApp"
  appSetupName                   = "Airtame.msi"
  filterOptions                  = @{Type = "MSI"}
  informationURL                 = "https://airtame.com/"
  privacyURL                     = "https://airtame.com/legal/"
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
}
Set-AppFactoryAppInstall @Install
$Uninstall = @{
  appGUID                        = $application.GUID
  Type                           = "Name"
  name                           = "Airtame"
}
Set-AppFactoryAppUninstall @Uninstall
```