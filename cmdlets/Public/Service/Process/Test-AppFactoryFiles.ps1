function Test-AppFactoryFiles {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$applicationList,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  # Create blank list to store the applications that we will be moving forward with.
  $applications = [System.Collections.Generic.List[PSCustomObject]]@()    
  # What files should exist
  $AppFileNames = @("Install.ps1","unInstall.ps1","detection.ps1", "Icon.png","ApplicationConfig.json")
  # Loop through each of the applications
  foreach ($application in $applicationList) {
    $AppPackageFolderPath = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath $application.Information.AppFolderName
    # Check for the required files
    try{
      foreach ($AppFileName in $AppFileNames) {
        $filepath = Join-Path -Path $AppPackageFolderPath -ChildPath $AppFileName
        switch($AppFileName){
          {$_ -eq "icon.png"} {
            if (-not(Test-Path -Path $filepath)) {
              throw "[$($application.Information.DisplayName)] File Not Found $($filepath). Skipping Application."
            }
          }
          "detection.ps1" {
            if (-not(Test-Path -Path $filepath) -and $application.DetectionRule.Type -eq "Script") {
              throw "[$($application.Information.DisplayName)] File Not Found $($filepath). Skipping Application."
            }
          }
          "ApplicationConfig.json" {
            if ($application.DetectionRule.Count -eq 0) {
              throw "[$($application.Information.DisplayName)] Could not find any detection rule defined, ensure ApplicationConfig.json contains atleast one detection rule element. Skipping Application."
            }
            if ($application.DetectionRule.Count -ge 2) {
              if ($application.DetectionRule.Type -like "Script") {
                throw "[$($application.Information.DisplayName)] Multiple detection rule types are defined, where at least one of them are of type 'Script', which is not a supported configuration in Intune. Skipping Application."
              }
            }
            $content = Get-Content -Path $filepath
            if($content -match "^.*`"###.*###`".*$"){
              throw "[$($application.Information.DisplayName)] Not all fields that need to configure inApplicationConfig.json have been updated. Skipping Application."
            }
          }
        }
      }
    }
    catch{
      if ($script:AppFactoryLogging) {
        Write-PSFMessage -Message $_ -Level "Error" -Tag "Application", "$($application.Information.DisplayName)", "Error" -Target "Application Factory Service"
      }
      continue
    }
    $applications.Add($application)
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] All files and configurations appear to be correct for application."  -Level $LogLevel -Tag "Process","Files" -Target "Application Factory Service"
    }    
  }
  return $applications
}