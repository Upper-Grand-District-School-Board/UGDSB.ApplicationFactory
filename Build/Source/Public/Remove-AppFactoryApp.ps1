function Remove-AppFactoryApp{
  [CmdletBinding()]
  param(  
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$appGUID,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  )
  # Get the application Config
  $configfile = Get-AppFactoryApp -appGUID $appGUID -LogLevel $LogLevel
  if (-not ($configfile)) {
    throw "Application with GUID $($appGUID) does not exist."
  }
  # Get the application folder
  $ApplicationFolder = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath $configfile.Information.AppFolderName
  # Remove the folder
  try{
    Remove-Item -Path $ApplicationFolder -Recurse -Force | Out-Null
    Write-PSFMessage -Message "[$($configfile.Information.DisplayName)] Removed Configuration Files at path $($ApplicationFolder)" -Level $LogLevel -Tag "Application","$($appGUID)","$($configfile.Information.DisplayName)"  -Target "Application Factory Service"
  }
  catch{
    Write-PSFMessage -Message "Error Encountered: $($_)" -Level "Error" -Tag "Application","$($appGUID)","$($configfile.Information.DisplayName)" -Target "Application Factory Service"
    throw $_  
  }
}  