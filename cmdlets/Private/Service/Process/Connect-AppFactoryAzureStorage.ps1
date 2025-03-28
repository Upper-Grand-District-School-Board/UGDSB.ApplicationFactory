
function Connect-AppFactoryAzureStorage {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$storageContainer,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][securestring]$storageSecret,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose" 
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
      if ($script:AppFactoryLogging) {
        Write-PSFMessage -Message "Creating Azure Storage Context for <c='green'>$($storageContainer)</c>" -Level $LogLevel -Tag "Storage", "$($storageContainer)" -Target "Application Factory Service"
      }
      $storageAccountContext = New-AzStorageContext @storageVars
    }
    catch {
      Write-PSFMessage -Message "Error Encountered: $($_)" -Level "Error" -Tag "Storage" -Target "Application Factory Service"
      throw $_
    }
  }
  end {
    return $storageAccountContext
  }
}