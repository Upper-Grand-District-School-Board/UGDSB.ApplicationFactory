function New-PSUGUIUninstallName{
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
      New-PSUGUIInputTextGroup -Label "Name:" -id "Uninstall_name" -placeholder "Name of Application"  -item_width 80 -item_colspan 3 -Value $SourceData.name
    }          
  }    
}