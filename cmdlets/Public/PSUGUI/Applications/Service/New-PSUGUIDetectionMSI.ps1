function New-PSUGUIDetectionMSI{
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
      New-PSUGUIInputSelectGroup -Label "Version Comparison:" -id "Detection_VersionCompare" -placeholder "" -options @("notConfigured","equal","notEqual","greaterThanOrEqual","greaterThan","lessThanOrEqual","lessThan") -item_colspan 3 -item_width 80 -defaultValue $SourceData.ProductVersionOperator
    }              
  }    
}