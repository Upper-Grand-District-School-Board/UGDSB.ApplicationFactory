function Import-PreviousVersion {
  [cmdletbinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$AppDetailsPath
  )
  $test = $false
  $ApplicationData = Get-Content -Path $AppDetailsPath | ConvertFrom-JSON -Depth 10
  #region Application Data
  $App = @{
    displayName    = ($ApplicationData.AppData.IntuneAppName -replace "STS-")
    publisher      = $ApplicationData.AppData.AppPublisher
    description    = $ApplicationData.AppConfig.Information.description
    owner          = "ECNO"
    AppSource      = $ApplicationData.AppData.AppSource
    informationURL = $ApplicationData.AppData.informationURL
    PrivacyURL     = $ApplicationData.AppData.PrivacyURL
    publishTo      = $ApplicationData.AppData.publishTo    
  }
  switch ($ApplicationData.AppData.AppSource) {
    "Evergreen" {
      $App.Add("appID", $ApplicationData.AppData.appID)
      $App.Add("appSetupName", $ApplicationData.AppData.AppSetupFileName)
      $App.Add("filterOptions", $ApplicationData.AppData.filterOptions)
    }    
    "StorageAccount" {
      $App.Add("StorageAccountContainerName", $ApplicationData.AppData.StorageAccountContainerName)
      $App.Add("appSetupName", $ApplicationData.AppData.AppSetupFileName)
    }    
    "ECNO" {
      $App.Add("StorageAccountContainerName", $ApplicationData.AppData.StorageAccountContainerName)
    }
    "Winget" {
      $App.Add("appID", $ApplicationData.AppData.appID)
      $App.Add("appSetupName", $ApplicationData.AppData.AppSetupFileName)        
    }
  }
if(-not $test){
  $application = New-AppFactoryApp @App
}
else{
  "#################### APP ########################"
  $App
}  
  #endregion
  #region Install Data
  $install = @{
    type    = $ApplicationData.Install.type
    appGUID = $application.GUID
  }
  foreach ($member in ($ApplicationData.Install  | get-member | where-object { $_.MemberType -eq "NoteProperty" })) {
    switch ($member.Name) {
      "afterstopProcess" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.Install.afterstopProcess)){
          $install.Add("conflictingProcessEnd", $ApplicationData.Install.afterstopProcess)
        }
      }
      "beginstopProcess" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.Install.beginstopProcess)){
          $install.Add("conflictingProcessStart", $ApplicationData.Install.beginstopProcess)
        }
      }
      "ignoreExit" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.Install.ignoreExit)){
          $install.Add("ignoreExitCodes", $ApplicationData.Install.ignoreExit)
        }
      }
      "installer" {
        if((-not ([String]::IsNullOrWhiteSpace($ApplicationData.Install.installer)) -and $ApplicationData.Install.installer -ne "###SETUPFILENAME###")){
          $install.Add("installer", $ApplicationData.Install.installer)
        }
      }
      "mst" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.Install.mst)){
          $install.Add("transforms", $ApplicationData.Install.mst)
        }
      }
      "Parameters" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.Install.Parameters)){
          if ($ApplicationData.Install.type -eq "MSI") {
            $install.Add("additionalArgumentList", $ApplicationData.Install.Parameters)
          }
          else{
            $install.Add("argumentList", $ApplicationData.Install.Parameters)
          }
        }
      }
      "script" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.Install.script)){
          $install.type = "Script"
          $install.Add("script", $ApplicationData.Install.script)
        }
      }
      "WIM" {
        if([bool]$ApplicationData.Install.WIM){
          $Install.Add("WIM", $true)
        }
      }                 
    }
  }
if(-not $test){    
  Set-AppFactoryAppInstall @Install
}
else{
  "#################### INSTALL ########################"
  $ApplicationData.Install  | get-member | where-object { $_.MemberType -eq "NoteProperty" } | format-table
  $Install
}
  #endregion
  #region Uninstall Data
  $uninstall = @{
    type    = $ApplicationData.uninstall.type
    appGUID = $application.GUID
  }
  foreach ($member in ($ApplicationData.unInstall  | get-member | where-object { $_.MemberType -eq "NoteProperty" })) {
    switch ($member.Name) {
      "afterstopProcess" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.unInstall.afterstopProcess)){
          $unInstall.Add("conflictingProcessEnd", $ApplicationData.unInstall.afterstopProcess)
        }
      }
      "beginstopProcess" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.unInstall.beginstopProcess)){
          $unInstall.Add("conflictingProcessStart", $ApplicationData.unInstall.beginstopProcess)
        }
      }
      "DirFiles" {
        if([bool]$ApplicationData.unInstall.DirFiles){
          $unInstall.Add("DirFiles", $true)
        }
      }
      "ignoreExit" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.unInstall.ignoreExit)){
          $unInstall.Add("ignoreExitCodes", $ApplicationData.unInstall.ignoreExit)
        }
      }
      "installer" {
        if(-not ([String]::IsNullOrWhiteSpace($ApplicationData.unInstall.installer) -and $ApplicationData.unInstall.installer -ne "###SETUPFILENAME###")){
          $unInstall.Add("installer", $ApplicationData.unInstall.installer)
        }
      }
      "MSIGUID" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.unInstall.MSIGUID)){
          $unInstall.Add("productCode", $ApplicationData.unInstall.MSIGUID)
        }
      }
      "Name" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.unInstall.Name)){
          $unInstall.Add("Name", $ApplicationData.unInstall.Name)
        }
      }
      "Parameters" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.unInstall.Parameters)){
          if ($ApplicationData.unInstall.type -eq "MSI") {
            $unInstall.Add("additionalArgumentList", $ApplicationData.unInstall.Parameters)
          }
          else{
            $unInstall.Add("argumentList", $ApplicationData.unInstall.Parameters)
          }
        }
      } 
      "script" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.unInstall.script)){
          $unInstall.type = "Script"
          $unInstall.Add("script", $ApplicationData.unInstall.script)
        }
      }
      "WIM" {
        if([bool]$ApplicationData.unInstall.WIM){
          $unInstall.Add("WIM", $true)
        }
      }                      
    }
  }
if(-not $test){  
  Set-AppFactoryAppUninstall @Uninstall
}
else{
  "#################### UNINSTALL ########################"
  $ApplicationData.unInstall  | get-member | where-object { $_.MemberType -eq "NoteProperty" } | format-table
  $Uninstall
}
  #endregion
  #region Detection Data
  $detection = @{
    type    = $ApplicationData.AppConfig.DetectionRule.type
    appGUID = $application.GUID
  } 
  foreach ($member in ($ApplicationData.AppConfig.DetectionRule  | get-member | where-object { $_.MemberType -eq "NoteProperty" })) {
    switch ($member.Name) {
      "Name" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.AppConfig.DetectionRule.Check32BitOn64System)){
          $detection.Add("Check32BitOn64System", $ApplicationData.AppConfig.DetectionRule.Check32BitOn64System)
        }
      }
      "DetectionMethod" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.AppConfig.DetectionRule.DetectionMethod)){
          $detection.Add("DetectionMethod", $ApplicationData.AppConfig.DetectionRule.DetectionMethod)
        }
      }
      "KeyPath" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.AppConfig.DetectionRule.KeyPath)){
          $detection.Add("KeyPath", $ApplicationData.AppConfig.DetectionRule.KeyPath)
        }
      }
      "Operator" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.AppConfig.DetectionRule.Operator)){
          $detection.Add("Operator", $ApplicationData.AppConfig.DetectionRule.Operator)
        }
      }
      "ValueName" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.AppConfig.DetectionRule.ValueName)){
          $detection.Add("ValueName", $ApplicationData.AppConfig.DetectionRule.ValueName)
        }
      }
      "ProductVersionOperator" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.AppConfig.DetectionRule.ProductVersionOperator)){
          $detection.Add("ProductVersionOperator", $ApplicationData.AppConfig.DetectionRule.ProductVersionOperator)
        }
      }
      "DetectionType" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.AppConfig.DetectionRule.DetectionType)){
          $detection.Add("DetectionType", $ApplicationData.AppConfig.DetectionRule.DetectionType)
        }
      }
      "RunAs32Bit" {
        if([System.Convert]::ToBoolean($ApplicationData.AppConfig.DetectionRule.RunAs32Bit)){
          $detection.Add("RunAs32Bit", $true)
        }
      }
      "ScriptFile" {
        if(-not [String]::IsNullOrWhiteSpace($ApplicationData.AppConfig.DetectionRule.ScriptFile)){
          $detection.Add("ScriptFile", $ApplicationData.AppConfig.DetectionRule.ScriptFile)
        }
      }
    }
  }
if(-not $test){  
  Set-AppFactoryAppDetectionRule @detection
}
else{
  "##################### DETECTION ######################"
  $ApplicationData.AppConfig.DetectionRule  | get-member | where-object { $_.MemberType -eq "NoteProperty" } | format-table
  $detection  
}
  #endregion
  #region FInal Steps to Import file

if(-not $test){
  $appFolderPath = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath $App.displayName
  $IconPath = Join-Path -Path $appFolderPath -ChildPath "Icon.png"
  Remove-Item -path $IconPath -Force
  $ImportFrom = ((Get-Item $AppDetailsPath).Directory).FullName
  Copy-Item -Path "$($ImportFrom)\Icon.png" -Destination $appFolderPath -Force -ErrorAction SilentlyContinue
  Copy-Item -Path "$($ImportFrom)\Detection.ps1" -Destination $appFolderPath -Force -ErrorAction SilentlyContinue
  $temp = Get-Content -Path "$($appFolderPath)\ApplicationConfig.json" | ConvertFrom-Json -Depth 10
  $temp.GUID = $ApplicationData.AppData.GUID
  $temp | ConvertTo-Json -Depth 10 | Set-Content -Path "$($appFolderPath)\ApplicationConfig.json" -Force
}

  #endregion  
}
#  [String]::IsNullOrWhiteSpace
<#
#>

<#

#>