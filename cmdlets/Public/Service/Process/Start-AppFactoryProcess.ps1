function Start-AppFactoryProcess{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$ApplicationServicePath,
    [Parameter()][switch]$EnableLogging,
    [Parameter()][string[]]$AppList,
    [Parameter()][switch]$force,
    [Parameter()][switch]$testmode,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  # Start the Application Factory Process
  Initialize-AppFactoryProcess -ApplicationServicePath $ApplicationServicePath -EnableLogging:$EnableLogging.IsPresent -LogLevel $LogLevel 
  # Get All applications in the process
  $AllApplications = Get-AppFactoryApp -active
  # If set to filter to specific application file
  if ($PSBoundParameters.ContainsKey("AppList")){
    $AllApplications = $AllApplications | Where-Object { $_.GUID -in $AppList }
  }
  if($EnableLogging.IsPresent){
    Write-PSFMessage -Message "There are <c='green'>$($AllApplications.count)</c> applications configured in AppFactory"  -Level  "Output" -Tag "Process" -Target "Application Factory Service"
    Write-PSFMessage -Message "Getting the latest version number for each application in the process" -Level  "Output" -Tag "Process" -Target "Application Factory Service"
  }
  if($AllApplications.Count -eq 0){
    Write-PSFMessage -Message "No applications set to active in AppFactory" -Level  "Output" -Tag "Process" -Target "Application Factory Service"
    return
  }
  $ApplicationList = Test-AppFactoryAppVersion -applicationList $AllApplications -LogLevel $LogLevel -force:$force.IsPresent
  if($ApplicationList.Count -eq 0){
    Write-PSFMessage -Message "No new versions of applications found" -Level  "Output" -Tag "Process" -Target "Application Factory Service"
    return
  }
  if($EnableLogging.IsPresent){
    Write-PSFMessage -Message "There are <c='green'>$($applicationList.count)</c> apps that require an update." -Level  "Output" -Tag "Process" -Target "Application Factory Service"
  }


  foreach($Application in $ApplicationList){
    $publish = Test-AppFactoryFiles -applicationList $Application -LogLevel $LogLevel
    if($publish.Count -eq 0){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] No applications to process." -Level  "Output" -Tag "Process" -Target "Application Factory Service"
      continue
    }
    if($EnableLogging.IsPresent){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Confirmed application files." -Level  "Output" -Tag "Process" -Target "Application Factory Service"
    }
    $publish = Get-AppFactoryInstaller -applicationList $publish -LogLevel $LogLevel
    if($publish.Count -eq 0){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] No applications to process." -Level  "Output" -Tag "Process" -Target "Application Factory Service"
      continue
    }
    if($EnableLogging.IsPresent){     
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Downloaded application files." -Level  "Output" -Tag "Process" -Target "Application Factory Service"
    }
    $publish = New-AppFactoryPackage -applicationList $publish -LogLevel $LogLevel
    if($publish.Count -eq 0){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] No applications to process." -Level  "Output" -Tag "Process" -Target "Application Factory Service"
      continue
    }
    if($EnableLogging.IsPresent){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Copied template files to build from." -Level  "Output" -Tag "Process" -Target "Application Factory Service"
    }
    try{
      Publish-AppFactoryAppInstall -application $publish -LogLevel $LogLevel
      if($EnableLogging.IsPresent){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Updated install lines for application." -Level  "Output" -Tag "Process" -Target "Application Factory Service"
      }
      Publish-AppFactoryAppUninstall -application $publish -LogLevel $LogLevel  
      if($EnableLogging.IsPresent){
        Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Updated uninstall lines for application." -Level  "Output" -Tag "Process" -Target "Application Factory Service"
      }
    }
    catch{
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Unable to create publishing files." -Level  "Warning" -Tag "Process",$application.Information.DisplayName -Target "Application Factory Service"
      continue    
    }
    if($EnableLogging.IsPresent){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Files published." -Level  "Output" -Tag "Process",$application.Information.DisplayName -Target "Application Factory Service"
    }
    $publish = New-AppFactoryIntuneFile -applicationList $publish -LogLevel $LogLevel
    if($publish.Count -eq 0){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] No applications to process." -Level  "Output" -Tag "Process" -Target "Application Factory Service"
      continue
    }  
    if($EnableLogging.IsPresent){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Created intune application file." -Level  "Output" -Tag "Process",$application.Information.DisplayName -Target "Application Factory Service"
    }    
    if(-not $testmode.IsPresent){
      $publish = Publish-AppFactoryIntunePackage -applicationList $publish -LogLevel $LogLevel
      if($publish.Count -gt 0){
        foreach($app in $publish){
          Write-PSFMessage -Message "[<c='green'>$($app.Information.DisplayName)</c>] Application published." -Level  "Output" -Tag "Process",$app.Information.DisplayName -Target "Application Factory Service"
        }
      }
      Remove-AppFactoryProcessFiles -applicationList $publish -LogLevel $LogLevel  
    }
    else{
      if($EnableLogging.IsPresent){
        Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] <c='yellow'>running in test mode so did not publish or remove files.</c>" -Level  "Output" -Tag "Process",$application.Information.DisplayName -Target "Application Factory Service"
      }
    }
  }
}