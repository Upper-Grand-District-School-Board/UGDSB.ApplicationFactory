function New-PSUGUISourceEvergreen{
  [cmdletbinding()]
  param(
    [Parameter()][PSCustomObject]$SourceData
  )
  New-UDElement -Tag "table"  -Attributes @{
    "style"       = @{
      "width" = "100%";

    }
    "cellpadding" = "1"
  } -Content {
    New-UDElement -Tag "tr" -Content {
      New-PSUGUIInputTextGroup -Label "Installer:" -id "Installer" -placeholder "Installer File Name" -Value $SourceData.appSetupFileName
      New-PSUGUIInputTextGroup -Label "Evergreen ID:" -id "AppID" -placeholder "Evergreen ID" -Value $SourceData.appID
    } 
    New-UDElement -Tag "tr" -content {New-UDElement -Tag 'td' -content {New-UDElement -Tag "br" -content {}}}
    New-UDElement -Tag "tr" -Content {
      New-UDElement -Tag "td" -Content {
        New-UDTypography -Text "Filter Options" -Variant "h6" -ClassName "card-title rounded x-card-title"
      } -Attributes @{Colspan = 4 }
    }
    New-UDElement -Tag "tr" -Content {
      New-PSUGUIInputTextGroup -Label "Architecture:" -id "Filter_Architecture" -placeholder "" -Value $SourceData.filterOptions.architecture
      New-PSUGUIInputTextGroup -Label "Platform:" -id "Filter_Platform" -placeholder "" -Value $SourceData.filterOptions.Platform
    } 
    New-UDElement -Tag "tr" -Content {
      New-PSUGUIInputTextGroup -Label "Channel:" -id "Filter_Channel" -placeholder "" -Value $SourceData.filterOptions.Channel
      New-PSUGUIInputTextGroup -Label "Type:" -id "Filter_Type" -placeholder "" -Value $SourceData.filterOptions.Type
    } 
    New-UDElement -Tag "tr" -Content {
      New-PSUGUIInputTextGroup -Label "Installer Type:" -id "Filter_InstallerType" -placeholder "" -Value $SourceData.filterOptions.InstallerType
      New-PSUGUIInputTextGroup -Label "Release:" -id "Filter_Release" -placeholder "" -Value $SourceData.filterOptions.Release
    } 
    New-UDElement -Tag "tr" -Content {
      New-PSUGUIInputTextGroup -Label "Language:" -id "Filter_Language" -placeholder "" -Value $SourceData.filterOptions.Language
      New-PSUGUIInputTextGroup -Label "Image Type:" -id "Filter_ImageType" -placeholder "" -Value $SourceData.filterOptions.ImageType
    }                 
  }     
}