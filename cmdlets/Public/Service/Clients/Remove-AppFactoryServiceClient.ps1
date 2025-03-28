function Remove-AppFactoryServiceClient{
  [CmdletBinding()]
  param(  
    [Alias("GUID")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$clientGUID,
    [Parameter()][ValidateSet("Output","Verbose")][string]$LogLevel = "Verbose"  
  )
  # Get Client Configuration Files
  $client = Get-AppFactoryServiceClient -GUID $clientGUID -LogLevel $LogLevel
  if ($null -eq $client) {
    Write-PSFMessage -Message "Error Encountered: Client not found." -Level "Error" -Tag "Client","$($clientGUID)" -Target "Application Factory Service"
    throw "CLient not found." 
  }
  try{
    $clientStorageContainerContext = Connect-AppFactoryAzureStorage -storageContainer $script:AppFactoryDeploymentsContainer -storageSecret $script:AppFactoryDeploymentsSecret
    # Remove Azure Storage Container
    Remove-AzStorageContainer -Name $clientGUID -Context $clientStorageContainerContext -Force -ErrorAction Stop 
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "[$($client.Name)] Removed Azure Container" -Level $LogLevel -Tag "Clients","ContactList","$($client.Name)","$($clientGUID)" -Target "Application Factory Service"
    }    
    # Remove Configuration File. 
    $fileName = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Clients" -AdditionalChildPath $client.fileName
    Remove-Item -Path $fileName -Force
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "[$($client.Name)] Removed configuration file" -Level $LogLevel -Tag "Clients","ContactList","$($client.Name)","$($clientGUID)" -Target "Application Factory Service"
    }    
  }
  catch{
    Write-PSFMessage -Message "Error Encountered: $($_)" -Level "Error" -Tag "Clients","ContactList","$($client.Name)","$($clientGUID)" -Target "Application Factory Service"
    throw $_
  }  
}