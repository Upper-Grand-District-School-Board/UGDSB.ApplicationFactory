<#
  .DESCRIPTION
  This cmdlet is designed to interact with the evergreen powershell module to find the installers for evergreen based installers
  .PARAMETER application
  The application object that we are working for so that we can ensure that get the correct and current data
  .PARAMETER LogLevel
  If logging is enabled, what level of logging do we want, default is verbose.
#>
function Get-AppFactoryEvergreenAppItem{
  [CmdletBinding()]
  [OutputType([PSCustomObject])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter()][ValidateSet("Output","Verbose")][string]$LogLevel = "Verbose"    
  )
  if($script:AppFactoryLogging){
    Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Looking for Evergreen Application with AppID: <c='green'>$($application.SourceFiles.AppID)</c>"  -Level $LogLevel -Tag "Application","$($application.Information.DisplayName)","Evergreen" -Target "Application Factory Service" 
  }

  # Construct array list to build the dynamic filter list
  $FilterList = [System.Collections.Generic.List[PSCustomObject]]@()
  # Process known filter properties and add them to array list if present on current object
  if ($Application.SourceFiles.FilterOptions.Architecture) {
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Architecture Filter: <c='green'>$($Application.SourceFiles.FilterOptions.Architecture)</c>" -Level $LogLevel -Tag "Application","$($application.Information.DisplayName)","Evergreen" -Target "Application Factory Service"
    }
    $FilterList.Add("`$PSItem.Architecture -eq ""$($Application.SourceFiles.FilterOptions.Architecture)""") | Out-Null
  }
  if ($Application.SourceFiles.FilterOptions.Platform) {
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Platform Filter: <c='green'>$($Application.SourceFiles.FilterOptions.Platform)</c>" -Level $LogLevel -Tag "Application","$($application.Information.DisplayName)","Evergreen" -Target "Application Factory Service"
    }
    $FilterList.Add("`$PSItem.Platform -eq ""$($Application.SourceFiles.FilterOptions.Platform)""") | Out-Null
  }
  if ($Application.SourceFiles.FilterOptions.Channel) {
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Channel Filter: <c='green'>$($Application.SourceFiles.FilterOptions.Channel)</c>" -Level $LogLevel -Tag "Application","$($application.Information.DisplayName)","Evergreen" -Target "Application Factory Service"
    }
    $FilterList.Add("`$PSItem.Channel -eq ""$($Application.SourceFiles.FilterOptions.Channel)""") | Out-Null
  }
  if ($Application.SourceFiles.FilterOptions.Type) {
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Type Filter: <c='green'>$($Application.SourceFiles.FilterOptions.Type)</c>" -Level $LogLevel -Tag "Application","$($application.Information.DisplayName)","Evergreen" -Target "Application Factory Service"
    }
    $FilterList.Add("`$PSItem.Type -eq ""$($Application.SourceFiles.FilterOptions.Type)""") | Out-Null
  }
  if ($Application.SourceFiles.FilterOptions.InstallerType) {
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] InstallerType Filter: <c='green'>$($Application.SourceFiles.FilterOptions.InstallerType)</c>" -Level $LogLevel -Tag "Application","$($application.Information.DisplayName)","Evergreen" -Target "Application Factory Service"
    }
    $FilterList.Add("`$PSItem.InstallerType -eq ""$($Application.SourceFiles.FilterOptions.InstallerType)""") | Out-Null
  }
  if ($Application.SourceFiles.FilterOptions.Release) {
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Release Filter: <c='green'>$($Application.SourceFiles.FilterOptions.Release)</c>" -Level $LogLevel -Tag "Application","$($application.Information.DisplayName)","Evergreen" -Target "Application Factory Service"
    }
    $FilterList.Add("`$PSItem.Release -eq ""$($Application.SourceFiles.FilterOptions.Release)""") | Out-Null
  }  
  if ($Application.SourceFiles.FilterOptions.Language) {
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Language Filter: <c='green'>$($Application.SourceFiles.FilterOptions.Language)</c>" -Level $LogLevel -Tag "Application","$($application.Information.DisplayName)","Evergreen" -Target "Application Factory Service"
    }
    $FilterList.Add("`$PSItem.Language -eq ""$($Application.SourceFiles.FilterOptions.Language)""") | Out-Null
  }    
  if ($Application.SourceFiles.FilterOptions.ImageType) {
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] ImageType Filter: <c='green'>$($Application.SourceFiles.FilterOptions.ImageType)</c>" -Level $LogLevel -Tag "Application","$($application.Information.DisplayName)","Evergreen" -Target "Application Factory Service"
    }
    $FilterList.Add("`$PSItem.ImageType -eq ""$($Application.SourceFiles.FilterOptions.ImageType)""") | Out-Null
  } 
  # Construct script block from filter list array
  $FilterExpression = [scriptblock]::Create(($FilterList -join " -and ")) 
  # Get the evergreen app based on dynamic filter list
  if($FilterList.Count -gt 0){
    $EvergreenApp = Get-EvergreenApp -Name $application.SourceFiles.AppID | Where-Object -FilterScript $FilterExpression | Sort-Object Version -Descending | Select-Object -first 1
  }
  else{
    $EvergreenApp = Get-EvergreenApp -Name $application.SourceFiles.AppID | Sort-Object Version -Descending | Select-Object -first 1
  }
  # Only return the top item
  $PSObject = [PSCustomObject]@{
    "Version" = $EvergreenApp.version
    "URI" = $EvergreenApp.URI
  }
  return $PSObject
}