function Get-PSUGUIAppUninstallInfo {
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[Hashtable]])]
  param(
  ) 
  $AppUninstall = @{}  
  $UninstallInformationMap = @(
    @{
      id    = "Uninstall_installer"
      param = "installer"
      type  = "text"
    },
    @{
      id    = "Uninstall_argumentList"
      param = "argumentList"
      type  = "text"
    },
    @{
      id    = "Uninstall_conflictingProcessStart"
      param = "conflictingProcessStart"
      type  = "array"
    },
    @{
      id    = "Uninstall_conflictingProcessEnd"
      param = "conflictingProcessEnd"
      type  = "array"
    },
    @{
      id    = "Uninstall_ignoreExitCodes"
      param = "ignoreExitCodes"
      type  = "array"
    },
    @{
      id    = "Uninstall_wim"
      param = "wim"
      type  = "switch"
    },
    @{
      id    = "Uninstall_dirFiles"
      param = "dirFiles"
      type  = "switch"
    },
    @{
      id    = "Uninstall_secureArgumentList"
      param = "secureArgumentList"
      type  = "switch"
    },
    @{
      id    = "Uninstall_productCode"
      param = "productCode"
      type  = "text"
    },
    @{
      id    = "Uninstall_additionalArgumentList"
      param = "additionalArgumentList"
      type  = "text"
    },
    @{
      id    = "Uninstall_name"
      param = "name"
      type  = "text"
    },
    @{
      id    = "Uninstall_Script"
      param = "script"
      type  = "code"
    }
  )
  $AppUninstallName = (Get-UDElement -id "Uninstall").Value
  if ([String]::IsNullOrWhiteSpace($AppUninstallName)) {
    Show-UDToast -Message "Application Uninstall is required on the uninstall tab." -Duration 3000 -Position "topCenter" -BackgroundColor "#FF0000"
    $global:submitApp = $false
  }
  else{
    $AppUninstall.Add("Type", $AppUninstallName) | Out-Null
    foreach ($item in $UninstallInformationMap) {
      $data = Get-UDElement -id $item.ID
      if ($item.type -eq "switch" -and $null -ne $data.checked) {
        $AppUninstall.Add($item.param, $data.checked) | Out-Null
      }
      elseif($item.type -eq "array" -and (-not [String]::IsNullOrWhiteSpace($data.value))){
        $AppUninstall.Add($item.param, ($data.value -split ",")) | Out-Null
      }
      elseif($item.type -eq "code" -and (-not [String]::IsNullOrWhiteSpace($data.code))){
        $AppUninstall.Add($item.param, ($data.code -split "`r`n")) | Out-Null
      }
      else{
        if (-not [String]::IsNullOrWhiteSpace($data.value)) {
          $AppUninstall.Add($item.param, $data.value) | Out-Null
        }
      }
    }
  }  
  return $AppUninstall
}