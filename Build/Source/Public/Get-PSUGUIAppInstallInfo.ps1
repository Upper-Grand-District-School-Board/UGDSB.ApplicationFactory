function Get-PSUGUIAppInstallInfo{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[Hashtable]])]
  param(
  )  
  $AppInstall = @{}
  $InstallInformationMap = @(
    @{
      id    = "Install_installer"
      param = "installer"
      type  = "text"
    },
    @{
      id    = "Install_argumentList"
      param = "argumentList"
      type  = "text"
    },
    @{
      id    = "Install_conflictingProcessStart"
      param = "conflictingProcessStart"
      type  = "array"
    },
    @{
      id    = "Install_conflictingProcessEnd"
      param = "conflictingProcessEnd"
      type  = "array"
    },
    @{
      id    = "Install_ignoreExitCodes"
      param = "ignoreExitCodes"
      type  = "array"
    },
    @{
      id    = "Install_WIM"
      param = "wim"
      type  = "switch"
    },
    @{
      id    = "Install_secureArgumentList"
      param = "secureArgumentList"
      type  = "switch"
    },
    @{
      id    = "Install_transforms"
      param = "transforms"
      type  = "text"
    },
    @{
      id    = "Install_additionalArgumentList"
      param = "additionalArgumentList"
      type  = "text"
    },
    @{
      id    = "Install_SkipMSIAlreadyInstalledCheck"
      param = "SkipMSIAlreadyInstalledCheck"
      type  = "switch"
    },
    @{
      id    = "Install_Script"
      param = "script"
      type  = "code"
    }
  )  
  $AppInstallName = (Get-UDElement -id "Install").Value
  if ([String]::IsNullOrWhiteSpace($AppInstallName)) {
    Show-UDToast -Message "Application Install is required on the install tab." -Duration 3000 -Position "topCenter" -BackgroundColor "#FF0000"
    $global:submitApp = $false
  }
  else{
    $AppInstall.Add("Type", $AppInstallName) | Out-Null
    foreach ($item in $InstallInformationMap) {
      $data = Get-UDElement -id $item.ID
      if ($item.type -eq "switch" -and $null -ne $data.checked) {
        $AppInstall.Add($item.param, $data.checked) | Out-Null
      }
      elseif($item.type -eq "array" -and (-not [String]::IsNullOrWhiteSpace($data.value))){
        $AppInstall.Add($item.param, ($data.value -split ",")) | Out-Null
      }
      elseif($item.type -eq "code" -and (-not [String]::IsNullOrWhiteSpace($data.code))){
        $AppInstall.Add($item.param, ($data.code -split "`r`n")) | Out-Null
      }
      else{
        if (-not [String]::IsNullOrWhiteSpace($data.value)) {
          $AppInstall.Add($item.param, $data.value) | Out-Null
        }
      }
    }
  }
  return $AppInstall  
}