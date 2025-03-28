function Get-AppFactoryInstaller {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][System.Collections.Generic.List[PSCustomObject]]$applicationList,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"    
  )
  # Create list to store results of the process
  $applications = [System.Collections.Generic.List[PSCustomObject]]@()
  foreach ($application in $applicationList) {
    try {
      $AppSetupFolderPath = Join-Path -Path $script:AppFactoryWorkspace -ChildPath "Installers" -AdditionalChildPath $application.Information.AppFolderName
      # Create path if it doesn't exist
      if (-not(Test-Path -Path $AppSetupFolderPath -PathType "Container")) {
        try {
          New-Item -Path $AppSetupFolderPath -ItemType "Container" -ErrorAction "Stop" | Out-Null
        }
        catch [System.Exception] {
          throw "[$($application.Information.DisplayName)] Failed to create '$($Path)' with error message: $($_.Exception.Message)"
        }
      }
      # Download installer file
      try {
        $OutFilePath = Join-Path -Path $AppSetupFolderPath -ChildPath $application.SourceFiles.AppSetupFileName
        if ($script:AppFactoryLogging) {
          Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Downloading setupfile <c='green'>$($application.SourceFiles.PackageSource)</c>" -Level $LogLevel -Tag "Application", "$($application.Information.DisplayName)", "Download" -Target "Application Factory Service"
        }
        switch ($Application.SourceFiles.AppSource) {
          "ECNO" {
            Get-AppFactoryECNOFile -application $application -Destination $AppSetupFolderPath -LogLevel $LogLevel
          }
          "Sharepoint" {
            Get-AppFactorySharepointFile -application $application -Destination $AppSetupFolderPath -LogLevel $LogLevel
          }
          "LocalStorage" {
            Get-ChildItem -Path $application.SourceFiles.PackageSource | foreach-object {Copy-Item $_.FullName -Destination $AppSetupFolderPath -Force -ErrorAction "Stop" -Recurse} | Out-Null
          }
          "StorageAccount" {
            Get-AppFactoryAzureStorageFile -application $application -Destination $AppSetupFolderPath -LogLevel $LogLevel 
          }
          "PSADT" {}
          default {
            Invoke-WebRequest -Uri $application.SourceFiles.PackageSource -OutFile $OutFilePath -UseBasicParsing -ErrorAction "Stop" 
          }
        }
      }
      catch [System.Exception] {
        throw "[$($application.Information.DisplayName)] Failed to download file from '$($application.SourceFiles.PackageSource)' with error message: $($_.Exception.Message)"
      }
    }
    catch {
      if ($script:AppFactoryLogging) {
        Write-PSFMessage -Message $_ -Level "Error" -Tag "Application", "$($application.Information.DisplayName)", "Error" -Target "Application Factory Service"
      }
      continue
    }
    if ($script:AppFactoryLogging) {
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Successfully downloaded files." -Level $LogLevel -Tag "Application", "$($application.Information.DisplayName)", "WinGet" -Target "AppFactory"
    }    
    $applications.Add($application)
  }
  return $applications
}