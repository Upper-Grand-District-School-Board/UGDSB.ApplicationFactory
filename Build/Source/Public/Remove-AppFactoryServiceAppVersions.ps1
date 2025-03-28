function Remove-AppFactoryServiceAppVersions{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[Version]])]
  param(  
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$appGUID,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$version,
    [Parameter()][ValidateNotNullOrEmpty()][PSCustomObject[]]$AllAppList,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  ) 
  if (-not $PSBoundParameters.ContainsKey("AllAppList")){
    $AllAppList = $script:PublishedAppList
  }
  foreach($key in $AllAppList.GetEnumerator().keys){
    $container = $AllAppList.$($key)
    $blobs = $container | Where-Object { $_.Name -like "$($appGUID)/$($version)/*" }
    foreach($blob in $blobs){
      Remove-AzStorageBlob -Blob $blob.name -Container $key -Context $script:psadtStorageContext -Force
    }
  }
}