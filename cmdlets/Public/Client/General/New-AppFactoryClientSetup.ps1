function New-AppFactoryClientSetup {
  [CmdletBinding()]
  param(
    [Parameter()][ValidateNotNullOrEmpty()][string]$path = "C:\AppFactory",
    [Parameter()][switch]$createSecretVault,
    [Parameter()][string]$vaultName = "ApplicationFactory",
    [Parameter(Mandatory = $true)][string]$AppRegistrationClientID,
    [Parameter(Mandatory = $true)][string]$AppRegistrationTenantID,
    [Parameter()][string]$AppRegSecretName = "AppFactoryAppRegSecret",
    [Parameter(Mandatory = $true)][string]$AppRegSecretValue,
    [Parameter(Mandatory = $true)][string]$APIEndpoint,
    [Parameter()][string]$APISecretName = "AppFactoryAPISecret",
    [Parameter()][string]$prefix = "af | ",
    [Parameter(Mandatory = $true)][string]$APISecretValue
  )
  If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw "You need to run this function as administrator." } 
  # List of Required Moodules
  $modules = @("Microsoft.PowerShell.SecretManagement", "SecretManagement.JustinGrote.CredMan", "PSFramework", "UGDSB.PS.Graph","IntuneWin32App")
  # Install Required Modules
  foreach ($module in $modules) {
    Install-Module -Name $module -Scope AllUsers
  }
  # Create Secret Vault if configured to do so
  if ($PSBoundParameters.ContainsKey("createSecretVault")) {
    Register-SecretVault -Name $vaultName -ModuleName "SecretManagement.JustinGrote.CredMan"
  }
  # Create the secrets if values where passed
  if ($PSBoundParameters.ContainsKey("AppRegSecretValue")) {
    Set-Secret -Name $AppRegSecretName -Secret $AppRegSecretValue -Vault $vaultName
  }
  if ($PSBoundParameters.ContainsKey("APISecretValue")) {
    Set-Secret -Name $APISecretName -Secret $APISecretValue -Vault $vaultName
  }  
  # Create the base folder
  if (-not (Test-Path -path $path)) {
    New-Item -Path $path -ItemType Directory -Force
  }
  # Create the Client Folders
  $folders = @("Apps", "Configurations", "Logs", "Workspace")
  foreach ($folder in $folders) {
    $folderPath = Join-Path -Path $path -ChildPath $folder
    if (-not (Test-Path -path $folderPath)) {
      New-Item -Path $folderPath -ItemType Directory -Force
    }
  }
  # Create the Client Configurations
  $config = @{
    keyVault              = $vaultName
    clientID              = $AppRegistrationClientID
    tenantID              = $AppRegistrationTenantID
    appregistrationSecret = $AppRegSecretName
    apiendpoint           = $APIEndpoint
    apisecret             = $APISecretName
    prefix                = $prefix
  }
  $configPath = Join-Path -Path $path -ChildPath "Configurations" -AdditionalChildPath "Configuration.json"
  $config | ConvertTo-Json | Set-Content -Path $configPath
}