function Get-AppFactoryClientApp{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter()][string]$GUID,
    [Parameter()][string]$AppName,
    [Parameter()][bool]$AddToIntune,
    [Parameter()][string]$AvailableAssignments,
    [Parameter()][string]$AvailableExceptions,
    [Parameter()][string]$RequiredAssignments,
    [Parameter()][string]$RequiredExceptions,
    [Parameter()][string]$UninstallAssignments,
    [Parameter()][string]$UninstallExceptions,
    [Parameter()][ValidateSet("Output","Verbose")][string]$LogLevel = "Verbose"
  )
  # App Folders
  $applicationFolderPath = Join-Path -Path $script:AppFactoryClientSourceDir -ChildPath "Apps"
  # Get All Applications
  $applicationConfigFiles = Get-Childitem -Path $applicationFolderPath
  # Blank List for the Apps
  $applicationList =  [System.Collections.Generic.List[PSCustomObject]]@()
  # Loop through the configuration and add to the list.
  foreach($file in $applicationConfigFiles){
    $json = Get-Content $file.FullName | ConvertFrom-Json
    $skip = $false
    foreach($param in ($PSBoundParameters.GetEnumerator() | Where-Object {$_.Key -ne "LogLevel"})){
      if($json.$($param.Key).getType().BaseType.Name -eq "Array"){
        if($param.Value -notin $json.$($param.Key) ){$skip = $true; break}
      }
      else{
        if($param.Value -ne $json.$($param.Key)){$skip = $true; break}
      }
    }
    if(-not $skip){
      $applicationList.Add($json) | Out-Null
    }
  } 
  return $applicationList   
}