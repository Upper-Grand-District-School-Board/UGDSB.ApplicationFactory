function Publish-AppFactoryClientApp {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  if ($script:AppFactoryClientLogging) {
    Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Publishing Application" -Level $LogLevel -Tag "Applications", "Intune", "$($application.IntuneAppName)" -Target "Application Factory Client"
  }
  # Get configuration details for application
  $ApplicationFolder = Join-Path -Path $script:AppFactoryClientWorkspace -ChildPath "Downloads" -AdditionalChildPath $application.IntuneAppName
  $ApplicationConfig = Get-Content -Path (Join-Path -Path $ApplicationFolder -ChildPath "App.json") | ConvertFrom-JSON -Depth 5
  # Configure Requirement Rule
  $RequirementRule = New-AppFactoryClientRequirementRule -application $ApplicationConfig -LogLevel $LogLevel
  # Configure Detection Rule
  $DetectionRules = New-AppFactoryClientDetectionRule -application $ApplicationConfig -applicationFolder $ApplicationFolder  -LogLevel $LogLevel
  # Create the base 64 image file
  $Icon = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes("$(Join-Path -Path $ApplicationFolder -ChildPath $ApplicationConfig.PackageInformation.IconFile)"))
  $IntuneAppPackage = Get-ChildItem "$($ApplicationFolder)\*.intunewin"
  $Win32AppArgs = @{
    "FilePath"          = $IntuneAppPackage.FullName
    "DisplayName"       = "$($script:AppFactoryClientPrefix)$($application.IntuneAppName) $($application.AppVersion)"
    "AppVersion"        = $ApplicationConfig.Information.AppVersion
    "Publisher"         = $ApplicationConfig.Information.Publisher
    "InstallExperience" = $ApplicationConfig.Program.InstallExperience
    "RestartBehavior"   = $ApplicationConfig.Program.DeviceRestartBehavior
    "DetectionRule"     = $DetectionRules
    "RequirementRule"   = $RequirementRule
    "Notes"             = "$($ApplicationConfig.Information.Notes)`n`rSTSID:$($application.GUID)"
  }
  # Dynamically add additional parameters for Win32 app
  if (-not([string]::IsNullOrEmpty($ApplicationConfig.Information.Description))) {
    $Win32AppArgs.Add("Description", $ApplicationConfig.Information.Description)
  }    
  else{
    $Win32AppArgs.Add("Description", $Win32AppArgs.DisplayName)
  }
  if ($null -ne $RequirementRules) {
    $Win32AppArgs.Add("AdditionalRequirementRule", $RequirementRules)
  }
  if (Test-Path -Path (Join-Path -Path $ApplicationFolder -ChildPath $ApplicationConfig.PackageInformation.IconFile)) {
    $Win32AppArgs.Add("Icon", $Icon)
  }
  if (-not([string]::IsNullOrEmpty($ApplicationConfig.Information.InformationURL))) {
    $Win32AppArgs.Add("InformationURL", $ApplicationConfig.Information.InformationURL)
  }  
  if (-not([string]::IsNullOrEmpty($ApplicationConfig.Information.PrivacyURL))) {
    $Win32AppArgs.Add("PrivacyURL", $ApplicationConfig.Information.PrivacyURL)
  }   
  if (-not([string]::IsNullOrEmpty($ApplicationConfig.Information.Owner))) {
    $Win32AppArgs.Add("Owner", $ApplicationConfig.Information.Owner)
  }
  if (-not([string]::IsNullOrEmpty($ApplicationConfig.Program.InstallCommand))) {
    if($application.InteractiveInstall){
      $Win32AppArgs.Add("InstallCommandLine", $ApplicationConfig.Program.InstallCommandInteractive)
    }
    else{
      $Win32AppArgs.Add("InstallCommandLine", $ApplicationConfig.Program.InstallCommand)
    }
  }
  if (-not([string]::IsNullOrEmpty($ApplicationConfig.Program.UninstallCommand))) {
    if($application.InteractiveUninstall){
      $Win32AppArgs.Add("UninstallCommandLine", $ApplicationConfig.Program.UninstallCommandInteractive)
    }
    else{
      $Win32AppArgs.Add("UninstallCommandLine", $ApplicationConfig.Program.UninstallCommand)
    }
  }
  if (-not([string]::IsNullOrEmpty($ApplicationConfig.Program.AllowAvailableUninstall))) {
    if ($ApplicationConfig.Program.AllowAvailableUninstall -eq $true) {
      $Win32AppArgs.Add("AllowAvailableUninstall", $true)
    }
  }  
  try{
    Remove-Variable -Scope Global -Name AccessToken -ErrorAction SilentlyContinue -Force
    Connect-MSIntuneGraph -TenantID $script:AppFactoryClientTenantID -ClientID $script:AppFactoryClientClientID -ClientSecret $script:AppFactoryClientAppRegSecret | Out-Null
    $Application = Add-IntuneWin32App @Win32AppArgs -UseAzCopy -ErrorAction Stop -WarningAction Stop
    return $Application
  }
  catch{
    $intuneApp = Get-GraphIntuneApp -displayName $application.IntuneAppName
    if ($intuneApp.count -gt 1) {
      $intuneApp = $intuneApp | Sort-Object -Property createdDateTime -Descending |  Select-Object -First 1
    }
    Remove-GraphIntuneApp -applicationid $intuneApp.id
    throw $_    
  }
}