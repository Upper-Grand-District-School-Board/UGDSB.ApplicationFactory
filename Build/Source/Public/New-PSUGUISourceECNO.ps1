function New-PSUGUISourceECNO{
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
      New-PSUGUIInputTextGroup -Label "Folder/Container:" -id "StorageContainer" -placeholder "Folder/Container Name" -Value $SourceData.storageAccountContainerName
    }    
  }   
}