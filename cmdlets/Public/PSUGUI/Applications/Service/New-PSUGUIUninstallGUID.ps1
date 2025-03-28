function New-PSUGUIUninstallGUID{
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
      New-PSUGUIInputTextGroup -Label "Product Code:" -id "Uninstall_productCode" -placeholder "MSI Product Code"  -item_width 80 -item_colspan 3 -Value $SourceData.productCode
    }          
  }    
}