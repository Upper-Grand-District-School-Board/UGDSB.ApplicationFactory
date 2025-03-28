function Get-AppFactoryWinGetAppItem{
  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter()][ValidateSet("Output","Verbose")][string]$LogLevel = "Verbose"    
  )
  # Create the argument and then run the winget
  $arguments = @("search", "$($application.SourceFiles.AppID)")
  $winget = & "winget" $arguments | Out-String -Stream
  # Confirm that a package was found
  foreach ($RowItem in $winget) {
    if ($RowItem -eq "No package found matching input criteria.") {
      if($script:AppFactoryLogging){
        Write-PSFMessage -Message "[$($application.Information.DisplayName)] No package found matching specified id: <c='green'>$($application.SourceFiles.AppId)</c>"  -Level "Error" -Tag "Process","Winget" -Target "Application Factory Service"
      }
      return $null
    }
  }
  # Now look for the specific item and get the details and parse them out
  $arguments = @("show", "$($application.SourceFiles.AppID)")
  $winget = & "winget" $arguments | Out-String -Stream
  $PSObject = [PSCustomObject]@{
    "Version" = ($winget | Where-Object { $PSItem -match "^Version\:.*(?<AppVersion>(\d+(\.\d+){0,3}))$" }).Replace("Version:", "").Trim()
    "URI" = (($winget | Where-Object { $PSItem -match "^.*(Download|Installer) Url\:.*$" }) -replace "(Download|Installer) Url:", "").Trim()
  }
  return $PSObject    
}