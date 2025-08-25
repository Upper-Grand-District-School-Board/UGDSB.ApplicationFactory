function Update-AppConfig(){
  [CmdletBinding()]
  param()
  $AppConfigTemplate = Join-Path $script:AppFactorySupportTemplateFolder -ChildPath "Application" -AdditionalChildPath "ApplicationConfig.json"
  $ApplicationConfig = Get-Content -Path $AppConfigTemplate -Raw | ConvertFrom-Json
  # Get the path to where the application configs are stored
  $applicationFolders = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps"
  # Get a list of all the configuration files for the applications
  $ApplicationConfigFiles = Get-Childitem -Path $applicationFolders -Recurse -Filter "ApplicationConfig.json"  
  foreach($config in $ApplicationConfigFiles){
    $appConfig = Get-Content -Path $config.FullName -Raw | ConvertFrom-Json
    $appConfig.program.InstallCommandInteractive = $ApplicationConfig.program.InstallCommandInteractive
    $appConfig.program.UninstallCommandInteractive = $ApplicationConfig.program.UninstallCommandInteractive
    $appConfig | ConvertTo-JSON | Out-File $config.FullName
    #break
  }
}