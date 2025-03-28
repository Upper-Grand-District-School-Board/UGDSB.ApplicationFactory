function Get-AppFactoryAzureStorageFile{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$destination,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose" 
  )
  try{
    $path = "$($application.SourceFiles.PackageSource)"
    $StorageBlobContents = Get-AzStorageBlob -Container $application.SourceFiles.StorageAccountContainerName -Context $script:appStorageContext -ErrorAction Stop | Where-Object {$_.Name -like "$($path)*"}
    foreach($blob in $StorageBlobContents){
      $file = $blob.Name -split "/"
      $params = @{
        Context = $script:appStorageContext
        Container = $application.SourceFiles.StorageAccountContainerName
        Blob = $blob.Name
        Destination = (Join-Path -Path $destination -ChildPath $file[-1])
        Force = $true
      }
      Get-AzStorageBlobContent @params | Out-Null  
    }
  }
  catch {
    Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Error Occured: $($_)" -Level "Error" -Tag "Application", "$($application.Information.DisplayName)" -Target "Application Factory Service"
    throw $_
  }  
}