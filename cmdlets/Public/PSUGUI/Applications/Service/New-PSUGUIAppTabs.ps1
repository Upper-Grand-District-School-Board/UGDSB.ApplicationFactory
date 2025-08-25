function New-PSUGUIAppTabs{
  [cmdletbinding()]
  param()
  New-UDTabs -Tabs {
    New-UDTab -Text 'Information' -Content {
      New-UDElement -Tag "div" -ClassName "card-body rounded" -Content {
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
            New-PSUGUIInputTextGroup -Label "Name:" -id "ApplicationName" -placeholder "Application Name"
            New-PSUGUIInputTextGroup -Label "Publisher:" -id "Publisher" -placeholder "Publisher Name"
          }
          New-UDElement -Tag "tr" -Content {
            New-PSUGUIInputSelectGroup -Label "Versions:" -id "AvailableVersions" -placeholder "Available Versions" -onchangeAction "AvailableVersionsSelection"
            New-PSUGUIInputTextGroup -Label "Owner:" -id "Owner" -placeholder "Owner Name"
          }
          New-UDElement -Tag "tr" -Content {
            New-PSUGUISwitch -Label "Active:" -id "Active" -Checked
            New-PSUGUISwitch -Label "Paused:" -id "pauseUpdate"
          }
          New-UDElement -Tag "tr" -Content {
            New-PSUGUIInputSelectGroup -Label "Install As:" -id "InstallExperience" -options @("system", "user") -DefaultValue "System"
            New-PSUGUUploadIcon -Label "Icon:" -id "IconFile" -placeholder "Upload Icon" -Output "$($env:TEMP)\PSUApp_Icon.png"
          }
          New-UDElement -Tag "tr" -Content {
            New-PSUGUIInputSelectGroup -Label "Clients:" -id "Client" -placeholder "Client Specific" -multiselect -options ((Get-AppFactoryServiceClient | Select-Object Name).Name | Sort-Object) -item_colspan 3 -item_width 80
          }
          New-UDElement -Tag "tr" -Content {
            New-PSUGUIInputTextGroup -Label "Information URL:" -id "InformationURL" -placeholder "Information URL" -item_colspan 3 -item_width 80
          }
          New-UDElement -Tag "tr" -Content {
            New-PSUGUIInputTextGroup -Label "Privacy URL:" -id "PrivacyURL" -placeholder "Privacy URL" -item_colspan 3 -item_width 80
          }  
          New-UDElement -Tag "tr" -Content {
            New-PSUGUIInputSelectGroup -Label "Architecture:" -id "Architecture" -placeholder "Available Architecture" -options @("All", "x86", "x64") -DefaultValue "All"
            New-PSUGUIInputSelectGroup -Label "Min Win OS:" -id "MinimumSupportedWindowsRelease" -placeholder "Minimum Windows OS Version" -options @("W10_1607", "W10_1703", "W10_1709", "W10_1809", "W10_1909", "W10_2004", "W10_20H2", "W10_21H1", "W10_21H2", "W10_22H2", "W11_21H2", "W11_22H2") -DefaultValue "W10_1607"
          } 
          New-UDElement -Tag "tr" -Content {
            New-PSUGUIInputTextGroup -Label "Memory (in MB):" -id "MinimumMemoryInMB" -placeholder "Minimum Memory in MB"
            New-PSUGUIInputTextGroup -Label "Disk Space (in MB):" -id "MinimumFreeDiskSpaceInMB" -placeholder "Minimum Disk Space in MB"
          }          
          New-UDElement -Tag "tr" -Content {
            New-PSUGUIInputTextboxGroup -Label "Description:" -id "Description" -placeholder "Description" -item_colspan 3 -item_width 80
          }
          New-UDElement -Tag "tr" -Content {
            New-PSUGUIInputTextboxGroup -Label "Notes:" -id "Notes" -placeholder "Notes" -item_colspan 3 -item_width 80
          }
        }
      }
    }
    New-UDTab -Text 'Source' -Content {
      New-UDElement -Tag "div" -ClassName "card-body rounded" -Content {
        New-UDElement -Tag "table"  -Attributes @{
          "style"       = @{
            "width" = "100%";

          }
          "cellpadding" = "1"
        } -Content {
          New-UDElement -Tag "tr" -Content {
            New-PSUGUIInputSelectGroup -Label "Source:" -id "Source" -placeholder "Select Source" -options @("StorageAccount", "Sharepoint", "Winget", "Evergreen", "PSADT", "ECNO", "LocalStorage") -item_colspan 3 -item_width 80 -onchangeAction "SourceSelection"
          }
        }                
      }
      New-UDelement -Tag "div" -ClassName "card-body rounded" -id "SourceSelectionFields" -Content {}
    }
    New-UDTab -Text 'Install' -Content {
      New-UDElement -Tag "div" -ClassName "card-body rounded" -Content {
        New-UDElement -Tag "table"  -Attributes @{
          "style"       = @{
            "width" = "100%";

          }
          "cellpadding" = "1"
        } -Content {
          New-UDElement -Tag "tr" -Content {
            New-PSUGUIInputSelectGroup -Label "Install:" -id "Install" -placeholder "Select Install Type" -options @("None", "EXE", "MSI", "ECNO", "Script") -item_colspan 3 -item_width 80 -onchangeAction "InstallSelection"
          }
        }                
      }
      New-UDelement -Tag "div" -ClassName "card-body rounded" -id "InstallSelectionFields" -Content {}             
    }
    New-UDTab -Text 'Uninstall' -Content {
      New-UDElement -Tag "div" -ClassName "card-body rounded" -Content {
        New-UDElement -Tag "table"  -Attributes @{
          "style"       = @{
            "width" = "100%";

          }
          "cellpadding" = "1"
        } -Content {
          New-UDElement -Tag "tr" -Content {
            New-PSUGUIInputSelectGroup -Label "Uninstall:" -id "Uninstall" -placeholder "Select Uninstall Type" -options @("NONE", "MSI", "EXE", "NAME", "GUID", "ECNO", "Script") -item_colspan 3 -item_width 80 -onchangeAction "UninstallSelection"
          }
        }                
      }
      New-UDelement -Tag "div" -ClassName "card-body rounded" -id "UninstallSelectionFields" -Content {}               
    }
    New-UDTab -Text 'Detection' -Content {
      New-UDElement -Tag "div" -ClassName "card-body rounded" -Content {
        New-UDElement -Tag "table"  -Attributes @{
          "style"       = @{
            "width" = "100%";

          }
          "cellpadding" = "1"
        } -Content {
          New-UDElement -Tag "tr" -Content {
            New-PSUGUIInputSelectGroup -Label "Detection:" -id "Detection" -placeholder "Select Detection Type" -options @("MSI", "Registry Version", "Registry Existance", "Script") -item_colspan 3 -item_width 80 -onchangeAction "DetectionSelection"
          }
        }                
      }
      New-UDelement -Tag "div" -ClassName "card-body rounded" -id "DetectionSelectionFields" -Content {}                  
    }
  }  
}