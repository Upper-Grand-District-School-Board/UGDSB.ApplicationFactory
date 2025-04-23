function Publish-AppFactoryIntunePackage {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][System.Collections.Generic.List[PSCustomObject]]$applicationList,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  )
  # Create a list to store the results of the process
  $applications = [System.Collections.Generic.List[PSCustomObject]]@()
  foreach ($application in $applicationList) {
    try {
      # Check what Azure Storage Containers we should be uploading the files to
      $containerUploads = [System.Collections.Generic.List[PSCustomObject]]@()
      if ((($application.SourceFiles.PublishTo.getType()).BaseType.Name -eq "Array" -and $application.SourceFiles.publishTo.Count -gt 0) -or (($application.SourceFiles.PublishTo.getType()).BaseType.Name -eq "Object" -and $application.SourceFiles.publishTo.length -gt 1)) {
        foreach ($org in $application.SourceFiles.PublishTo) {
          $containerUploads.Add($org) | Out-Null
        }    
      }
      else {
        $containerUploads.Add($script:AppFactoryPublicFolder) | Out-Null
      } 
      # File Upload Details
      $SourceFolder = Join-Path -Path $script:AppFactoryWorkspace -ChildPath "Publish" -AdditionalChildPath $application.Information.AppFolderName
      $applicationJSON = $application.PSObject.Copy()
      $applicationJSON.PSObject.Properties.Remove("GUID")
      $applicationJSON.PSObject.Properties.Remove("SourceFiles")
      $applicationJSON.PSObject.Properties.Remove("Install")
      $applicationJSON.PSObject.Properties.Remove("Uninstall")
      $applicationJSONPath = Join-Path -Path $SourceFolder -ChildPath "App.json"
      if($applicationJSON.DetectionRule.KeyPath -match "###PRODUCTCODE###"){
        $msi = Join-Path -Path $SourceFolder -ChildPath "files" -AdditionalChildPath $application.SourceFiles.AppSetupFileName
        $productCode = get-msiMetaData -path $msi -Property ProductCode
        $applicationJSON.DetectionRule[0].KeyPath = $applicationJSON.DetectionRule.KeyPath -replace "###PRODUCTCODE###",[regex]::Match($productCode,"{.*}").value
      }      
      $applicationJSON | ConvertTo-JSON -Depth 10 | Out-File -Path $applicationJSONPath -Force
      # Application Files to Upload
      $ApplicationPath = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath $application.Information.AppFolderName
      $ScriptDataFile = Join-Path -Path $SourceFolder -ChildPath $application.DetectionRule.ScriptFile
      $AppIconFile = Join-Path -Path $ApplicationPath -ChildPath $application.PackageInformation.IconFile  
      $IntunePackage = Join-Path -Path $SourceFolder -ChildPath $application.SourceFiles.IntunePackage  
      $appUploads = [PSCustomObject]@(
        @{
          "File" = $applicationJSONPath
          "Blob" = "$($application.GUID)/$($application.Information.AppVersion)/App.json"
        },
        @{
          "File" = $IntunePackage
          "Blob" = "$($application.GUID)/$($application.Information.AppVersion)/$($application.SourceFiles.IntunePackage)"
        },
        @{
          "File" = $AppIconFile
          "Blob" = "$($application.GUID)/$($application.Information.AppVersion)/$($application.PackageInformation.IconFile)"
        },
        @{
          "File" = $ScriptDataFile
          "Blob" = "$($application.GUID)/$($application.Information.AppVersion)/detection.ps1"
        }       
      )
      # Process the uploads for each of the files as required to each container that is required
      foreach ($container in $containerUploads) {
        if ($script:AppFactoryLogging) {
          Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Uploading files to storage" -Level $LogLevel -Tag "Application", "$($application.Information.DisplayName)" -Target "Application Factory Service"
        }
        foreach ($upload in $appUploads) {
          if ((Test-Path $upload.File) -and (Get-Item $upload.File).Attributes[0] -ne "Directory") {
            try {
              if ($script:AppFactoryLogging) {
                Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>)] Uploading <c='green'>$($upload.File)</c> to <c='green'>$($container)</c> container" -Level $LogLevel -Tag "Application", "$($application.Information.DisplayName)" -Target "Application Factory Service"
              }
              Set-AzStorageBlobContent @upload -Container $container -Context $script:psadtStorageContext -Force -ErrorAction Stop | Out-Null
            }
            catch {
              throw "[$($application.IntuneAppName)] Unable able to upload file: $($_.Exception.Message)"
            }        
          }
        }             
      }
      $application.SourceFiles.LastUpdate = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
      $originalAppInfo = Get-Content -Path "$($ApplicationPath)\ApplicationConfig.json" | ConvertFrom-JSON
      $application.DetectionRule = $originalAppInfo.DetectionRule
      $application | ConvertTo-JSON -Depth 10 | Out-File -FilePath "$($ApplicationPath)\ApplicationConfig.json" -Force
      $applications.Add($application)
    } 
    catch {
      if ($script:AppFactoryLogging) {
        Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Failed to upload intune file" -Level "Error" -Tag "Application", "$($application.Information.DisplayName)" -Target "Application Factory Service"
      }        
      throw $_
    }
  } 
  
  return $applications 
}