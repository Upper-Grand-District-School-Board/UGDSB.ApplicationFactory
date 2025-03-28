function New-PSUGUIInputSelectGroup {
  [cmdletbinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Label,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()][string[]]$options,
    [Parameter()][string[]]$defaultValue = @(),
    [Parameter()][string]$placeholder = "",
    [Parameter()][string]$onchangeAction = "",
    [Parameter()][int]$label_width = 20,
    [Parameter()][int]$item_width = 30,
    [Parameter()][int]$label_colspan = 1,
    [Parameter()][int]$item_colspan = 1,    
    [Parameter()][switch]$multiselect   
  )
  New-UDElement -Tag "td" -Content {
    New-UDElement -Tag "span" -ClassName "appfactory-label" -Content { New-UDTypography -Text $Label }
  } -Attributes @{"style" = @{"width" = "$($label_width)%"; "vertical-align" = "bottom"; }; Colspan = $label_colspan }
  New-UDElement -Tag "td" -Content {
    New-UDSelect -Multiple:$($multiselect.isPresent) -ClassName "appfactory-select" -DefaultValue $defaultValue -id $id -FullWidth -Option {
      foreach ($option in $options) {
        New-UDSelectOption -Name $option -Value $option
      }
    } -OnChange {
      switch ($onchangeAction) {
        "SourceSelection" {
          Set-UDElement -Id "SourceSelectionFields" -Content {}
          Set-UDElement -Id "SourceSelectionFields" -Content {
            switch ((Get-UDElement $id).value) {
              "StorageAccount" {
                New-PSUGUISourceStorageAccount
              }
              "Sharepoint" {
                New-PSUGUISourceSharepoint
              }
              "Winget" {
                New-PSUGUISourceWinget
              }
              "Evergreen" {
                New-PSUGUISourceEvergreen
              }
              "ECNO" {
                New-PSUGUISourceECNO
              }
              "LocalStorage" {
                New-PSUGUISourceStorageAccount
              }
            }
          }
        }
        "InstallSelection" {
          Set-UDElement -Id "InstallSelectionFields" -Content {}
          Set-UDElement -Id "InstallSelectionFields" -Content {
            switch ((Get-UDElement $id).value) {
              "Script" {
                New-PSUGUIInstallScript
              }
              "EXE" {
                New-PSUGUIInstallEXE
              }
              "MSI" {
                New-PSUGUIInstallMSI
              }
            }
          }          
        }
        "UninstallSelection" {
          Set-UDElement -Id "UninstallSelectionFields" -Content {}
          Set-UDElement -Id "UninstallSelectionFields" -Content {
            switch ((Get-UDElement $id).value) {
              "Script" {
                New-PSUGUIUnInstallScript
              }
              "EXE" {
                New-PSUGUIUnInstallEXE
              }
              "MSI" {
                New-PSUGUIUnInstallMSI
              }
              "Name" {
                New-PSUGUIUninstallName
              }
              "GUID" {
                New-PSUGUIUninstallGUID
              }    
            }
          }          
        }        
        "DetectionSelection" {
          Set-UDElement -Id "DetectionSelectionFields" -Content {}
          Set-UDElement -Id "DetectionSelectionFields" -Content {
            switch ((Get-UDElement $id).value) {
              "MSI" {
                New-PSUGUIDetectionMSI
              }
              "Registry Version" {
                New-PSUGUIDetectionRegistryVersion
              }
              "Registry Existance" {
                New-PSUGUIDetectionRegistryExistance
              }              
              "Script" {
                New-PSUGUIDetectionScript
              }
            }
          }
        }
        "AvailableVersionsSelection" {
          Set-UDElement -id "DeleteVersion" -Properties @{
            Disabled = $false
          }
        }
        default {}
      }
    }
  } -Attributes @{"style" = @{"width" = "$($item_width)%"; "vertical-align" = "bottom" }; Colspan = $item_colspan }  
}  