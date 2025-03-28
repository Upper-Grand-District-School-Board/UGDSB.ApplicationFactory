<#
  .DESCRIPTION
  This cmdlet is designed to download contacts from Azure Storage Account
  .PARAMETER application
  The application object that we are working for so that we can ensure that get the correct and current data 
  .PARAMETER LogLevel
  If logging is enabled, what level of logging do we want, default is verbose.
#>
function Get-AppFactoryLocalStorageAppItem {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose" 
  )
  try {
    if ($script:AppFactoryLogging) {
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Getting Local Storage based application"  -Level $LogLevel -Tag "Application", "$($application.Information.DisplayName)", "AzureStorage" -Target "Application Factory Service"
    }
    $localAppPath = Join-Path -Path $script:AppFactorySourceDir -ChildPath "LocalInstallers" -AdditionalChildPath $application.SourceFiles.StorageAccountContainerName
    $localAppList = Get-ChildItem -Path $localAppPath | Sort-Object LastWriteTime -Descending
    # Only return the top item
    $PSObject = [PSCustomObject]@{
      "Version" = $localAppList[0].Name
      "URI" = $localAppList[0].FullName
    }
    return $PSObject        
  }
  catch {
    Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Error Occured: $($_)" -Level "Error" -Tag "Application", "$($application.Information.DisplayName)" -Target "Application Factory Service"
    throw $_
  }         
}