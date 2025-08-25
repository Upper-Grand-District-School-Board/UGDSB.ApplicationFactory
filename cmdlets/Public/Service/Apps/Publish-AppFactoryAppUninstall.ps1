function Publish-AppFactoryAppUninstall{
  [CmdletBinding()]
  param(  
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  )
  $uninstallScript = [System.Collections.Generic.List[String]]@()
  $uninstallScript.Add("    ## <Perform Uninstallation tasks here>") | Out-Null
  if ($application.Uninstall.Type -eq "None") {
    return
  }  
  if($application.Uninstall.dirFiles -or $application.Uninstall.type -eq "ECNO"){
    $script:uninstallerPath = "`$adtSession.dirFiles"
  }
  else{
    $script:uninstallerPath = ""
  }
  #region Preinstall
  #if ($application.Uninstall.conflictingProcessStart) {
  #  $params = @{
  #    interactive     = $true
  #    blockingProcess = $application.Uninstall.conflictingProcessStart
  #    deferCount      = 3
  #    LogLevel        = $LogLevel
  #  }
  #  foreach ($line in $((Add-AppFactoryApplicationBlockingProcess @params -LogLevel $LogLevel).SyncRoot)) {
  #    $uninstallScript.Add($line)
  #  }    
  #}
  #endregion  
  #region WimMount
  if ($application.Uninstall.wim) {
    $mountPath = Join-Path -Path "$($ENV:ALLUSERSPROFILE)" -ChildPath "AFS" -AdditionalChildPath $application.Information.AppFolderName
    $script:uninstallerPath = "`$mountPath"
    foreach ($line in $((Add-AppFactoryAppWIM -section "start" -MountPath $mountPath -LogLevel $LogLevel).SyncRoot)) {
      $uninstallScript.Add($line)
    }     
  }
  #endregion  
  #region Uninstall Script
  if($application.Uninstall.installer -ne "===SETUPFILENAME==="){
    $setup_uninstall = $application.Uninstall.installer
  }
  else{
    $setup_uninstall = $application.SourceFiles.AppSetupFileName
  }
  $params = @{
    directory          = $script:uninstallerPath
    AppSetupFileName   = $setup_uninstall
    argumentList       = $application.Uninstall.argumentList
    secureArgumentList = $application.Uninstall.secureArgumentList
    SuccessExitCodes   = $application.Uninstall.SuccessExitCodes
    rebootExitCodes    = $application.Uninstall.rebootExitCodes
    ignoreExitCodes    = $application.Uninstall.ignoreExitCodes  
    LogLevel           = $LogLevel  
  }  
  switch ($application.Uninstall.type) {
    "MSI" {
      $params.add("Transforms", $application.Uninstall.Transforms)
      $params.add("Action", "Uninstall")
      $params.add("additionalArgumentList", $application.Uninstall.additionalArgumentList)
      foreach ($line in $((Add-AppFactoryAppMSI @params).SyncRoot)) {
        $uninstallScript.Add($line)
      }              
    }
    "EXE" {
      foreach ($line in $((Add-AppFactoryAppEXE @params).SyncRoot)) {
        $uninstallScript.Add($line)
      }      
    }
    "Name" {
      $execute = "Uninstall-ADTApplication -Name `"$($application.Uninstall.name)`""
      if($application.Uninstall.filterScript){$execute = "$($execute) -filterScript `{$($application.Uninstall.filterScript)`}"}
      $uninstallScript.Add("`t$($execute)")  | Out-Null
    }
    "GUID" {
      $uninstallScript.Add("`tUninstall-ADTApplication -ProductCode '$($application.Uninstall.productCode)'")  | Out-Null
    }
    "ECNO" {
      $uninstallScript.Add("`tPush-Location $($script:uninstallerPath)")  | Out-Null 
      $uninstallScript.Add("`tStart-Process -FilePath powershell.exe -ArgumentList `"-ExecutionPolicy Bypass -File _action.ps1 remove`" -NoNewWindow -Wait")  | Out-Null 
      $uninstallScript.Add("`tPop-Location")  | Out-Null 
    }
    "Script" {
      foreach($line in $application.Uninstall.script){
        $uninstallScript.Add("`t$($line)") | Out-Null
      }
    }
  }
  #endregion
  #region WIM Dismount
  if ($application.Uninstall.wim) {
    foreach ($line in $(Add-AppFactoryAppWIM -section "end" -MountPath $mountPath -LogLevel $LogLevel).SyncRoot) {
      $uninstallScript.Add($line)
    }    
  }
  #endregion    
  #region Postinstall
  if ($application.Uninstall.conflictingProcessEnd) {
    $params = @{
      interactive     = $false
      blockingProcess = $application.Uninstall.conflictingProcessEnd
      LogLevel        = $LogLevel
    }
    foreach ($line in $((Add-AppFactoryApplicationBlockingProcess @params -LogLevel $LogLevel).SyncRoot)) {
      $uninstallScript.Add($line)
    }
  }
  #endregion  
  $publishPath = Join-Path -Path $script:AppFactoryWorkspace -ChildPath "Publish" -AdditionalChildPath $application.Information.AppFolderName
  $publishFile = Join-Path -Path $publishPath -ChildPath "Invoke-AppDeployToolkit.ps1"
  $outputFile = Get-Content -Path $publishFile
  $outputFile -replace "    ## <Perform Uninstallation tasks here>",$($uninstallScript -join "`r`n") | Set-Content -Path $publishFile
  return
}