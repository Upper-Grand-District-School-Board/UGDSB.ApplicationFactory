
function New-AppFactoryApp {
  [CmdletBinding(DefaultParameterSetName = 'PSADTECNO')]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String]$displayName,
    [Parameter()][ValidateNotNullOrEmpty()][String]$AppFolderName,
    [Parameter()][String]$description,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String]$publisher,
    [Parameter()][String]$notes = "",
    [Parameter()][String]$owner = "",
    [Parameter()][String]$informationURL = "",
    [Parameter()][String]$privacyURL = "",
    [Parameter(Mandatory = $true)][ValidateSet("StorageAccount", "Sharepoint", "Winget", "Evergreen", "PSADT", "ECNO", "LocalStorage")][String]$AppSource,
    [Parameter(Mandatory = $true, ParameterSetName = 'WingetEvergreen')]
    [ValidateNotNullOrEmpty()][string]$appID,
    [Parameter(Mandatory = $true, ParameterSetName = 'AzureLocalStorage')]
    [Parameter(Mandatory = $true, ParameterSetName = 'Sharepoint')]
    [Parameter(Mandatory = $true, ParameterSetName = 'WingetEvergreen')]
    [Alias("appSetupName")][ValidateNotNullOrEmpty()][string]$AppSetupFileName = "",
    [Parameter(Mandatory = $true, ParameterSetName = 'ECNO')]
    [Parameter(Mandatory = $true, ParameterSetName = 'AzureLocalStorage')]
    [Alias("storageContainerName")][ValidateNotNullOrEmpty()][string]$StorageAccountContainerName = "",
    [Parameter()][String[]]$ExtraFiles = @(),
    [Parameter()][PSCustomObject]$filterOptions = @{},
    [Parameter()][String[]]$publishTo = @(),
    [Parameter()][String]$AppVersion = "<replaced_by_build>",
    [Parameter()][String[]]$AvailableVersions = @(),
    [Parameter()][ValidateSet("system", "user")][string]$InstallExperience = "system",
    [Parameter()][ValidateSet("suppress", "force", "basedOnReturnCode", "allow")][string]$DeviceRestartBehavior = "suppress",
    [Parameter()][ValidateSet("true", "false")][string]$AllowAvailableUninstall = $true,
    [Parameter()][ValidateSet("W10_1607", "W10_1703", "W10_1709", "W10_1809", "W10_1909", "W10_2004", "W10_20H2", "W10_21H1", "W10_21H2", "W10_22H2", "W11_21H2", "W11_22H2")][string]$MinimumSupportedWindowsRelease = "W10_1607",
    [Parameter()][ValidateSet("All", "x64", "x86")][string]$Architecture = "All",
    [Parameter()][String[]]$DependsOn = @(),    
    [Parameter()][bool]$active = $true,
    [Parameter()][switch]$force,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  if (-not $PSBoundParameters.ContainsKey("AppFolderName")) {
    $AppFolderName = $displayName
  }  
  try {
    # Create the package folders for the application we are creating
    New-AppFactoryAppFolder -displayName $displayName -folderName $AppFolderName -LogLevel $LogLevel -Force $force | Out-Null
  }
  catch {
    throw $_
  }
  # Read Template Config File
  $configFilePath = Join-Path -Path $script:AppFactorySupportTemplateFolder -ChildPath "Application" -AdditionalChildPath "ApplicationConfig.json"
  $configFIle = Get-Content -Path $configFilePath | ConvertFrom-Json
  # Get a new GUID for the application
  $appGUID = (New-GUID).Guid
  # Set Configuration File values
  $configFIle.GUID = $appGUID
  $configfile.Information.DisplayName = $displayName
  $configfile.Information.AppFolderName = $AppFolderName
  $configfile.Information.AppVersion = $AppVersion
  $configfile.Information.Description = $Description
  $configfile.Information.Publisher = $Publisher
  $configfile.Information.Notes = $Notes
  $configfile.Information.owner = $owner
  $configfile.Information.informationURL = $informationURL
  $configfile.Information.PrivacyURL = $PrivacyURL
  $configfile.SourceFiles.AppSource = $AppSource
  $configfile.SourceFiles.AppID = $AppID
  $configfile.SourceFiles.AppSetupFileName = $AppSetupFileName
  $configfile.SourceFiles.StorageAccountContainerName = $StorageAccountContainerName
  $configfile.SourceFiles.ExtraFiles = $ExtraFiles
  $configfile.SourceFiles.FilterOptions = $FilterOptions
  $configfile.SourceFiles.publishTo = $publishTo
  $configfile.SourceFiles.active = $active
  $configfile.Program.InstallExperience = $InstallExperience
  $configfile.Program.DeviceRestartBehavior = $DeviceRestartBehavior
  $configfile.Program.AllowAvailableUninstall = $AllowAvailableUninstall
  $configfile.RequirementRule.MinimumSupportedWindowsRelease = $MinimumSupportedWindowsRelease
  $configfile.RequirementRule.Architecture = $Architecture

  # If depends on was passed, check to make sure that the application exists
  if ($PSBoundParameters.ContainsKey("DependsOn")) {
    foreach ($app in $DependsOn) {
      $exists = Get-AppFactoryApp -appGUID $app
      if ($null -eq $exists) {
        Write-PSFMessage -Message "Error Encountered: Dependent Application with GUID $($app) does not exist" -Level "Error" -Tag "Application", "$($displayName)", "$($appGUID)" -Target "Application Factory Service"
        throw "Dependent Application with GUID $($app) does not exist"
      }
    }
    $configfile.SourceFiles.DependsOn = $DependsOn
  }
  # Create the configuration for the application
  try {
    Write-AppConfiguration -configfile $configfile -LogLevel $LogLevel
  }
  catch {
    Write-PSFMessage -Message "Error Encountered: $($_)" -Level "Error" -Tag "Application", "$($displayName)", "$($configFIle.GUID)" -Target "Application Factory Service"
    throw $_     
  }
  return $configfile
}

