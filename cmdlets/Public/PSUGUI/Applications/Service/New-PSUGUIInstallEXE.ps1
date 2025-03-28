function New-PSUGUIInstallEXE{
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
      New-PSUGUIInputTextGroup -Label "Setup Name:" -id "Install_installer" -placeholder "### Only set if not the same download file ###"  -item_width 80 -item_colspan 3 -Value $SourceData.installer
    }
    New-UDElement -Tag "tr" -Content {
      New-PSUGUIInputTextGroup -Label "Parameters:" -id "Install_argumentList" -placeholder "Parameters" -item_width 80 -item_colspan 3 -Value $SourceData.argumentList
    } 
    New-UDElement -Tag "tr" -Content {
      New-PSUGUIInputTextGroup -Label "Conflicting Processes (Start):" -id "Install_conflictingProcessStart" -placeholder "Comma seperated list of conflicting processes" -item_width 80 -item_colspan 3 -Value ($SourceData.conflictingProcessStart -Join ", ")
    }
    New-UDElement -Tag "tr" -Content {
      New-PSUGUIInputTextGroup -Label "Conflicting Processes (End):" -id "Install_conflictingProcessEnd" -placeholder "Comma seperated list of conflicting processes" -item_width 80 -item_colspan 3 -Value ($SourceData.conflictingProcessEnd -Join ", ")
    } 
    New-UDElement -Tag "tr" -Content {
      New-PSUGUIInputTextGroup -Label "Ignore Exit Codes:" -id "Install_ignoreExitCodes" -placeholder "Comma seperated list of exit codes to ignore" -item_width 80 -item_colspan 3 -Value ($SourceData.ignoreExitCodes -Join ", ")
      
    } 
    New-UDElement -Tag "tr" -Content {
      New-PSUGUISwitch -Label "WIM:" -id "Install_WIM" -Checked:$SourceData.wim
      New-PSUGUISwitch -Label "Secure Argument List:" -id "Install_secureArgumentList" -Checked:$SourceData.secureArgumentList
    }               
  }   
}