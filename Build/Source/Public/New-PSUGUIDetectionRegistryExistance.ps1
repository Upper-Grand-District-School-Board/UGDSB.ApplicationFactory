function New-PSUGUIDetectionRegistryExistance{
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
    $registryKey = $SourceData.keyPath -split "\\"
    if($registryKey[-1] -ne "###PRODUCTCODE###"){$value = $registryKey[-1]}
    else{$value = ""}    
    New-UDElement -Tag "tr" -Content {
      New-PSUGUIInputTextGroup -Label "Registry Key:" -id "Detection_Keypath" -placeholder "### Only set if do not want to detect automatically from MSI ###"  -item_width 80 -item_colspan 3 -Value $value
    }
    New-UDElement -Tag "tr" -Content {
      New-PSUGUIInputTextGroup -Label "Registry Item:" -id "Detection_Item" -placeholder "DisplayVersion"  -item_width 80 -item_colspan 3 -Value $SourceData.valueName
    }  
    New-UDElement -Tag "tr" -Content {
      New-PSUGUIInputSelectGroup -Label "Detection Type:" -id "Detection_Operator" -placeholder "" -options @("notConfigured","equal","notEqual","greaterThanOrEqual","greaterThan","lessThanOrEqual","lessThan") -item_colspan 3 -item_width 80 -DefaultValue $SourceData.operator
    }  
    New-UDElement -Tag "tr" -Content {
      New-PSUGUISwitch -Label "32-Bit:" -id "Detection_32bit" -Checked:$([System.Convert]::ToBoolean($SourceData.Check32BitOn64System))
    }                       
  }   
}