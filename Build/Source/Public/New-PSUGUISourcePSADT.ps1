function New-PSUGUISourcePSADT{
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
      if(-not $SourceData -or $SourceData.AppVersion -eq "<replaced_by_build>"){
        [version]$VersionData = [Version]"1.0.0"
      }
      else{
        [version]$VersionData = [Version]$SourceData.AppVersion
      }
      New-PSUGUIInputTextGroup -Label "Script Version:" -id "AppVersion" -placeholder "Script Version i.e. 1.0.0" -Value $VersionData
    }    
  }   
}