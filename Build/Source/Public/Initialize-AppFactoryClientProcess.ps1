function Initialize-AppFactoryClientProcess{
  [CmdletBinding()]
  param(
    [Alias("Path")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$ClientServicePath,
    [Parameter()][ValidateNotNullOrEmpty()][string]$configuration = "Configuration.json",
    [Parameter()][string]$LocalModule = $null,
    [Parameter()][switch]$EnableLogging,
    [Parameter()][int]$retries = 5,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  # Set if we should be logging with the PSFramework Module
  $script:AppFactoryClientLogging = $EnableLogging.IsPresent 
  # Where is the configuration file stored
  $script:AppFactoryClientSourceDir = $ClientServicePath
  $script:AppFactoryClientConfigDir = Join-Path -Path $script:AppFactoryClientSourceDir -ChildPath "Configurations"    
  # Workspace
  $script:AppFactoryClientWorkspace = Join-Path -Path $script:AppFactoryClientSourceDir -ChildPath "Workspace"
  if ($script:AppFactoryClientLogging) {
    $AppFactoryClientLogDir = Join-Path -Path $script:AppFactoryClientSourceDir -ChildPath "Logs"  
    # Name for the log file to be used
    $logFile = "$($AppFactoryClientLogDir)\AppFactoryClient-%Date%.csv"  
    $paramSetPSFLoggingProvider = @{
      Name         = "logfile"
      InstanceName = "AppFactoryClient"
      FilePath     = $logFile
      Enabled      = $true
      Wait         = $true
    }
    Set-PSFLoggingProvider @paramSetPSFLoggingProvider 
    Write-PSFMessage -Message "Logging Configured" -Level $LogLevel -Tag "Setup" -Target "Application Factory Client"
    Write-PSFMessage -Message "Log File: <c='green'>$($logFile)</c>" -Level $LogLevel -Tag "Setup" -Target "Application Factory Client"
    Write-PSFMessage -Message "Reading Configuration File" -Level $LogLevel -Tag "Setup" -Target "Application Factory Client"
  }  
  try {
    $configurationPath = Join-Path $script:AppFactoryClientConfigDir -ChildPath $configuration
    $configurationDetails = Get-Content -Path $configurationPath -ErrorAction Stop | ConvertFrom-JSON
    $script:AppFactoryClientClientRetries = $configurationDetails.retries
    $script:AppFactoryClientClientID = $configurationDetails.clientID
    $script:AppFactoryClientTenantID = $configurationDetails.tenantID
    $script:AppFactoryClientApiEndpoint = $configurationDetails.apiendpoint
    $script:AppFactoryClientAppRegSecret = Get-Secret -Vault $configurationDetails.keyVault -Name $configurationDetails.appregistrationSecret -AsPlainText
    $script:AppFactoryClientAPISecret = Get-Secret -Vault $configurationDetails.keyVault -Name $configurationDetails.apisecret
    $script:AppFactoryClientPrefix = $configurationDetails.prefix
  }
  catch {
    throw $_
  }   
}