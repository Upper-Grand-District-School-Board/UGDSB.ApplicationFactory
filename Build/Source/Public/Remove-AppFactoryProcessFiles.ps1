function Remove-AppFactoryProcessFiles{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$applicationList,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  foreach($application in $applicationList){
    $installersPath = Join-Path -Path $script:AppFactoryWorkspace -ChildPath "Installers" -AdditionalChildPath $application.Information.AppFolderName
    $publishPath = Join-Path -Path $script:AppFactoryWorkspace -ChildPath "Publish" -AdditionalChildPath $application.Information.AppFolderName
    Remove-Item -path $installersPath -Recurse -Force -Confirm:$false
    if ($script:AppFactoryLogging) {
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Application Installer Folder Removed [<c='green'>$($installersPath)</c>]." -Level  "Output" -Tag "Process",$application.Information.DisplayName -Target "Application Factory Service"
    }
    Remove-Item -path $publishPath -Recurse -Force -Confirm:$false
    if ($script:AppFactoryLogging) {
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Application Publish Folder Removed [<c='green'>$($publishPath )</c>]." -Level  "Output" -Tag "Process",$application.Information.DisplayName -Target "Application Factory Service"
    }    
  }
}