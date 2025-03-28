function Get-PSUGuiAppDetectionInfo{
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[Hashtable]])]
  param(
  ) 
  $AppDetection = @{}
  $UninstallInformationMap = @(
    @{
      id    = "Detection_VersionCompare"
      param = "ProductVersionOperator"
      type  = "text"
    },
    @{
      id    = "Detection_Script_32bit"
      param = "RunAs32Bit"
      type  = "switch"
    },
    @{
      id    = "Detection_Keypath"
      param = "KeyPath"
      type  = "text"
    },
    @{
      id    = "Detection_Item"
      param = "ValueName"
      type  = "text"
    },
    @{
      id    = "Detection_Operator"
      param = "Operator"
      type  = "text"
    },
    @{
      id    = "Detection_32bit"
      param = "Check32BitOn64System"
      type  = "switch"
    }
  )  
  $AppDetectionName = (Get-UDElement -id "Detection").Value
  if ([String]::IsNullOrWhiteSpace($AppDetectionName)) {
    Show-UDToast -Message "Application Detection is required on the detection tab." -Duration 3000 -Position "topCenter" -BackgroundColor "#FF0000"
    $global:submitApp = $false
  }
  else{
    if($AppDetectionName -eq "Registry Version"){
      $AppDetection.Add("Type", "Registry") | Out-Null
      $AppDetection.Add("DetectionMethod", "VersionComparison") | Out-Null
    } 
    elseif($AppDetectionName -eq "Registry Existance"){
      $AppDetection.Add("Type", "Registry") | Out-Null
      $AppDetection.Add("DetectionMethod", "Existence") | Out-Null
    }
    else{
      $AppDetection.Add("Type", $AppDetectionName) | Out-Null
    }
    foreach ($item in $UninstallInformationMap) {
      $data = Get-UDElement -id $item.ID
      if ($item.type -eq "switch" -and $null -ne $data.checked) {
        $AppDetection.Add($item.param, $data.checked) | Out-Null
      }
      else{
        if (-not [String]::IsNullOrWhiteSpace($data.value)) {
          $AppDetection.Add($item.param, $data.value) | Out-Null
        }
      }
    }    
  }
  return $AppDetection  
}