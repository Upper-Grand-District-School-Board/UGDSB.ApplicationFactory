<#
  .DESCRIPTION
  This cmdlet is designed to download contacts from Azure Storage Account
  .PARAMETER application
  The application object that we are working for so that we can ensure that get the correct and current data 
  .PARAMETER LogLevel
  If logging is enabled, what level of logging do we want, default is verbose.
#>
function Get-AppFactoryAzureStorageAppItem {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose" 
  )
  try {
    if ($script:AppFactoryLogging) {
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Getting Azure Storage based application"  -Level $LogLevel -Tag "Application", "$($application.Information.DisplayName)", "AzureStorage" -Target "Application Factory Service"
    }
    $StorageBlobContents = Get-AzStorageBlob -Container $application.SourceFiles.StorageAccountContainerName -Context $script:appStorageContext -ErrorAction Stop | Where-Object {$_.Name -ne "latest.json"} | Sort-Object LastModified -Descending
    $fileInfo = $StorageBlobContents[0].Name -split "/"
    # Only return the top item
    $PSObject = [PSCustomObject]@{
      "Version" = $fileInfo[0]
      "URI" = $fileInfo[0]
    }
    return $PSObject    
  }
  catch {
    Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Error Occured: $($_)" -Level "Error" -Tag "Application", "$($application.Information.DisplayName)" -Target "Application Factory Service"
    throw $_
  }  
}