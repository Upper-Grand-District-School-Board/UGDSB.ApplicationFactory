function New-PSUGUIUninstallEXE{
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
      New-PSUGUIInputTextGroup -Label "Setup Name:" -id "Uninstall_installer" -placeholder "### Only set if not the same download file ###"  -item_width 80 -item_colspan 3 -Value $SourceData.installer
    }
    New-UDElement -Tag "tr" -Content {
      New-PSUGUIInputTextGroup -Label "Parameters:" -id "Uninstall_argumentList" -placeholder "Parameters" -item_width 80 -item_colspan 3 -Value $SourceData.argumentList
    } 
    New-UDElement -Tag "tr" -Content {
      New-PSUGUIInputTextGroup -Label "Conflicting Processes (Start):" -id "Uninstall_conflictingProcessStart" -placeholder "Comma seperated list of conflicting processes" -item_width 80 -item_colspan 3 -Value ($SourceData.conflictingProcessStart -Join ", ")
    }
    New-UDElement -Tag "tr" -Content {
      New-PSUGUIInputTextGroup -Label "Conflicting Processes (End):" -id "Uninstall_conflictingProcessEnd" -placeholder "Comma seperated list of conflicting processes" -item_width 80 -item_colspan 3 -Value ($SourceData.conflictingProcessEnd -Join ", ")
    } 
    New-UDElement -Tag "tr" -Content {
      New-PSUGUIInputTextGroup -Label "Ignore Exit Codes:" -id "Uninstall_ignoreExitCodes" -placeholder "Comma seperated list of exit codes to ignore" -item_width 80 -item_colspan 3 -Value ($SourceData.ignoreExitCodes -Join ", ")
    } 
    New-UDElement -Tag "tr" -Content {
      New-PSUGUISwitch -Label "WIM:" -id "Uninstall_wim" -Checked:$SourceData.wim
      New-PSUGUISwitch -Label "Packaged File (Dirfiles):" -id "Uninstall_dirFiles" -Checked:$SourceData.dirFiles
    }   
    New-UDElement -Tag "tr" -Content {
      New-PSUGUISwitch -Label "Secure Argument List:" -id "Uninstall_secureArgumentList" -Checked:$SourceData.secureArgumentList
    }            
  }   
}