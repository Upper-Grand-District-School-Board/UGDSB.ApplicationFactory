function New-AppFactoryIntuneFile {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$applicationList,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  # Create blank list to store the applications that we will be moving forward with.
  $applications = [System.Collections.Generic.List[PSCustomObject]]@()
  # Loop through each of the applications
  foreach ($application in $applicationList) {
    try{
      $SourceFolder = Join-Path -Path $script:AppFactoryWorkspace -ChildPath "Publish" -AdditionalChildPath $application.Information.AppFolderName
      $IntuneWinAppUtilPath = Join-Path -Path $script:AppFactorySupportFiles -ChildPath "IntuneWinAppUtil.exe"
      $OutputPackage = Join-Path -Path $SourceFolder -ChildPath "$([System.IO.Path]::GetFileNameWithoutExtension($application.PackageInformation.SetupFile)).intunewin"
      $param = @{
        FilePath = $IntuneWinAppUtilPath
        ArgumentList = "-c ""$($SourceFolder)"" -s ""$($application.PackageInformation.SetupFile)"" -o ""$($SourceFolder)"" -q"
        LoadUserProfile = $false
        Passthru = $true
        UseNewEnvironment = $true
        Wait = $true
      }
      $process = Start-Process @param
      if($process.ExitCode -eq 0){
        Rename-Item -path $OutputPackage -NewName "$($application.Information.DisplayName).intunewin" -Force
      }
      else{
        throw "Process failed with exit code $($process.ExitCode)"
      }
      $application.SourceFiles | Add-Member -MemberType NoteProperty -Name IntunePackage -Value "$($application.Information.DisplayName).intunewin" -Force
      $applications.Add($application)
    }
    catch{
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Unable to create intune win files. Error: $($_)" -Level  "Warning" -Tag "Process",$application.Information.DisplayName -Target "Application Factory Service"
      continue          
    }
  }   
  return $applications 
}