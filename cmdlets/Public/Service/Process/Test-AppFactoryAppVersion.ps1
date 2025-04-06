function Test-AppFactoryAppVersion{
  [CmdletBinding()]
  [OutputType([System.Collections.Hashtable])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][System.Collections.Generic.List[PSCustomObject]]$applicationList,
    [Parameter()][ValidateNotNullOrEmpty()][switch]$force,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )  
  $FilteredList = [System.Collections.Generic.List[PSCustomObject]]::new()
  foreach($Application in $ApplicationList){
    if($application.SourceFiles.PauseUpdate){
      if ($script:AppFactoryLogging) {
        Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] <c='yellow'>Updates are paused for this application.</c>" -Level $LogLevel -Tag "Application", "$($application.Information.DisplayName)" -Target "AppFactory"
      }
      continue
    }
    switch ($Application.SourceFiles.AppSource) {
      "ECNO" {$AppItem = Get-AppFactoryECNOAppItem -application $Application -LogLevel $LogLevel}
      "Sharepoint" {$AppItem = Get-AppFactorySharepointAppItem -application $Application -LogLevel $LogLevel}
      "LocalStorage" {$AppItem = Get-AppFactoryLocalStorageAppItem -application $Application -LogLevel $LogLevel}
      "StorageAccount" {$AppItem = Get-AppFactoryAzureStorageAppItem -application $Application -LogLevel $LogLevel}
      "Winget" { $AppItem = Get-AppFactoryWinGetAppItem -application $Application -LogLevel $LogLevel }
      "Evergreen" {$AppItem = Get-AppFactoryEvergreenAppItem -application $Application -LogLevel $LogLevel}
      "PSADT" { $AppItem = Get-AppFactoryPSADTAppItem -application $application -LogLevel $LogLevel }
    }
    if($null -ne $AppItem){
      $required = $false
      if($application.SourceFiles.publishTo.count -eq 0){
        if($script:PublishedAppList.Public.Name -notcontains "$($application.GUID)/$($AppItem.Version)/App.json"){
          if ($script:AppFactoryLogging) {
            Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Specified version (<c='green'>$($AppItem.Version)</c>) is not already packaged in the public container." -Level $LogLevel -Tag "Application", "$($application.Information.DisplayName)" -Target "AppFactory"
          }
          $required = $true
        }
      }
      else{
        foreach($publishTo in $application.SourceFiles.publishTo){
          if($script:PublishedAppList.$($publishTo).Name -notcontains "$($application.GUID)/$($AppItem.Version)/App.json"){
            Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Specified version (<c='green'>$($AppItem.Version)</c>) is not already packaged in the <c='green'>$($publishTo)</c> container." -Level $LogLevel -Tag "Application", "$($application.Information.DisplayName)" -Target "AppFactory"
            $required = $true
          }
        }
      }
      if($required -or $force.IsPresent){
        if ($script:AppFactoryLogging) {
          if($force.IsPresent){
            Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Currently the specified version (<c='green'>$($AppItem.Version)</c>) of the application is already packaged but force is set." -Level $LogLevel -Tag "Application", "$($application.Information.DisplayName)", "WinGet" -Target "AppFactory"
          }
          else{
            Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Specified version (<c='green'>$($AppItem.Version)</c>) is not already packaged in at least one of the expected clients." -Level $LogLevel -Tag "Application", "$($application.Information.DisplayName)", "WinGet" -Target "AppFactory"
          }
        }
        $Application.Information.AppVersion = $AppItem.Version
        if(($application.DetectionRule | Get-Member -Name Value)){
          $application.DetectionRule[0].Value = $AppItem.Version
        }
        $Application.SourceFiles | Add-Member -MemberType NoteProperty -Name "PackageVersion" -Value $AppItem.Version -Force
        $Application.SourceFiles | Add-Member -MemberType NoteProperty -Name "PackageSource" -Value $AppItem.URI -Force
        $FilteredList.Add($Application)
      }
      else{
        if ($script:AppFactoryLogging) {
          Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Currently the version specfieid (<c='green'>$($AppItem.Version)</c>) of the application is already packaged and force is not set." -Level $LogLevel -Tag "Application", "$($application.Information.DisplayName)", "WinGet" -Target "AppFactory"
        }
      }
    }
  }
  return $FilteredList
}
