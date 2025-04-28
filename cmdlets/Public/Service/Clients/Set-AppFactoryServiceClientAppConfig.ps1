function Set-AppFactoryServiceClientAppConfig{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$orgGUID,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$appGUID,
    [Parameter()][bool]$AddToIntune,
    [Parameter()][string[]]$AvailableAssignments,
    [Parameter()][string[]]$AvailableExceptions,
    [Parameter()][string[]]$RequiredAssignments,
    [Parameter()][string[]]$RequiredExceptions,
    [Parameter()][string[]]$UninstallAssignments,
    [Parameter()][string[]]$UninstallExceptions,
    [Parameter()][bool]$UnassignPrevious,
    [Parameter()][bool]$CopyPrevious,
    [Parameter()][int]$KeepPrevious,
    [Parameter()][bool]$foreground,
    [Parameter()][PSCustomObject]$filters,
    [Parameter()][string[]]$espprofiles,
    [Parameter()][bool]$InteractiveInstall,
    [Parameter()][bool]$InteractiveUninstall,
    [Parameter()][String]$AppVersion,
    [Parameter()][ValidateSet("Output","Verbose")][string]$LogLevel = "Verbose"
  )
  $currentConfig = Get-AppFactoryServiceClientAppConfig -orgGUID $orgGUID -appGUID $appGUID -LogLevel $LogLevel
  if(-not $currentConfig){$currentConfig = [PSCustomObject]@{}}
  foreach($item in $PSBoundParameters.GetEnumerator()){
    if($item.key -in ("orgGUID","appGUID","LogLevel")){continue}
    #$itemType = $item.Value.GetType().Name
    $action = $null
    if($item.key -in $currentConfig.psobject.properties.Name){
      $Action = "Update"
      switch -regex ($item.Value.GetType().Name){
        "Boolean" {
          if(-not  [System.Convert]::ToBoolean($item.Value)){
            $action = "Remove"
          }
        }
        "String|String\[\]|PSCustomObject" {
          if([String]::IsNullOrWhiteSpace($item.value) -or $item.value -eq "0.0"){
            $Action = "Remove"
          }
        }
        "Int32" {
          if($item.value -eq 0){
            $Action = "Remove"
          }
        }
        default {
          $Action = "Unknown"
        }
      }
    }
    else{
      switch -regex ($item.Value.GetType().Name){
        "Boolean" {
          if([System.Convert]::ToBoolean($item.Value)){
            $action = "Add"
          }
        }
        "String|String\[\]|PSCustomObject" {
          if(-not ([String]::IsNullOrWhiteSpace($item.value)) -and $item.value -ne "0.0"){
            $Action = "Add"
          }
        }
        "Int32" {
          if($item.value -ne 0){
            $Action = "Add"
          }
        }
      }
    }
    switch($Action){
      "Add"{ 
        $currentConfig | Add-Member -MemberType NoteProperty -Name $item.Key -Value $item.Value -Force
      }
      "Remove"{ 
        $currentConfig.PSObject.Properties.Remove($item.Key)
      }
      "Update"{ 
        $currentConfig.$($item.Key) = $item.Value
      }

    }
  }
  $ClientConfigFolderPath = Join-Path -Path $script:AppFactoryClientConfigDir -ChildPath "$($orgGUID)"
  $ClientAppConfig = Join-Path -Path $ClientConfigFolderPath -ChildPath "$($appGUID).json"
  if(-not (Test-Path $ClientConfigFolderPath)){
    New-Item -Path $ClientConfigFolderPath -ItemType Directory -Force | Out-Null
  }
  $currentConfig | ConvertTo-JSON | Out-File -Path $ClientAppConfig -Force  
}
