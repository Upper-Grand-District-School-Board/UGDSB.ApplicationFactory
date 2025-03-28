function Get-ClientAppConfig{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter(Mandatory = $true)][PSCustomObject]$application,
    [Parameter()][PSCustomObject]$customConfig,
    [Parameter()][string]$audience = "Public",
    [Parameter()][ValidateSet("Output","Verbose")][string]$LogLevel = "Verbose"
  )
  if($audience -eq "Public"){
    $AppAudience = "Public"
  }
  else{
    $AppAudience = "Private"
  }
  # Defaults for each application
  $defaultConfig = [PSCustomObject]@{
    "AddToIntune"             = $false
    "AvailableAssignments"    = @()
    "AvailableExceptions"     = @()
    "RequiredAssignments"     = @()
    "RequiredExceptions"      = @()
    "UninstallAssignments"    = @()
    "UninstallExceptions"     = @()
    "UnassignPrevious"        = $false
    "CopyPrevious"            = $false
    "KeepPrevious"            = 0
    "foreground"              = $false
    "filters"                 = @{}
    "espprofiles"             = @()
    "container"               = $AppAudience
    "GUID"                    = $application.GUID
    "IntuneAppName"           = $application.Information.DisplayName
    "AppVersion"              = $null
    "InteractiveInstall"      = $false
    "InteractiveUninstall"    = $false
  }
  if($null -ne $customConfig){
    $customConfig.PSObject.Properties | ForEach-Object {
      $defaultConfig.$($_.Name) = $_.Value
    }
  }
  if($null -eq $defaultConfig.AppVersion){
    $temp = ($script:PublishedAppList.$audience | Where-Object {$_.Name -like "$($application.GUID)/*/App.json"}).Name
    $AppVersions = ([regex]::Matches($temp,"/(.*?)/App.json")).Groups.Value | Where-Object {$_ -notlike "*App.json"}
    $defaultConfig.AppVersion = $AppVersions | Sort-Object -Descending | Select-Object -First 1
  }
  return $defaultConfig
}
