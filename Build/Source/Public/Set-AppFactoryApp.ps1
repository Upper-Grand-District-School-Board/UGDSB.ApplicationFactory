function Set-AppFactoryApp {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String]$appGUID,
    [Parameter()][ValidateNotNullOrEmpty()][String]$displayName,
    [Parameter()][string]$AppVersion,
    [Parameter()][ValidateNotNullOrEmpty()][String]$AppFolderName,
    [Parameter()][ValidateNotNullOrEmpty()][String]$description,
    [Parameter()][ValidateNotNullOrEmpty()][String]$publisher,
    [Parameter()][String]$notes = "",
    [Parameter()][String]$owner = "",
    [Parameter()][String]$informationURL = "",
    [Parameter()][String]$privacyURL = "",
    [Parameter()][ValidateSet("StorageAccount", "Sharepoint", "Winget", "Evergreen", "PSADT", "ECNO", "LocalStorage")][String]$AppSource,
    [Parameter()][ValidateNotNullOrEmpty()][string]$appID,
    [Alias("appSetupName")][Parameter()][ValidateNotNullOrEmpty()][string]$AppSetupFileName = "",
    [Alias("storageContainerName")][Parameter()][ValidateNotNullOrEmpty()][string]$StorageAccountContainerName = "",
    [Parameter()][String[]]$ExtraFiles = @(),
    [Parameter()][PSCustomObject]$filterOptions = @{},
    [Parameter()][String[]]$publishTo = @(),
    [Parameter()][String[]]$AvailableVersions = @(),
    [Parameter()][ValidateSet("system", "user")][string]$InstallExperience = "system",
    [Parameter()][ValidateSet("suppress", "force", "basedOnReturnCode", "allow")][string]$DeviceRestartBehavior = "suppress",
    [Parameter()][ValidateSet("true", "false")][string]$AllowAvailableUninstall = $true,
    [Parameter()][ValidateSet("W10_1607", "W10_1703", "W10_1709", "W10_1809", "W10_1909", "W10_2004", "W10_20H2", "W10_21H1", "W10_21H2", "W10_22H2", "W11_21H2", "W11_22H2")][string]$MinimumSupportedWindowsRelease = "W10_1607",
    [Parameter()][ValidateSet("All", "x64", "x86")][string]$Architecture = "All",
    [Parameter()][String[]]$DependsOn = @(),  
    [Parameter()][bool]$active,
    [Parameter()][switch]$force,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  # Get the application Config
  $configfile = Get-AppFactoryApp -appGUID $appGUID -LogLevel $LogLevel
  if (-not ($configfile)) {
    throw "Application with GUID $($GUID) does not exist."
  }  
  # Take note of the original name in case we are changing it
  $originalFolderName = $configfile.Information.AppFolderName
  # Update the config file with the new values
  
  if ($PSBoundParameters.ContainsKey("AppFolderName")) {
    $configfile.Information.AppFolderName = $AppFolderName
    $originalPath = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath $originalFolderName
    Rename-Item -Path $originalPath -NewName $AppFolderName
  }
  if ($PSBoundParameters.ContainsKey("displayName")) { $configfile.Information.DisplayName = $displayName }
  if ($PSBoundParameters.ContainsKey("AppVersion")) { $configfile.Information.AppVersion = $AppVersion }
  if ($PSBoundParameters.ContainsKey("description")) { $configfile.Information.Description = $Description }  
  if ($PSBoundParameters.ContainsKey("publisher")) { $configfile.Information.Publisher = $Publisher }  
  if ($PSBoundParameters.ContainsKey("notes")) { $configfile.Information.Notes = $Notes }  
  if ($PSBoundParameters.ContainsKey("owner")) { $configfile.Information.owner = $owner } 
  if ($PSBoundParameters.ContainsKey("informationURL")) { $configfile.Information.informationURL = $informationURL }  
  if ($PSBoundParameters.ContainsKey("privacyURL")) { $configfile.Information.PrivacyURL = $PrivacyURL } 
  if ($PSBoundParameters.ContainsKey("AppSource")) { $configfile.SourceFiles.AppSource = $AppSource }  
  if ($PSBoundParameters.ContainsKey("appID")) { $configfile.SourceFiles.AppID = $AppID }
  if ($PSBoundParameters.ContainsKey("AppSetupFileName")) { $configfile.SourceFiles.AppSetupFileName = $AppSetupFileName }    
  if ($PSBoundParameters.ContainsKey("StorageAccountContainerName")) { $configfile.SourceFiles.StorageAccountContainerName = $StorageAccountContainerName }
  if ($PSBoundParameters.ContainsKey("ExtraFiles")) { $configfile.SourceFiles.ExtraFiles = $ExtraFiles }
  if ($PSBoundParameters.ContainsKey("filterOptions")) { $configfile.SourceFiles.FilterOptions = $FilterOptions }  
  if ($PSBoundParameters.ContainsKey("publishTo")) { $configfile.SourceFiles.publishTo = $publishTo }  
  if ($PSBoundParameters.ContainsKey("AvailableVersions")) {$configfile.SourceFiles.AvailableVersions = $AvailableVersions }
  if ($PSBoundParameters.ContainsKey("InstallExperience")) { $configfile.Program.InstallExperience = $InstallExperience }   
  if ($PSBoundParameters.ContainsKey("DeviceRestartBehavior")) { $configfile.Program.DeviceRestartBehavior = $DeviceRestartBehavior }
  if ($PSBoundParameters.ContainsKey("AllowAvailableUninstall")) { $configfile.Program.AllowAvailableUninstall = $AllowAvailableUninstall } 
  if ($PSBoundParameters.ContainsKey("MinimumSupportedWindowsRelease")) { $configfile.RequirementRule.MinimumSupportedWindowsRelease = $MinimumSupportedWindowsRelease }    
  if ($PSBoundParameters.ContainsKey("Architecture")) { $configfile.RequirementRule.Architecture = $Architecture } 
  if ($PSBoundParameters.ContainsKey("active")) { $configfile.SourceFiles.Active = $Active } 
  if ($PSBoundParameters.ContainsKey("DependsOn")) {
    if ($null -ne $DepandsOn -and $DepandsOn -ne "") {
      foreach ($app in $DependsOn) {
        $exists = Get-AppFactoryApp -appGUID $app
        if ($null -eq $exists) {
          Write-PSFMessage -Message "Error Encountered: Dependent Application with GUID $($app) does not exist" -Level "Error" -Tag "Application", "$($originalDisplayName)", "$($appGUID)" -Target "Application Factory Service"
          throw "Dependent Application with GUID $($app) does not exist"
        }
      }
    }
    else {
      $configfile.SourceFiles.DependsOn = @()
    }
  }
  # Create the configuration for the application
  try{
    Write-AppConfiguration -configfile $configfile -LogLevel $LogLevel
  }
  catch{
    Write-PSFMessage -Message "Error Encountered: $($_)" -Level "Error" -Tag "Application", "$($displayName)", "$($configFIle.GUID)" -Target "Application Factory Service"
    throw $_     
  }  
  return $configfile       
}