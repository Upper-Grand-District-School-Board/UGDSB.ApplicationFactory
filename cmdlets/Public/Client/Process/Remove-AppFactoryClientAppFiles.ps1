function Remove-AppFactoryClientAppFiles{
  [CmdletBinding()]
  param(  
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$applications,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  ) 
  $downloadFolder = Join-Path -Path $script:AppFactoryClientWorkspace -ChildPath "Downloads" -AdditionalChildPath $application.IntuneAppName
  try{
    Remove-Item -Path $downloadFolder -Force -Recurse -Confirm:$false
    if($script:AppFactoryClientLogging){
      Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Removed files." -Level $LogLevel -Tag "Applications","$($application.IntuneAppName)" -Target "Application Factory Client"
    }
  } 
  catch{
    if($script:AppFactoryClientLogging){
      Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Unable to delete files. Error: $($_)" -Level Error -Tag "Applications","$($application.IntuneAppName)" -Target "Application Factory Client"
    }
    throw $_
  }
}