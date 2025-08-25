function Get-AppfactoryPSUClientApplications {
  [cmdletbinding()]
  param()
  Initialize-AppFactoryProcess -ApplicationServicePath $AppFactory_ApplicationPath
  $ids = ($Roles -match "(^([0-9A-Fa-f]{8}[-]?[0-9A-Fa-f]{4}[-]?[0-9A-Fa-f]{4}[-]?[0-9A-Fa-f]{4}[-]?[0-9A-Fa-f]{12})$)")
  $clients = Get-AppFactoryServiceClient
  if ($roles.Contains($PSU_GUI_AdminRole)) {
    $defaultValue = $AppFactoryDefaultClientGUID
  }
  else {
    $defaultValue = $ids[0]
  }
  $page:authtoken = Get-Secret -Vault $KVName -Name $APIInternalSecret -AsPlainText
  $page:applist = Invoke-RestMethod -uri "https://$($psuenv)/api/appfactory/clientapps/$($defaultValue)" -Method Get -Headers @{ "Authorization" = "Bearer $($page:authtoken)" } 
  New-UDSelect -Id "ClientIDs" -ClassName "inputrequired"  -DefaultValue $defaultValue -FullWidth -Option {
    foreach ($client in $clients) {
      if ($ids.Contains($client.GUID) -or $roles.Contains($PSU_GUI_AdminRole)) {
        New-UDSelectOption -Name $client.Name -Value $client.GUID
      }
    }
  } -OnChange {
    Show-UDModal -Content {
      New-UDTypography -Text "Updating Organization List" -Variant "h5"
    }    
    $orgID = (Get-UDElement -id "ClientIDs").value
    $page:applist = Invoke-RestMethod -uri "https://$($psuenv)/api/appfactory/clientapps/$($orgID)" -Method Get -Headers @{ "Authorization" = "Bearer $($page:authtoken)" } 
    Sync-UDElement -Id 'ApplicationListTableData'
    Hide-UDModal
  }
  New-UDElement -tag "br"
  New-UDElement -tag "br"
  New-UDElement -Tag "div" -ClassName "container-fluid" -Content {
    New-UDElement -Tag "div" -ClassName "row justify-content-start" -Content {
      New-UDElement -Tag "div" -ClassName "col-5" -Content {
        New-UDElement -Tag "div" -ClassName "card-body rounded" -Content {
          New-UDTypography -Text "Application List" -Variant "h5" -ClassName "card-title rounded x-card-title"
          New-UDElement -Tag "div" -id "ApplicationList" -Content {
            New-UDDataGrid -id "ApplicationListTableData" -LoadRows {
            $page:applist | Out-UDDataGridData -Context $EventData -TotalRows $Rows.Length
          } -Columns @(
            New-UDDataGridColumn -Field ID -Flex 0 -DisableColumnMenu -DisableReorder -Hide
            New-UDDataGridColumn -Field Name -Flex 1.5 -Render {
              $EventData.Name
              if ($null -ne $EventData.InformationURL -and $EventData.InformationURL -ne "") {
                New-UDLink -Url $EventData.InformationURL -OpenInNewWindow -Content {
                  New-UDImage -URL "/assets/images/information.png" -Attributes @{
                    alt   = "$($EventData.InformationURL)"
                    style = @{
                      width  = "20px"
                      height = "20px"
                      "padding-left" = "5px"
                    }
                  }
                }
              }
              if ($null -ne $EventData.PrivacyURL -and $EventData.PrivacyURL -ne "") {
                New-UDLink -Url $EventData.PrivacyURL -OpenInNewWindow -Content {
                  New-UDImage -URL "/assets/images/privacy.png" -Attributes @{
                    alt   = "$($EventData.PrivacyURL)"
                    style = @{
                      width  = "20px"
                      height = "20px"
                      "padding-left" = "5px"
                    }
                  }
                }
              }
            }
            New-UDDataGridColumn -Field Enabled -Flex 1.5
            New-UDDataGridColumn -Field Updated -Flex 1.5
            New-UDDataGridColumn -Field ClientDetails -Flex 0 -DisableColumnMenu -DisableExport -DisableReorder -Hide -Render {}
            New-UDDataGridColumn -Field AppVersions -Flex 0 -DisableColumnMenu -DisableExport -DisableReorder -Hide -Render {}
          ) -StripedRows -AutoHeight $true -PageSize 10 -RowsPerPageOptions @(10, 25, 50, 100, 1000) -ShowPagination -DefaultSortColumn Name -OnSelectionChange {
              $TableData = Get-UDElement -Id "ApplicationListTableData"
              $selectedRow = ((Get-UDElement -Id "ApplicationListTableData").selection)[0]
              $selectedRowData = $TableData.Data.Rows | Where-Object { $_.ID -eq $selectedRow }
              $AppDetails = $selectedRowData.ClientDetails | ConvertFrom-Json
              $AppVersions = $selectedRowData.AppVersions
              $PreviousVersionNumber = 0
              if (-not [String]::IsNullOrWhiteSpace($AppDetails.KeepPrevious)) {
                $PreviousVersionNumber = $AppDetails.KeepPrevious
              }
              Set-UDElement -id "ApplicationGUID" -Attributes @{ "value" = $selectedRow }
              Set-UDElement -id "ApplicationName" -Attributes @{ "value" = $selectedRowData.Name }
              Set-UDElement -id "ApplicationDescription" -Attributes @{ "value" = $selectedRowData.Description }
              Set-UDElement -id "Enabled" -Attributes @{ "checked" = [System.Convert]::ToBoolean($selectedRowData.Enabled) }
              Set-UDElement -id "DownloadForground" -Attributes @{ "checked" = [System.Convert]::ToBoolean($AppDetails.foreground) }
              Set-UDElement -id "PreviousVersions" -Attributes @{ "value" = $PreviousVersionNumber }
              Set-UDElement -id "ESP" -Attributes @{ "value" = $AppDetails.espprofiles -join ", " }
              Set-UDElement -id "CopyPrevious" -Attributes @{ "checked" = [System.Convert]::ToBoolean($AppDetails.CopyPrevious) }
              Set-UDElement -id "RemovePrevious" -Attributes @{ "checked" = [System.Convert]::ToBoolean($AppDetails.UnassignPrevious) }
              Set-UDElement -id "InteractiveInstall" -Attributes @{ "checked" = [System.Convert]::ToBoolean($AppDetails.InteractiveInstall) }
              Set-UDElement -id "InteractiveUninstall" -Attributes @{ "checked" = [System.Convert]::ToBoolean($AppDetails.InteractiveUninstall) }
              Set-UDElement -id "Available_Install" -Attributes @{ "value" = $AppDetails.AvailableAssignments -join ", " }
              Set-UDElement -id "Available_Exceptions" -Attributes @{ "value" = $AppDetails.AvailableExceptions -join ", " }
              Set-UDElement -id "Required_Install" -Attributes @{ "value" = $AppDetails.RequiredAssignments -join ", " }
              Set-UDElement -id "Required_Exceptions" -Attributes @{ "value" = $AppDetails.RequiredExceptions -join ", " }
              Set-UDElement -id "Required_Uninstall" -Attributes @{ "value" = $AppDetails.UninstallAssignments -join ", " }
              Set-UDElement -id "Uninstall_Exceptions" -Attributes @{ "value" = $AppDetails.UninstallExceptions -join ", " }
              Set-UDElement -id "InformationURL" -Attributes @{ "value" = $selectedRowData.InformationURL }
              Set-UDElement -id "PrivacyURL" -Attributes @{ "value" = $selectedRowData.PrivacyURL }
              Set-UDElement -id "InstallType" -Attributes @{ "value" = $selectedRowData.InstallType }
              Set-UDElement -id "Publisher" -Attributes @{ "value" = $selectedRowData.Publisher }
              Set-UDElement -id "Architecture" -Attributes @{ "value" = $selectedRowData.RequirementRules.Architecture }
              Set-UDElement -id "MinOS" -Attributes @{ "value" = $selectedRowData.RequirementRules.MinimumSupportedWindowsRelease }
              Set-UDElement -id "MemoryInMB" -Attributes @{ "value" = $selectedRowData.RequirementRules.MinimumMemoryInMB ? $selectedRowData.RequirementRules.MinimumMemoryInMB : "" }
              Set-UDElement -id "DiskSpaceInMB" -Attributes @{ "value" = $selectedRowData.RequirementRules.MinimumFreeDiskSpaceInMB ? $selectedRowData.RequirementRules.MinimumFreeDiskSpaceInMB : "" }       
              $FilterDetails = [System.Collections.Generic.List[String]]@()
              if ($appdetails.filters) {
                $FilterNames = ($appdetails.filters | get-member | where-Object { $_.MemberType -eq "NoteProperty" } | select-object Name).Name
                foreach ($filter in $FilterNames) {
                  $FilterDetails.Add("$($filter);$($appdetails.filters.$filter.filterName);$($appdetails.filters.$filter.filterType)")
                }  
              }
              Set-UDElement -id "FilterList" -Attributes @{ "value" = $FilterDetails -join ", " }
              if ([String]::IsNullOrWhiteSpace($AppDetails.AppVersion)) {
                $VersionValue = "0.0"
              }
              else {
                $VersionValue = $AppDetails.AppVersion
              }
              Set-UDElement -id "VersionControl" -Content {}
              Set-UDElement -id "VersionControl" -Content {
                New-UDSelect -ClassName "appfactory-select" -id "SelectedVersion" -FullWidth
              }
              Set-UDElement -id "SelectedVersion" -Properties @{
                DefaultValue = $VersionValue
                Options = @(
                  New-UDSelectOption -Name "Latest" -Value "0.0"
                  foreach ($version in ($AppVersions | Sort-Object -Descending)) {
                    New-UDSelectOption -Name $version -Value $version
                  }            
                )
              }
              Set-UDElement -id "UpdateApplication" -Properties @{
                Disabled = $false
              }
            }
          }
        }
      }
      New-UDElement -Tag "div" -ClassName "col-1" -Content {}
      New-UDElement -Tag "div" -ClassName "col-6" -Content {
        New-UDElement -Tag "div" -ClassName "card-body rounded" -Content {
          New-UDTypography -Text "Application Details" -Variant "h5" -ClassName "card-title rounded x-card-title"
          New-UDButton -Id "UpdateApplication" -Text "Update Application" -ClassName "btn btn-primary" -Disabled -OnClick {
            Show-UDModal -Content {
              New-UDTypography -Text "Updating Application Configuration" -Variant "h5"
            }
            $selectedRow = ((Get-UDElement -Id "ApplicationListTableData").selection)[0]
            $orgID = (Get-UDElement -id "ClientIDs").value
            $AppVersionSelected = (Get-UDElement -id "SelectedVersion").Value
            $AppConfig = @{
              orgGUID              = $orgID
              appGUID              = $selectedRow
              AddToIntune          = (Get-UDElement -id "Enabled").checked
              AvailableAssignments = ((Get-UDelement -id "Available_Install").Value -split ",")
              AvailableExceptions  = ((Get-UDelement -id "Available_Exceptions").Value -split ",")
              RequiredAssignments  = ((Get-UDelement -id "Required_Install").Value -split ",")
              RequiredExceptions   = ((Get-UDelement -id "Required_Exceptions").Value -split ",")
              UninstallAssignments = ((Get-UDelement -id "Required_Uninstall").Value -split ",")
              UninstallExceptions  = ((Get-UDelement -id "Uninstall_Exceptions").Value -split ",")
              UnassignPrevious     = (Get-UDElement -id "RemovePrevious").checked
              CopyPrevious         = (Get-UDElement -id "CopyPrevious").checked
              KeepPrevious         = (Get-UDElement -id "PreviousVersions").Value
              foreground           = (Get-UDElement -id "DownloadForground").checked
              espprofiles          = ((Get-UDelement -id "ESP").Value -split ",")
              InteractiveInstall   = (Get-UDElement -id "InteractiveInstall").checked
              InteractiveUninstall = (Get-UDElement -id "InteractiveUninstall").checked
              AppVersion           = $AppVersionSelected
            }    
            $AllFilters = (Get-UDElement -id "FilterList").Value -split ","
            $filters = @{}
            foreach ($filter in $AllFilters) {
              $filterDetails = $filter -split ";"
              if (-not [String]::IsNullOrWhiteSpace($filterDetails[0])) {
                $filters.Add($filterDetails[0], @{filterName = $filterDetails[1]; filterType = $filterDetails[2] })
              }
            }
            $AppConfig.Add("filters", $filters)            
            Invoke-RestMethod -uri "https://$($psuenv)/api/appfactory/clientapps/$($orgID)" -Method Put -Headers @{ "Authorization" = "Bearer $($page:authtoken)" } -Body (@{appdata = $AppConfig} | ConvertTo-Json -Depth 10) -ContentType "application/json" -StatusCodeVariable updatestatus
            $page:applist = Invoke-RestMethod -uri "https://$($psuenv)/api/appfactory/clientapps/$($orgID)" -Method Get -Headers @{ "Authorization" = "Bearer $($page:authtoken)" } 
            Sync-UDElement -Id 'ApplicationListTableData' 
            Hide-UDModal
          }
          New-UDElement -Tag "table"  -Attributes @{
            "style"       = @{
              "width" = "100%";
  
            }
            "cellpadding" = "1"
          } -Content {          
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextGroup -Label "GUID:" -id "ApplicationGUID" -placeholder "" -disabled -item_colspan 3 -item_width 80
            }
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextGroup -Label "Display Name:" -id "ApplicationName" -placeholder "" -disabled -item_colspan 3 -item_width 80
            }      
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextboxGroup -Label "Description:" -id "ApplicationDescription" -placeholder "" -disabled -item_colspan 3 -item_width 80 -Rows 4
            }                 
            New-UDElement -Tag "tr" -Content {
              New-PSUGUISwitch -Label "Enabled:" -id "Enabled"
              New-PSUGUISwitch -Label "Download Foreground:" -id "DownloadForground"
            }     
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextGroup -Label "Keep Previous Versions:" -id "PreviousVersions" -placeholder ""
              #New-PSUGUIInputSelectGroup -Label "Version:" -id "SelectedVersion" -placeholder "" -DefaultValue ""
              New-UDElement -Tag "td" -Content {
                New-UDElement -Tag "span" -ClassName "appfactory-label" -Content { New-UDTypography -Text "Version:" }
              } -Attributes @{"style" = @{"width" = "20%"; "vertical-align" = "bottom"; }; }  
              New-UDElement -Tag "td" -id "VersionControl" -Content {
                New-UDSelect -ClassName "appfactory-select" -DefaultValue "" -id "SelectedVersion" -FullWidth -Option {
                }
              }
            }                                     
            New-UDElement -Tag "tr" -Content {
              New-PSUGUISwitch -Label "Copy Previous Assignments:" -id "CopyPrevious"
              New-PSUGUISwitch -Label "Unassign Previous Assignments:" -id "RemovePrevious"
            }      
            New-UDElement -Tag "tr" -Content {
              New-PSUGUISwitch -Label "Interactive Install:" -id "InteractiveInstall"
              New-PSUGUISwitch -Label "Interactive Uninstall:" -id "InteractiveUninstall"
            }
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextGroup -Label "ESP Assignments:" -id "ESP" -placeholder "Names of entra groups comma seperated" -item_colspan 3 -item_width 80
            }
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextGroup -Label "Filters:" -id "FilterList" -placeholder "See docuemntation for proper format" -item_colspan 3 -item_width 80
            }                         
            New-UDElement -Tag "tr" -content { New-UDElement -Tag 'td' -content { New-UDElement -Tag "br" -content {} } }
            New-UDElement -Tag "tr" -Content {
              New-UDElement -Tag "td" -Content {
                New-UDTypography -Text "Application Install Assignments" -Variant "h6" -ClassName "card-title rounded x-card-title"
              } -Attributes @{Colspan = 4 }
            } 
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextGroup -Label "Required:" -id "Required_Install" -placeholder "Names of entra groups comma seperated" -item_colspan 3 -item_width 80
            }
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextGroup -Label "Required Exceptions:" -id "Required_Exceptions" -placeholder "Names of entra groups comma seperated" -item_colspan 3 -item_width 80
            }              
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextGroup -Label "Available for enrolled devices:" -id "Available_Install" -placeholder "Names of entra groups comma seperated" -item_colspan 3 -item_width 80
            }
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextGroup -Label "Available for enrolled devices Exceptions:" -id "Available_Exceptions" -placeholder "Names of entra groups comma seperated" -item_colspan 3 -item_width 80
            }            
            New-UDElement -Tag "tr" -content { New-UDElement -Tag 'td' -content { New-UDElement -Tag "br" -content {} } }
            New-UDElement -Tag "tr" -Content {
              New-UDElement -Tag "td" -Content {
                New-UDTypography -Text "Application Uninstall Assignments" -Variant "h6" -ClassName "card-title rounded x-card-title"
              } -Attributes @{Colspan = 4 }
            }             
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextGroup -Label "Required:" -id "Required_Uninstall" -placeholder "Names of entra groups comma seperated" -item_colspan 3 -item_width 80
            }
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextGroup -Label "Exceptions:" -id "Uninstall_Exceptions" -placeholder "Names of entra groups comma seperated" -item_colspan 3 -item_width 80
            }
            New-UDElement -Tag "tr" -content { New-UDElement -Tag 'td' -content { New-UDElement -Tag "br" -content {} } }
            New-UDElement -Tag "tr" -Content {
              New-UDElement -Tag "td" -Content {
                New-UDTypography -Text "Package Details" -Variant "h6" -ClassName "card-title rounded x-card-title"
              } -Attributes @{Colspan = 4 }
            } 
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextGroup -Label "Architecture:" -id "Architecture" -disabled -placeholder ""
              New-PSUGUIInputTextGroup -Label "Min OS:" -id "MinOS" -disabled -placeholder ""
            } 
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextGroup -Label "Memroy (in MB):" -id "MemoryInMB" -disabled -placeholder ""
              New-PSUGUIInputTextGroup -Label "Disk Space (in MB):" -id "DiskSpaceInMB" -disabled -placeholder ""
            } 
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextGroup -Label "Install Type:" -id "InstallType" -disabled -placeholder ""
              New-PSUGUIInputTextGroup -Label "Publisher:" -id "Publisher" -disabled -placeholder ""
            } 
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextGroup -Label "Information URL:" -id "InformationURL" -placeholder "" -disabled -item_colspan 3 -item_width 80
            }
            New-UDElement -Tag "tr" -Content {
              New-PSUGUIInputTextGroup -Label "Privacy URL:" -id "PrivacyURL" -placeholder "" -disabled -item_colspan 3 -item_width 80
            }
          }
        }        
        New-UDElement -Tag "div" -id "ts_step" -content {}
      }      
    }
  }
}