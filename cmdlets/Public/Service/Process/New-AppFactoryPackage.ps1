function New-AppFactoryPackage{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][System.Collections.Generic.List[PSCustomObject]]$applicationList,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  )
  # Create a list to store the results of the process
  $applications = [System.Collections.Generic.List[PSCustomObject]]@()
  foreach ($application in $applicationList) {
    try{
      $AppPublishFolderPath = Join-Path -Path $script:AppFactoryWorkspace -ChildPath "Publish" -AdditionalChildPath $application.Information.AppFolderName
      $AppSetupFolderPath = Join-Path -Path $script:AppFactoryWorkspace -ChildPath "Installers" -AdditionalChildPath $application.Information.AppFolderName
      $ApplicationDirectory = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath $application.Information.AppFolderName
      $ToolkitFile = Join-Path -Path $script:AppFactoryWorkspace -ChildPath "Publish" -AdditionalChildPath $application.Information.AppFolderName,"Invoke-AppDeployToolkit.ps1"
      Remove-Item -Path $AppPublishFolderPath -Force -Recurse -ErrorAction SilentlyContinue
      #region Create Publish Folder
      try {
        New-Item -Path $AppPublishFolderPath -ItemType Directory -ErrorAction "Stop" | Out-Null
      }
      catch {
        throw "[$($application.Information.DisplayName)] Failed to create '$($AppPublishFolderPath)' with error message: $($_.Exception.Message)"
      }
      #endregion
      #region Copy PSADT template files
      try{
        Copy-Item -Path "$($script:AppFactorySupportTemplateFolder)\PSADT\*" -Destination $AppPublishFolderPath -Recurse -Force -Confirm:$false
      }
      catch {
        throw "[$($application.Information.DisplayName)] Unable to copy template files: $($_.Exception.Message)"
      }
      #endregion
      #region Copy Application Files
      if($application.SourceFiles.AppSource -ne "PSADT"){
        try{
          Copy-Item -Path "$($AppSetupFolderPath)\*" -Destination "$($AppPublishFolderPath)\Files" -Recurse -Force -Confirm:$false
        }
        catch {
          throw "[$($application.Information.DisplayName)] Unable to copy template files: $($_.Exception.Message)"
        }
      }
      #endregion
      #region Inject Install/Uninstall in Deployment Script
      $ToolkitContent = Get-Content -Path $ToolkitFile -Raw
      $ToolkitContent = $ToolkitContent -replace "###INTUNEAPPNAME###", $application.Information.DisplayName
      $ToolkitContent = $ToolkitContent -replace "###APPPUBLISHER###", $application.Information.Publisher
      $ToolkitContent = $ToolkitContent -replace "###VERSION###", $application.SourceFiles.PackageVersion
      $ToolkitContent = $ToolkitContent -replace "###APPARCH###", $application.RequirementRule.Architecture
      $ToolkitContent = $ToolkitContent -replace "###AppLang###", "English"
      $ToolkitContent = $ToolkitContent -replace "###APPDATE###", (Get-Date).ToShortDateString()
      $InstallerContent = Get-Content -Path "$($ApplicationDirectory)\install.ps1" -ErrorAction SilentlyContinue
      $UninstallerContent = Get-Content -Path "$($ApplicationDirectory)\uninstall.ps1" -ErrorAction SilentlyContinue
      $ToolKitInstallStart = $ToolkitContent -split "    ## <Perform Installation tasks here>"
      $ToolkitUninstallStart = $ToolKitInstallStart[1] -split "    ## <Perform Uninstallation tasks here>"
      $NewContent = [System.Collections.Generic.List[string]]::new()
      foreach($line in $ToolKitInstallStart[0]){
        $NewContent.Add($line)
      }
      $NewContent.Add("    ## <Perform Installation tasks here>")
      foreach($line in $InstallerContent){
        $NewContent.Add(($line -replace "###SETUPFILENAME###", $($application.SourceFiles.AppSetupFileName)))
      }
      foreach($line in $ToolkitUninstallStart[0]){
        $NewContent.Add($line)
      }
      $NewContent.Add("    ## <Perform Uninstallation tasks here>")
      foreach($line in $UninstallerContent){
        $NewContent.Add(($line -replace "###SETUPFILENAME###", $($application.SourceFiles.AppSetupFileName)))
      }      
      foreach($line in $ToolkitUninstallStart[1]){
        $NewContent.Add($line)
      }
      Out-File -InputObject $NewContent -FilePath $ToolkitFile -Encoding "utf8" -Force -Confirm:$false  
      #endregion
      $iconPath = Join-Path -Path $AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath  $application.Information.AppFolderName,"Icon.png"
      $iconDestination = Join-Path -Path $AppPublishFolderPath -ChildPath "Icon.png"
      Copy-Item -Path $iconPath -Destination $iconDestination -Force -Confirm:$false  
      if($application.DetectionRule.Type -eq "Script"){
        $detectionPath = Join-Path -Path $AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath  $application.Information.AppFolderName,$application.DetectionRule.ScriptFile
        $detectionDestination = Join-Path -Path $AppPublishFolderPath -ChildPath $application.DetectionRule.ScriptFile
        $detectionContent = Get-Content -Path $detectionPath -Raw
        $detectionContent = $detectionContent -replace "###VERSION###", $application.SourceFiles.PackageVersion
        Out-File -InputObject $detectionContent -FilePath $detectionDestination -Encoding "utf8" -Force -Confirm:$false  
      }
    }
    catch{
      if ($script:AppFactoryLogging) {
        Write-PSFMessage -Message $_ -Level "Error" -Tag "Application", "$($application.Information.DisplayName)", "Error" -Target "Application Factory Service"
      }
      continue
    }
    $applications.add($application)
  }
  return $applications
}