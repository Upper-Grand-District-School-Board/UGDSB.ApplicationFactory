function Write-AppConfiguration{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$configfile,
    [Parameter()][ValidateSet("Output","Verbose")][string]$LogLevel = "Verbose"
  )  
  try{
    $outputPath = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath $configfile.Information.AppFolderName, "ApplicationConfig.json"
    $configfile | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputPath
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "[$($configfile.Information.DisplayName)] Wrote default app configuration" -Level $LogLevel -Tag "Application", "$($configfile.Information.DisplayName)", "$($configFIle.GUID)" -Target "AppFactory" 
    }    
  }
  catch{
    throw $_ 
  }    
}