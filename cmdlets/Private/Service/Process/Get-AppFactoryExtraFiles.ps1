function Get-AppFactoryExtraFiles{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$destination,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose" 
  )
  try{
    foreach($container in $Application.SourceFiles.ExtraFiles){
      #$path = "$($application.SourceFiles.PackageSource)"
      $StorageBlobContents = Get-AzStorageBlob -Container $container -Context $script:appStorageContext -ErrorAction Stop
      foreach($blob in $StorageBlobContents){
        $file = $blob.Name -split "/"
        if($file.length -gt 2){
          $directoryPath = Join-path -Path $destination -ChildPath (($file[1..($file.length -2)]) -join "/")
          New-Item -Path $directoryPath -ItemType Directory -Force | Out-Null
        }
        else{
          $directoryPath = $destination
        }
        $params = @{
          Context = $script:appStorageContext
          Container = $container
          Blob = $blob.Name
          Destination = (Join-Path -Path $directoryPath -ChildPath $file[-1])
          Force = $true
        }
        Get-AzStorageBlobContent @params | Out-Null  
      }      
    }
  }
  catch {
    Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Error Occured: $($_)" -Level "Error" -Tag "Application", "$($application.Information.DisplayName)" -Target "Application Factory Service"
    throw $_
  }   
}