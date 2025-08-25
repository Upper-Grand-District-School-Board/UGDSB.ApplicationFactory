function Publish-AppFactoryAppInstall {
  [CmdletBinding()]
  param(  
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  )
  $installScript = [System.Collections.Generic.List[String]]@()
  $installScript.Add("    ## <Perform Installation tasks here>") | Out-Null
  if ($application.install.Type -eq "None") {
    return
  }
  $script:installerPath = "`$adtSession.dirFiles"
  #region Preinstall
  #if ($application.install.conflictingProcessStart) {
  #  $params = @{
  #    interactive     = $true
  #    blockingProcess = $application.install.conflictingProcessStart
  #    deferCount      = 3
  #    LogLevel        = $LogLevel
  #  }
  #  foreach ($line in $((Add-AppFactoryApplicationBlockingProcess @params -LogLevel $LogLevel).SyncRoot)) {
  #    $installScript.Add($line)
  #  }    
  #}
  #endregion
  #region WimMount
  if ($application.install.wim) {
    $mountPath = Join-Path -Path "$($ENV:ALLUSERSPROFILE)" -ChildPath "AFS" -AdditionalChildPath $application.Information.AppFolderName
    $script:installerPath = "`$mountPath"
    foreach ($line in $((Add-AppFactoryAppWIM -section "start" -MountPath $mountPath -LogLevel $LogLevel).SyncRoot)) {
      $installScript.Add($line)
    }     
  }
  #endregion
  #region Install Script
  if($application.install.installer -ne "===SETUPFILENAME==="){
    $setup_install = $application.install.installer
  }
  else{
    $setup_install = $application.SourceFiles.AppSetupFileName
  }
  $params = @{
    directory          = $script:installerPath
    AppSetupFileName   = $setup_install
    argumentList       = $application.install.argumentList
    secureArgumentList = $application.install.secureArgumentList
    SuccessExitCodes   = $application.install.SuccessExitCodes
    rebootExitCodes    = $application.install.rebootExitCodes
    ignoreExitCodes    = $application.install.ignoreExitCodes  
    LogLevel           = $LogLevel  
  }
  if($application.Program.InstallExperience -eq "User"){
    $params.add("userInstall",$true)
  }
  switch ($application.install.type) {
    "EXE" {
      foreach ($line in $((Add-AppFactoryAppEXE @params).SyncRoot)) {
        $installScript.Add($line)
      }      
    }
    "MSI" {
      $params.add("Transforms", $application.install.Transforms)
      $params.add("Action", "Install")
      $params.add("additionalArgumentList", $application.install.additionalArgumentList)
      $params.add("SkipMSIAlreadyInstalledCheck", $application.Install.SkipMSIAlreadyInstalledCheck)
      foreach ($line in $((Add-AppFactoryAppMSI @params).SyncRoot)) {
        $installScript.Add($line)
      }              
    }
    "Script" {
      foreach($line in $application.Install.script){
        $installScript.Add("`t$($line)") | Out-Null
      }
    }
    "PowerShell" {
      $installScript.Add("`tExecute-Process -Path `"powershell.exe`" -Parameters `"-ExecutionPolicy Bypass -File `"`"`$($($script:installerPath))\$($application.Install.script)`"`"`"")  | Out-Null 
    }
    "ECNO" {
      $installScript.Add("`tPush-Location $($script:installerPath)")  | Out-Null 
      $installScript.Add("`tStart-Process -FilePath powershell.exe -ArgumentList `"-ExecutionPolicy Bypass -File _action.ps1 install`" -NoNewWindow -Wait")  | Out-Null 
      $installScript.Add("`tPop-Location")  | Out-Null 
    }
  }
  #endregion
  #region WIM Dismount
  if ($application.install.wim) {
    foreach ($line in $(Add-AppFactoryAppWIM -section "end" -MountPath $mountPath -LogLevel $LogLevel).SyncRoot) {
      $installScript.Add($line)
    }    
  }
  #endregion    
  #region Postinstall
  if ($application.install.conflictingProcessEnd) {
    $params = @{
      interactive     = $false
      blockingProcess = $application.install.conflictingProcessEnd
      LogLevel        = $LogLevel
    }
    foreach ($line in $((Add-AppFactoryApplicationBlockingProcess @params -LogLevel $LogLevel).SyncRoot)) {
      $installScript.Add($line)
    }
  }
  #endregion   


  #C:\DevOps\ApplicationFactoryApplications\Workspace\Publish\7-Zip\Invoke-AppDeployToolkit.ps1
  $publishPath = Join-Path -Path $script:AppFactoryWorkspace -ChildPath "Publish" -AdditionalChildPath $application.Information.AppFolderName
  $publishFile = Join-Path -Path $publishPath -ChildPath "Invoke-AppDeployToolkit.ps1"
  $outputFile = Get-Content -Path $publishFile
  $outputFile -replace "    ## <Perform Installation tasks here>",$($installScript -join "`r`n") | Set-Content -Path $publishFile
  return
}
