function New-PSUGUIDetectionScript{
  [cmdletbinding()]
  param(
    [Parameter()][PSCustomObject]$SourceData,
    [Parameter()][string]$scriptPath
  )
  New-UDElement -Tag "table"  -Attributes @{
    "style"       = @{
      "width" = "100%";

    }
    "cellpadding" = "1"
  } -Content {
    New-UDElement -Tag "tr" -Content {
      if(Test-Path $scriptPath){
        $code = Get-Content -Path $scriptPath -ErrorAction SilentlyContinue
      }
      New-PSUGUIInputCode -id "Detection_Script" -item_colspan 4 -Code ($code -join "`n")
    }   
    New-UDElement -Tag "tr" -Content {
      New-PSUGUISwitch -Label "32-Bit:" -id "Detection_Script_32bit" -Checked:$([System.Convert]::ToBoolean($SourceData.RunAs32Bit))
    } 
  }    
}