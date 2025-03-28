function Connect-AppFactoryAzureStorage {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$storageContainer,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][securestring]$storageSecret
  )
  begin {
    # Generate variables to connect to azure storage
    $storageVars = @{
      "StorageAccountName" = $storageContainer
      "StorageAccountKey"  = ConvertFrom-SecureString $storageSecret -AsPlainText
    }    
  }
  process {
    try {
      # Create an azure storage account context using an access key
      $storageAccountContext = New-AzStorageContext @storageVars
    }
    catch {
      throw $_
    }
  }
  end {
    return $storageAccountContext
  }
}