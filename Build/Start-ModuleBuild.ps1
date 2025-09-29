param(
  [version]$global:Version = "0.7.4"
)
#Requires -Module ModuleBuilder
$privateFolder = Join-Path -Path $PSScriptRoot -ChildPath Source  -AdditionalChildPath "Private"
$publicFolder = Join-Path -Path $PSScriptRoot -ChildPath Source -AdditionalChildPath "Public"
# Remove Folders if Exist
Remove-Item -Path $privateFolder -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
Remove-Item -Path $publicFolder -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
# Create Folders
New-Item -Path $privateFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
New-Item -Path $publicFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
# Parent Folder
$parentFolder = (get-item $PSScriptRoot).Parent
# Sub Folders without build and Module
$folders = Get-ChildItem -Path $parentFolder -Directory | Where-Object {$_.Name -in ('cmdlets')}
# Copy Private Cmdlets
foreach($folder in $folders){
  $files = Get-ChildItem -Path "$($folder)\private" -Recurse -Filter "*.ps1"
  foreach($file in $files){
    Copy-Item -Path $file -Destination $privateFolder
  }  
}
# Copy Public Cmdlets
foreach($folder in $folders){
  $files = Get-ChildItem -Path "$($folder)\public" -Recurse -Filter "*.ps1"
  foreach($file in $files){
    Copy-Item -Path $file -Destination $publicFolder
  }  
}
# Output Directory
$moduleDir = Join-Path -Path $parentFolder -ChildPath Module
$params = @{
  SourcePath = "$PSScriptRoot\Source\UGDSB.ApplicationFactory.psd1"
  Version = $global:Version
  CopyPaths = @("$PSScriptRoot\Source\UGDSB.ApplicationFactory.nuspec")
  OutputDirectory = $moduleDir 
  UnversionedOutputDirectory = $true
}
Build-Module @params
$foldersToCopy = @("SupportFiles","Templates")
foreach($folder in $foldersToCopy){
  $folderPath = Join-Path -Path $parentFolder -ChildPath $folder
  Copy-Item -Path $folderPath -Destination "$($moduleDir)\UGDSB.ApplicationFactory" -Recurse -Force
}
$updatePath = "C:\Program Files\PowerShell\Modules\UGDSB.ApplicationFactory\$($Version)\"
if(Test-Path $updatePath){
  Copy-Item -Path "C:\DevOps\UGDSB.ApplicationFactory\Module\UGDSB.ApplicationFactory\*" -Destination $updatePath -Force -Recurse
}