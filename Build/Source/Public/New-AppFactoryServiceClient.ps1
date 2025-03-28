<#
  .DESCRIPTION
  This cmdlet is designed to create a new organization
  .PARAMETER clientName
  The name of the organization
  .PARAMETER clientContacts
  The list of contacts for the organization
  .PARAMETER force
  Overwrite the current file with a new configuration.
  .PARAMETER LogLevel
  If logging is enabled, what level of logging do we want, default is verbose.

  .EXAMPLE

  Create a new organization
    New-AppFactoryClient -clientName "### Organization Name ###"

  Create a new organization with contacts
    New-AppFactoryClient -clientName "### Organization Name ###" -clientContacts "### Contact 1 ###", "### Contact 2 ###"
#>
function New-AppFactoryServiceClient {
  [CmdletBinding()]
  [Alias("New-AppFactoryOrganization")]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Alias('Name')][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$clientName,
    [Alias('contactList')][Parameter()][string[]]$clientContacts = @(),
    [Parameter()][switch]$force,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"      
  )
  # Generate a unique GUID for client
  $GUID = (New-GUID).Guid
  # Create the client file to write out
  $obj = [PSCustomObject]@{
    GUID     = $GUID
    Name     = $clientName
    Contacts = $clientContacts
  }  
  # Path for the new client file
  $clientFile = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Clients" -AdditionalChildPath "$($clientName).json"
  # Client File Path
  if ($script:AppFactoryLogging) {
    Write-PSFMessage -Message "Creating client with GUID: <c='green'>$($GUID)</c>" -Level $LogLevel -Tag "Clients", "$($clientName)" -Target "Application Factory Service"
    Write-PSFMessage -Message "Client file path: <c='green'>$($clientFile)</c>" -Level $LogLevel -Tag "Clients", "$($clientName)" -Target "Application Factory Service"
  }
  # First write out the client json
  try {
    if ((Test-Path -Path $clientFile) -and -not $force.IsPresent) {
      throw "Client already exists with this name."
    }
    $obj | ConvertTo-Json | Out-File -FilePath $clientFile -Force
    Write-PSFMessage -Message "Created client configuration file." -Level $LogLevel -Tag "Clients", "$($clientName)" -Target "Application Factory Service"
  }
  catch {
    Write-PSFMessage -Message "Error Encountered: $($_)" -Level "Error" -Tag "Clients", "$($clientName)" -Target "Application Factory Service"
    throw $_
  }
  # Create Azure Storage Container to store client specific applications
  try {
    $clientStorageContainerContext = Connect-AppFactoryAzureStorage -storageContainer $script:AppFactoryDeploymentsContainer -storageSecret $script:AppFactoryDeploymentsSecret
    New-AzStorageContainer -Name $GUID -Permission Off -Context $clientStorageContainerContext | Out-Null
    if ($script:AppFactoryLogging) {
      Write-PSFMessage -Message "Created clients storage container <c='green'>$($GUID)</c>" -Level $LogLevel -Tag "Clients", "$($clientName)" -Target "AppFactory"
    }
  }
  catch {
    Remove-Item -Path $clientFile -Force
    Write-PSFMessage -Message "Error Encountered: $($_)" -Level "Error" -Tag "Clients", "$($clientName)" -Target "Application Factory Service"
    throw $_
  }
  return $obj      
}