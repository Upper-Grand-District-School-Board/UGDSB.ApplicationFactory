function Get-AppFactoryStorageSAS{
  [CmdletBinding()]
  [OutputType([Hashtable])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$GUID,
    [Parameter()][ValidateNotNullOrEmpty()][int]$hours = 2,
    [Parameter()][ValidateSet("Output","Verbose")][string]$LogLevel = "Verbose"
  )
  # Create expiry time
  $SASExpiry = (Get-Date).ToUniversalTime().AddHours($hours) 
  # Azure Storage Contexts. 
  $script:psadtStorageContext = Connect-AppFactoryAzureStorage -storageContainer $script:AppFactoryDeploymentsContainer -storageSecret $script:AppFactoryDeploymentsSecret -LogLevel $LogLevel   
  # Store the details for the connectivity and return it
  try{
    $SASTokens = @{
      "StoragePath" = "https://$($script:AppFactoryDeploymentsContainer).blob.core.windows.net"
      "PublicContainerName" = $script:AppFactoryPublicFolder
      "OrganizationContainerName" = $GUID
      "public" = New-AzStorageContainerSASToken -Context $script:psadtStorageContext -Name $script:AppFactoryPublicFolder -Permission r  -ExpiryTime $SASExpiry
      "organization" = New-AzStorageContainerSASToken -Context $script:psadtStorageContext -Name $GUID -Permission r -ExpiryTime $SASExpiry    
    }
    if ($script:AppFactoryLogging) {
      Write-PSFMessage -Message "Created SAS Tokens for client with GUID <c='green'>$($GUID)</c>" -Level $LogLevel -Tag "Azure","Storage","SAS" -Target "Application Factory Service"
    }
    return $SASTokens  
  }
  catch{
    if ($script:AppFactoryLogging) {
      Write-PSFMessage -Message "Unable to creat SAS Tokens for client with GUID <c='green'>$($GUID)</c>" -Level "Error" -Tag "Azure","Storage","SAS" -Target "Application Factory Service"
    }
    throw $_
  }
}