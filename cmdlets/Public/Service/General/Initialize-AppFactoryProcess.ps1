<#
  .DESCRIPTION
  This cmdlet is designed to set all the required variables and settings for the process
  .PARAMETER Path
  Where the application configuration files are stored
  .PARAMETER configuration
  The name of the configuration file if not the default
  .PARAMETER LocalModule
  If we should load the module from a local source vs installed module
  .PARAMETER EnableLogging
  If logging should be enabled with PSFramework
  .PARAMETER LogLevel
  If logging is enabled, what level of logging do we want, default is verbose.
  .EXAMPLE

  Start Application Factory with the default configuration file and no logging
    Initialize-AppFactoryProcess -Path "### PATH TO PROCESS FILES ###"

  Start Application Factory with a different configuration file and logging enabled
    Initialize-AppFactoryProcess -Path "### PATH TO PROCESS FILES ###" -configuration "### CONFIGURATION JSON FILE NAME ###" -EnableLogging

  Start Application Factory with a local module loaded for testing
    Initialize-AppFactoryProcess -Path "### PATH TO PROCESS FILES ###" -LocalModule "### PATH TO LOCAL MODULE ###"
#>
function Initialize-AppFactoryProcess{
  [CmdletBinding()]
  [Alias("Start-AppFactory")]
  param(
    [Alias("Path")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$ApplicationServicePath,
    [Parameter()][ValidateNotNullOrEmpty()][string]$configuration = "Configuration.json",
    [Parameter()][string]$LocalModule = $null,
    [Parameter()][switch]$EnableLogging,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  # Set if we should be logging with the PSFramework Module
  $script:AppFactoryLogging = $EnableLogging.IsPresent
  if($null -ne $LocalModule){
    $script:LocalModulePath = $LocalModule
  }
  # Determine what the Source Directory we aer using is
  $script:AppFactorySourceDir = $ApplicationServicePath  
  # Where are the supporting files stored
  $script:AppFactorySupportFiles = Join-Path -Path $PSScriptRoot -ChildPath "SupportFiles"
  $script:AppFactorySupportTemplateFolder = Join-Path -Path $PSScriptRoot -ChildPath "Templates"
  $script:AppFactoryLocalSupportFiles = Join-Path -Path $script:AppFactorySourceDir -ChildPath "SupportFiles"
  $script:AppFactoryWorkspace = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Workspace"
  # Setup Logging Configuration
  if ($script:AppFactoryLogging) {
    $AppFactoryLogDir = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Logs"
    # Name for the log file to be used
    $logFile = "$($AppFactoryLogDir)\AppFactoryService-%Date%.csv"   
    $paramSetPSFLoggingProvider = @{
      Name         = "logfile"
      InstanceName = "AppFactoryService"
      FilePath     = $logFile
      Enabled      = $true
      Wait         = $true
    }
    Set-PSFLoggingProvider @paramSetPSFLoggingProvider 
    Write-PSFMessage -Message "Logging Configured" -Level $LogLevel -Tag "Setup" -Target "Application Factory Service"
    Write-PSFMessage -Message "Log File: <c='green'>$($logFile)</c>" -Level $LogLevel -Tag "Setup" -Target "Application Factory Service"
    Write-PSFMessage -Message "Reading Configuration File" -Level $LogLevel -Tag "Setup" -Target "Application Factory Service"     
  }  
  # Where is the configuration folder
  $script:AppFactoryConfigDir = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Configurations"
  $script:AppFactoryClientConfigDir = Join-Path -Path $script:AppFactorySourceDir -ChildPath "ClientConfigurations"
  # What is the path to the configuration file
  $AFConfigFile = Join-Path $script:AppFactoryconfigDir -ChildPath $configuration
  # Read the configuration file into an object
  $configDetails = Get-Content -Path $AFConfigFile -ErrorAction Stop | ConvertFrom-JSON
  $script:AppFactoryInstallersContainer = $configDetails.storage.installers.name
  $script:AppFactoryInstallersSecret = Get-Secret -Vault $configDetails.keyVault -Name $configDetails.storage.installers.secret
  $script:AppFactoryDeploymentsContainer = $configDetails.storage.deployments.name
  $script:AppFactoryDeploymentsSecret = Get-Secret -Vault $configDetails.keyVault -Name $configDetails.storage.deployments.secret
  $script:AppFactoryPublicFolder = $configDetails.publicContainer
  $script:AppFactorySharepointTenant = $configDetails.sharepoint.tenant
  $script:AppFactorySharepointClientID = $configDetails.sharepoint.clientId
  $script:AppFactorysharepointsite = $configDetails.sharepoint.sharepointsite
  $script:AppFactorysharepointurl = $configDetails.sharepoint.sharepointurl
  $script:AppFactorySharepointCertificate = $configDetails.sharepoint.certificateFile
  $script:AppFactorySharepointCertificateSecret = Get-Secret -Vault $configDetails.keyVault -Name $configDetails.sharepoint.certificateSecret
  $script:AppFactorySharepointVersionField = $configDetails.sharepoint.versionField
  $script:AppFactorySharepointDocumentLibrary = $configDetails.sharepoint.documentLibrary  
  if ($script:AppFactoryLogging) {
    Write-PSFMessage -Message "Loaded variables for the Application Factory Service" -Level $LogLevel -Tag "Setup" -Target "Application Factory Service"
  }    
  # Initialize the Azure Storage and Available apps
  # Azure Storage Contexts. The first is for exe installers, the 2nd is for payload free installers
  $script:appStorageContext = Connect-AppFactoryAzureStorage -storageContainer $script:AppFactoryInstallersContainer -storageSecret $script:AppFactoryInstallersSecret -LogLevel $LogLevel
  $script:psadtStorageContext = Connect-AppFactoryAzureStorage -storageContainer $script:AppFactoryDeploymentsContainer -storageSecret $script:AppFactoryDeploymentsSecret -LogLevel $LogLevel
  # Get a Hashtable of All the Current Blobs that are present so we can check to see if the version is not packaged in at least one of the containers
  $script:PublishedAppList = @{
    "public" = Get-AzStorageBlob -Container public -Context $psadtStorageContext
  }
  $Clients = Get-AppFactoryServiceClient -LogLevel $LogLevel
  foreach($Client in $Clients){
    $script:PublishedAppList.Add($Client.GUID, (Get-AzStorageBlob -Container $Client.GUID -Context $psadtStorageContext))
  }  
}