function Get-AppFactoryPSUApplications {
  [cmdletbinding()]
  param()
  New-UDElement -Tag "figure" -ClassName "text-center" -Content {
    New-UDElement -Tag "h4" -ClassName "display-4" -Content { "Application Factory Applications" }
  }  
  New-UDElement -Tag "div" -ClassName "container-fluid" -Content {
    New-UDElement -Tag "div" -ClassName "row justify-content-start" -Content {
      New-UDElement -Tag "div" -ClassName "col-5" -Content {
        New-UDElement -Tag "div" -ClassName "card-body rounded" -Content {
          New-UDTypography -Text "Application List" -Variant "h5" -ClassName "card-title rounded x-card-title"
          New-UDElement -Tag "div" -id "ApplicationList" -Content {
            Initialize-AppFactoryProcess -ApplicationServicePath $AppFactory_ApplicationPath
            New-UDDataGrid -id "ApplicationListTableData" -LoadRows {
              Initialize-AppFactoryProcess -ApplicationServicePath $AppFactory_ApplicationPath
              $ClientList = Get-AppFactoryServiceClient
              $TableData = Get-AppFactoryApp | Select-Object -Property @{Label = "ID"; expression = { $_.GUID } }, @{Label = "Name"; expression = { $_.Information.DisplayName } }, @{Label = "Availability"; expression = { 
                  if ($_.SourceFiles.publishTo.count -eq 0) {
                    "All"
                  }
                  else {
                    $orgList = [System.Collections.Generic.List[String]]::new()
                    foreach ($obj in $_.SourceFiles.publishTo) {
                      $orgList.Add(($ClientList | Where-Object { $_.GUID -eq $obj }).Name) | Out-Null
                    }
                    $orgList -join ", "
                  }
                }
              }, @{Label = "Active"; expression = { $_.SourceFiles.Active } }, @{Label = "Source"; expression = { $_.SourceFiles.AppSource } }, @{Label = "Updated"; expression = { (Get-Date -Date $_.SourceFiles.LastUpdate).ToString("yyyy/MM/dd HH:mm:ss") } }, Information, SourceFiles, Install, Uninstall, RequirementRule, DetectionRule
              $TableData | Out-UDDataGridData -Context $EventData -TotalRows $Rows.Length
            } -Columns @(
              New-UDDataGridColumn -Field Name -Flex 1.5 -Render {
                $EventData.Name
                New-UDElement -tag "div" -content {} -Attributes @{style = @{width = "10px"}}
                if($null -ne $EventData.Information.InformationURL -and $EventData.Information.InformationURL -ne "") {
                  New-UDLink -Url $EventData.Information.InformationURL -OpenInNewWindow -Content {
                    New-UDImage -URL "/assets/images/information.png" -Attributes @{
                      alt = "$($EventData.Information.InformationURL)"
                      style = @{
                        width = "20px"
                        height = "20px"
                      }
                    }
                  }
                }
                New-UDElement -tag "div" -content {} -Attributes @{style = @{width = "10px"}}
                if($null -ne $EventData.Information.PrivacyURL -and $EventData.Information.PrivacyURL -ne "") {
                  New-UDLink -Url $EventData.Information.PrivacyURL -OpenInNewWindow -Content {
                    New-UDImage -URL "/assets/images/privacy.png" -Attributes @{
                      alt = "$($EventData.Information.PrivacyURL)"
                      style = @{
                        width = "20px"
                        height = "20px"
                      }
                    }
                  }
                }
              }
              New-UDDataGridColumn -Field Availability -Flex 2.0
              New-UDDataGridColumn -Field Active -Flex 1.0
              New-UDDataGridColumn -Field Updated -Flex 1.0
              New-UDDataGridColumn -Field Source -Flex 0 -DisableColumnMenu -Render {} -DisableExport -DisableReorder -Hide
              New-UDDataGridColumn -Field Information -Flex 0 -DisableColumnMenu -Render {} -DisableExport -DisableReorder -Hide
              New-UDDataGridColumn -Field SourceFiles -Flex 0 -DisableColumnMenu -Render {} -DisableExport -DisableReorder -Hide
              New-UDDataGridColumn -Field Install -Flex 0 -DisableColumnMenu -Render {} -DisableExport -DisableReorder -Hide
              New-UDDataGridColumn -Field Uninstall -Flex 0 -DisableColumnMenu -Render {} -DisableExport -DisableReorder -Hide
              New-UDDataGridColumn -Field RequirementRule -Flex 0 -DisableColumnMenu -Render {} -DisableExport -DisableReorder -Hide
              New-UDDataGridColumn -Field DetectionRule -Flex 0 -DisableColumnMenu -Render {} -DisableExport -DisableReorder -Hide
            ) -StripedRows -AutoHeight $true -PageSize 10 -RowsPerPageOptions @(10,25,50,100,1000) -ShowPagination -DefaultSortColumn Name -OnSelectionChange {
              Import-Module -Name $AppFactory_Module -Force
              $TableData = Get-UDElement -Id "ApplicationListTableData"
              $selectedRow = ((Get-UDElement -Id "ApplicationListTableData").selection)[0]
              $selectedRowData = $TableData.Data.Rows | Where-Object { $_.ID -eq $selectedRow } 
              $AppVersions = Get-AppFactoryServiceAppVersions -appGUID $selectedRow -AllAppList $script:PublishedAppList 
              # Standard Text Based Elements to Set
              $setTextElements = @(
                @{
                  id          = "ApplicationGUID"
                  value       = $selectedRow
                  type        = "text"
                  placeholder = ""
                },
                @{
                  id          = "ApplicationName"
                  value       = $selectedRowData.Information.DisplayName
                  type        = "text"
                  placeholder = "Application Name"
                },
                @{
                  id          = "Publisher"
                  value       = $selectedRowData.Information.Publisher
                  type        = "text"
                  placeholder = "Publisher Name"                  
                },
                @{
                  id          = "PrivacyURL"
                  value       = $selectedRowData.Information.PrivacyURL
                  type        = "text"
                  placeholder = "Information URL"                  
                },
                @{
                  id          = "InformationURL"
                  value       = $selectedRowData.Information.InformationURL
                  type        = "text"
                  placeholder = "Privacy URL"                  
                },
                @{
                  id          = "Owner"
                  value       = $selectedRowData.Information.Owner
                  type        = "text"
                  placeholder = "Owner Name"                  
                }
              )
              foreach ($item in $setTextElements) {
                Set-UDElement -id $item.id -Properties @{
                  value = $item.value
                }                 
              }
              if ($selectedRowData.Availability -ne "All") {
                $ClientListValue = $selectedRowData.Availability -split ", "
              }
              else {
                $ClientListValue = ""
              }
              # Standard Select Based Elements to Set
              $setSelectElements = @(
                @{
                  id    = "Client"
                  value = $ClientListValue
                },
                @{
                  id    = "Architecture"
                  Value = $selectedRowData.RequirementRule.Architecture
                },
                @{
                  id    = "MinimumSupportedWindowsRelease"
                  Value = $selectedRowData.RequirementRule.MinimumSupportedWindowsRelease
                },
                @{
                  id    = "Source"
                  Value = $selectedRowData.SourceFiles.AppSource
                },
                @{
                  id    = "Install"
                  Value = $selectedRowData.Install.type
                },
                @{
                  id    = "Uninstall"
                  Value = $selectedRowData.Uninstall.type
                }
              )
              foreach ($item in $setSelectElements) {
                Set-UDElement -id $item.id -Properties @{
                  Value = $item.Value
                }
              }
              # Start Text Box Based Elements to Set
              $setTextboxElements = @(
                @{
                  id    = "Description"
                  value = $selectedRowData.Information.Description
                },
                @{
                  id    = "Notes"
                  value = $selectedRowData.Information.Notes
                }                
              )
              foreach ($item in $setTextboxElements) {
                Set-UDElement -id $item.id -Properties @{
                  Value = $item.Value
                }
              }  
              # Start Switch Based Elements to Set            
              $setSwitchElements = @(
                @{
                  id      = "Active"
                  Checked = $selectedRowData.SourceFiles.Active
                },
                @{
                  id      = "pauseUpdate"
                  Checked = $selectedRowData.SourceFiles.pauseUpdate
                }
              )
              foreach ($item in $setSwitchElements) {
                Set-UDElement -id $item.id -Properties @{
                  Checked = $item.Checked
                }
              }
              # Available versions based on application
              Set-UDElement -id "AvailableVersions" -Properties @{
                Options = @(
                  foreach ($version in ($AppVersions | Sort-Object -Descending)) {
                    New-UDSelectOption -Name $version -Value $version 
                  }
                )
              }
              # Detection drop down
              Set-UDElement -Id "DetectionSelectionFields" -Content {}
              Set-UDElement -Id "DetectionSelectionFields" -Content {              
                switch ($selectedRowData.DetectionRule.Type) {
                  "MSI" {
                    Set-UDElement -id "Detection" -Properties @{
                      Value = "MSI"
                    }  
                    New-PSUGUIDetectionMSI -SourceData $selectedRowData.DetectionRule                
                  }
                  "Registry" {
                    if ($selectedRowData.DetectionRule.DetectionMethod -eq "VersionComparison") {
                      Set-UDElement -id "Detection" -Properties @{
                        Value = "Registry Version"
                      }              
                      New-PSUGUIDetectionRegistryVersion -SourceData $selectedRowData.DetectionRule                      
                    }
                    else {
                      Set-UDElement -id "Detection" -Properties @{
                        Value = "Registry Existance"
                      }       
                      New-PSUGUIDetectionRegistryExistance -SourceData $selectedRowData.DetectionRule                             
                    }
                  } 
                  "Script" {
                    Set-UDElement -id "Detection" -Properties @{
                      Value = "Script"
                    }  
                    $scriptPath = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath $selectedRowData.information.appFolderName, "Detection.ps1" -ErrorAction SilentlyContinue
                    New-PSUGUIDetectionScript -SourceData $selectedRowData.DetectionRule -scriptPath $scriptPath                               
                  }
                }
              }
              # Set Icon FIle
              $ApplicationPath = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath $selectedRowData.Information.AppFolderName
              $AppIconFile = Join-Path -Path $ApplicationPath -ChildPath "Icon.png"
              Set-UDElement -Id "imgdiv" -Content {}
              Set-UDElement -Id "imgdiv" -Content {
                New-UDImage -Id "appimage" -Path "$($AppIconFile)" -Width 50 -Height 50
              }
              # Set Source Files
              Set-UDElement -Id "SourceSelectionFields" -Content {}
              Set-UDElement -Id "SourceSelectionFields" -Content {
                switch ($selectedRowData.sourceFiles.appSource) {
                  "StorageAccount" {
                    New-PSUGUISourceStorageAccount -SourceData $selectedRowData.sourcefiles
                  }
                  "Sharepoint" {
                    New-PSUGUISourceSharepoint -SourceData $selectedRowData.sourcefiles
                  }
                  "Winget" {
                    New-PSUGUISourceWinget -SourceData $selectedRowData.sourcefiles
                  }
                  "LocalStorage" {
                    New-PSUGUISourceStorageAccount -SourceData $selectedRowData.sourcefiles
                  }
                  "ECNO" {
                    New-PSUGUISourceECNO -SourceData  $selectedRowData.sourcefiles
                  }
                  "Evergreen" {
                    New-PSUGUISourceEvergreen -SourceData  $selectedRowData.sourcefiles
                  }
                  "PSADT" {
                    New-PSUGUISourcePSADT -SourceData  $selectedRowData.Information
                  }
                  "StorageAccount - PowerShell Script" {
                    New-PSUGUISourceStorageAccountScript -SourceData  $selectedRowData.Information
                  }                  
                }
              }
              # Set Install Data
              Set-UDElement -Id "InstallSelectionFields" -Content {}
              Set-UDElement -Id "InstallSelectionFields" -Content {
                switch ($selectedRowData.Install.type) {
                  "Script" {
                    New-PSUGUIInstallScript -SourceData $selectedRowData.install
                  }
                  "EXE" {
                    New-PSUGUIInstallEXE -SourceData $selectedRowData.install
                  }
                  "MSI" {
                    New-PSUGUIInstallMSI -SourceData $selectedRowData.install
                  }
                  "Powershell" {
                    New-PSUGUIInstallPowershell -SourceData  $selectedRowData.install -versiondata $selectedRowData.Information
                  }
                }
              }              
              # Set Uninstall Data
              Set-UDElement -Id "UninstallSelectionFields" -Content {}
              Set-UDElement -Id "UninstallSelectionFields" -Content {
                switch ($selectedRowData.Uninstall.type) {
                  "Script" {
                    New-PSUGUIUnInstallScript -SourceData $selectedRowData.Uninstall
                  }
                  "EXE" {
                    New-PSUGUIUnInstallEXE -SourceData $selectedRowData.Uninstall
                  }
                  "MSI" {
                    New-PSUGUIUnInstallMSI -SourceData $selectedRowData.Uninstall
                  }
                  "Name" {
                    New-PSUGUIUninstallName -SourceData $selectedRowData.Uninstall
                  }
                  "GUID" {
                    New-PSUGUIUninstallGUID -SourceData $selectedRowData.Uninstall
                  }  
                  "Powershell" {
                    New-PSUGUIUninstallPowershell -SourceData  $selectedRowData.uninstall
                  }                
                }
              }               
              Set-UDElement -id "UpdateApplication" -Properties @{
                Disabled = $false
              }
              Set-UDElement -id "DeleteApplication" -Properties @{
                Disabled = $false
              }
              Set-UDElement -id "DeleteVersion" -Properties @{
                Disabled = $true
              }
              Set-UDElement -id "AvailableVersions" -Properties @{
                Value = ""
              }
            }
          }
        }
      }
      New-UDElement -Tag "div" -ClassName "col-1" -Content {}
      New-UDElement -Tag "div" -ClassName "col-6" -Content {
        New-UDElement -Tag "div" -ClassName "card-body rounded" -Content {
          New-UDTypography -Text "Application Details" -Variant "h5" -ClassName "card-title rounded x-card-title"
          New-UDButton -Id "NewApplication" -Text "New Application" -ClassName "btn btn-primary" -OnClick {
            $global:submitApp = $true
            $AppInformation = Get-PSUGUIAppInfo
            $AppInstall = Get-PSUGUIAppInstallInfo
            $AppUninstall = Get-PSUGUIAppUninstallInfo
            $AppDetection = Get-PSUGuiAppDetectionInfo
            if ($global:submitApp) {
              $AppInformation.Add("AppFolderName", $AppInformation.displayName) | Out-Null
              $AppFolder = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath $AppInformation.AppFolderName
              $IconFileData = Get-UDElement -Id "IconFile"
              $IconDesination = Join-Path -Path $AppFolder -ChildPath "Icon.png"
              if ([String]::IsNullOrWhiteSpace($IconFileData.value)) {
                $IconPath = Join-Path -Path $script:AppFactorySupportTemplateFolder -ChildPath "PSADT" -AdditionalChildPath "Assets", "AppIcon.png"
              }
              else {
                $IconPath = "$($env:TEMP)\PSUApp_Icon.png"
              }
              $application = New-AppFactoryApp @AppInformation
              Set-AppFactoryAppInstall -appGUID $application.GUID @AppInstall
              Set-AppFactoryAppUninstall -appGUID $application.GUID @AppUninstall
              Set-AppFactoryAppDetectionRule -appGUID $application.GUID @AppDetection
              if($AppDetection.Type -eq "Script"){
                $ScriptData = (Get-UDElement -Id "Detection_Script").code
                $DetectionPS = Join-Path -Path $AppFolder -ChildPath "Detection.ps1"
                $ScriptData | Out-File -FilePath $DetectionPS -Force
              }
              Copy-Item -Path $IconPath -Destination $IconDesination -Force
              Set-UDElement -id "AppTabs" -Content {New-PSUGUIAppTabs}
              Sync-UDElement -Id 'ApplicationListTableData'              
            }
          }
          New-UDButton -Id "UpdateApplication" -Text "Update Application" -Disabled -ClassName "btn btn-primary" -OnClick {
            Import-Module -Name $AppFactory_Module -Force
            Initialize-AppFactoryProcess -ApplicationServicePath $AppFactory_ApplicationPath            
            $global:submitApp = $true            
            $AppInformation = Get-PSUGUIAppInfo
            $AppInstall = Get-PSUGUIAppInstallInfo
            $AppUninstall = Get-PSUGUIAppUninstallInfo
            $AppDetection = Get-PSUGuiAppDetectionInfo
            if ($global:submitApp) {
              $selectedRow = ((Get-UDElement -Id "ApplicationListTableData").selection)[0]
              $application = Set-AppFactoryApp -appGUID $selectedRow @AppInformation                 
              $AppFolder = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath $application.Information.AppFolderName
              $IconFileData = Get-UDElement -Id "IconFile"
              $IconDesination = Join-Path -Path $AppFolder -ChildPath "Icon.png"
              if (-not [String]::IsNullOrWhiteSpace($IconFileData.value)) {
                $IconPath = "$($env:TEMP)\PSUApp_Icon.png"
                Copy-Item -Path $IconPath -Destination $IconDesination -Force
              }
              Set-AppFactoryAppInstall -appGUID $application.GUID @AppInstall
              Set-AppFactoryAppUninstall -appGUID $application.GUID @AppUninstall
              Set-AppFactoryAppDetectionRule -appGUID $application.GUID @AppDetection
              if($AppDetection.Type -eq "Script"){
                $ScriptData = (Get-UDElement -Id "Detection_Script").code
                $DetectionPS = Join-Path -Path $AppFolder -ChildPath "Detection.ps1"
                $ScriptData | Out-File -FilePath $DetectionPS -Force
              }
              Sync-UDElement -Id 'ApplicationListTableData'              
            }            
          }
          New-UDButton -Id "DeleteApplication" -Text "Delete Application" -Disabled -ClassName "btn btn-primary" -OnClick {
            Show-UDModal -MaxWidth lg -Content {
              Import-Module -Name $AppFactory_Module -Force
              Initialize-AppFactoryProcess -ApplicationServicePath $AppFactory_ApplicationPath
              $TableData = Get-UDElement -Id "ApplicationListTableData"
              $selectedRow = ((Get-UDElement -Id "ApplicationListTableData").selection)[0]
              $selectedRowData = $TableData.Data.Rows | Where-Object { $_.ID -eq $selectedRow }               
              $displayName = $selectedRowData.Information.DisplayName
              New-UDTypography -Text "Are you sure you want to delete this application? $($displayName)" -Variant "h5"
              New-UDButton -Text "Yes"  -ClassName "btn btn-primary" -OnClick {
                Remove-AppFactoryApp -appGUID $selectedRow
                Sync-UDElement -Id 'ApplicationListTableData' 
                Set-UDElement -id "AppTabs" -Content {New-PSUGUIAppTabs}
                Hide-UDModal   
              }
              New-UDButton -Text "No"  -ClassName "btn btn-primary" -OnClick {
                Hide-UDModal
              }
            }
          }
          New-UDButton -Id "DeleteVersion" -Text "Delete Version" -Disabled -ClassName "btn btn-primary" -OnClick {
            Show-UDModal -MaxWidth lg -Content {
              Import-Module -Name $AppFactory_Module -Force
              Initialize-AppFactoryProcess -ApplicationServicePath $AppFactory_ApplicationPath
              $TableData = Get-UDElement -Id "ApplicationListTableData"
              $selectedRow = ((Get-UDElement -Id "ApplicationListTableData").selection)[0]
              $selectedRowData = $TableData.Data.Rows | Where-Object { $_.ID -eq $selectedRow }               
              $displayName = $selectedRowData.Information.DisplayName
              $versionToDelete = (Get-UDElement -id "AvailableVersions").Value
              New-UDTypography -Text "Are you sure you want to delete this version $($versionToDelete) from $($displayName)?" -Variant "h5"
              New-UDButton -Text "Yes"  -ClassName "btn btn-primary" -OnClick {
                Remove-AppFactoryServiceAppVersions -appGUID $selectedRow -version $versionToDelete -AllAppList $script:PublishedAppList
                $AppVersions = Get-AppFactoryServiceAppVersions -appGUID $selectedRow -AllAppList $script:PublishedAppList 
                Set-UDElement -id "AvailableVersions" -Properties @{
                  Options = @(
                    foreach ($version in ($AppVersions | Sort-Object -Descending)) {
                      New-UDSelectOption -Name $version -Value $version 
                    }
                  )
                }                
                Hide-UDModal   
              }
              New-UDButton -Text "No"  -ClassName "btn btn-primary" -OnClick {
                Hide-UDModal
              }
            }            
          }      
          New-UDElement -id "AppTabs" -Content {
            New-PSUGUIAppTabs
          }    
        }    
        New-UDElement -Tag "pre" -id "datahelper" -Content {}    
      }
    }
  }
}