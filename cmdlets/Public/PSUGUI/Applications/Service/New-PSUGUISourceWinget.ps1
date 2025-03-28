function New-PSUGUISourceWinget{
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
      New-PSUGUIInputTextGroup -Label "Winget ID:" -id "AppID" -placeholder "Winget ID" -Value $SourceData.appID
    }    
  }   
}