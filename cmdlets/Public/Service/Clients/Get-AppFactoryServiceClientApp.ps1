function Get-AppFactoryServiceClientApp{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$orgGUID,
    [Parameter()][ValidateNotNullOrEmpty()][string]$appGUID,
    [Parameter()][switch]$AddToIntune,
    [Parameter()][ValidateSet("Output","Verbose")][string]$LogLevel = "Verbose"
  )
  # Blank List for the Apps
  $applicaitonList =  [System.Collections.Generic.List[PSCustomObject]]@()
  # Where are custom configs stored
  $ClientConfigFolderPath = Join-Path -Path $script:AppFactoryClientConfigDir -ChildPath "$($orgGUID)"
  # Public application list
  $publicApps = Get-AppFactoryApp -active -public -LogLevel $LogLevel
  # Client specific application list
  $clientApps = Get-AppFactoryApp -active -publishTo $orgGUID -LogLevel $LogLevel
  # Loop through each public app
  foreach($app in $publicApps){
    $customConfigPath = Join-Path -Path $ClientConfigFolderPath -ChildPath "$($app.GUID).json"
    $customConfig = $null
    if(Test-Path -Path $customConfigPath){
      $customConfig = Get-Content -Path $customConfigPath | ConvertFrom-Json -Depth 5
    }
    $AppConfig = Get-ClientAppConfig -application $app -customConfig $customConfig -audience "Public" -LogLevel $LogLevel
    if($AddToIntune.IsPresent -and -not $AppConfig.AddToIntune){
      continue      
    }  
    $applicaitonList.Add($AppConfig)
  }
  foreach($app in $clientApps){
    $customConfigPath = Join-Path -Path $ClientConfigFolderPath -ChildPath "$($app.GUID).json"
    $customConfig = $null
    if(Test-Path -Path $customConfigPath){
      $customConfig = Get-Content -Path $customConfigPath | ConvertFrom-Json -Depth 5
    }
    $AppConfig = Get-ClientAppConfig -application $app -customConfig $customConfig -audience $orgGUID -LogLevel $LogLevel
    if($AddToIntune.IsPresent -and -not $AppConfig.AddToIntune){
      continue      
    }
    $applicaitonList.Add($AppConfig)
  }  
  return $applicaitonList 
}