```ps
$Application = @{
  displayName                    = "Git For Windows"
  publisher                      = "Git"
  description                    = "Git is a free and open source distributed version control system designed to handle everything from small to very large projects with speed and efficiency."
  notes                          = ""
  owner                          = "ECNO"
  AppSource                      = "LocalStorage"
  StorageAccountContainerName    = "Git"
  appSetupName                   = "GitForWindows.exe"
  informationURL                 = "https://git-scm.com/"
}
$application = New-AppFactoryApp @Application
$Detection = @{
  appGUID                        = $application.GUID
  Type                           = "Registry"
  DetectionMethod                = "VersionComparison"
  KeyPath                        = "Git_is1"
  Operator                       = "greaterThanOrEqual"
}
Set-AppFactoryAppDetectionRule @Detection
$Install = @{
  appGUID                        = $application.GUID
  Type                           = "EXE"
  argumentList                  = "/SILENT"
}
Set-AppFactoryAppInstall @Install
$Uninstall = @{
  appGUID                        = $application.GUID
  Type                           = "EXE"
  installer                      = "C:\Program Files\Git\unins000.exe"
  argumentList                   = "/SILENT"
  
}
Set-AppFactoryAppUninstall @Uninstall
```