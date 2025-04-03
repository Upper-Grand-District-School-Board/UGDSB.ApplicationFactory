function Get-PSUGUIAppInfo {
  [cmdletbinding()]
  [OutputType([System.Collections.Generic.List[Hashtable]])]
  param(
  )
  $AppInformation = @{}
  $FilterInformation = @{}
  $InformationFieldMap = @(
    @{
      id       = "ApplicationName"
      param    = "displayName"
      required = $true
      type     = "text"
    },
    @{
      id       = "Publisher"
      param    = "publisher"
      required = $true
      type     = "text"
    },
    @{
      id       = "Owner"
      param    = "owner"
      required = $false
      type     = "text"
    },
    @{
      id       = "Active"
      param    = "Active"
      required = $false
      type     = "switch"
    },
    @{
      id       = "Client"
      param    = "publishTo"
      required = $false
      type     = "select_client"
    },
    @{
      id       = "informationURL"
      param    = "informationURL"
      required = $false
      type     = "text"
    },
    @{
      id       = "PrivacyURL"
      param    = "privacyURL"
      required = $false
      type     = "text"
    },
    @{
      id       = "Architecture"
      param    = "Architecture"
      required = $false
      type     = "select"
    },
    @{
      id       = "MinimumSupportedWindowsRelease"
      param    = "MinimumSupportedWindowsRelease"
      required = $false
      type     = "select"
    },
    @{
      id       = "Description"
      param    = "Description"
      required = $true
      type     = "text"
    },
    @{
      id       = "Notes"
      param    = "Notes"
      required = $false
      type     = "text"
    }
  )
  $SourceInformatinMap = @(
    @{
      id           = "StorageContainer"
      param        = "StorageAccountContainerName"
      required     = $true
      required_for = @("storageAccount", "Sharepoint", "LocalStorage")
      type         = "text"
    },
    @{
      id           = "Installer"
      param        = "AppSetupFileName"
      required     = $true
      required_for = @("storageAccount", "Sharepoint", "Winget", "Evergreen", "LocalStorage")
      type         = "text"
    },
    @{
      id           = "AppID"
      param        = "AppID"
      required     = $true
      required_for = @("Winget", "Evergreen")
      type         = "text"
    },
    @{
      id           = "AppVersion"
      param        = "AppVersion"
      required     = $true
      required_for = @("PSADT","PowerShell")
      type         = "text"
    } 
  )
  $FilterInformationMap = @(
    @{
      id    = "Filter_Architecture"
      param = "architecture"
    },
    @{
      id    = "Filter_Platform"
      param = "Platform"
    },
    @{
      id    = "Filter_Channel"
      param = "Channel"
    },
    @{
      id    = "Filter_Type"
      param = "Type"
    },
    @{
      id    = "Filter_Release"
      param = "Release"
    },
    @{
      id    = "Filter_Language"
      param = "Language"
    },
    @{
      id    = "Filter_ImageType"
      param = "ImageType"
    }
  )
  foreach ($item in $InformationFieldMap) {
    $data = Get-UDElement -id $item.id
    if ([String]::IsNullOrWhiteSpace($data.value) -and $item.required) {
      Show-UDToast -Message "$($item.id) is required on the Information tab." -Duration 3000 -Position "topCenter" -BackgroundColor "#FF0000"
      $global:submitApp = $false
    }
    else {
      if ($item.type -eq "switch" -and $null -ne $data.checked) {
        $AppInformation.Add($item.param, $data.checked) | Out-Null
      }
      elseif($item.type -eq "select_client"){
        $Clients = [System.Collections.Generic.List[String]]::new()
        if($data.value){
          $clientList = Get-AppFactoryServiceClient
          foreach($obj in $data.value){
            $client = $clientList | Where-Object {$_.Name -eq $obj}
            $Clients.Add($client.GUID)
          }  
        }
        $AppInformation.Add($item.param, $Clients) | Out-Null
      }
      else {
        if (-not [String]::IsNullOrWhiteSpace($data.value)) {
          $AppInformation.Add($item.param, $data.value) | Out-Null
        }
      }
    }
  }
  $AppSourceName = (Get-UDElement -id "Source").Value
  if ([String]::IsNullOrWhiteSpace($AppSourceName)) {
    Show-UDToast -Message "Application Source is required on the source tab." -Duration 3000 -Position "topCenter" -BackgroundColor "#FF0000"
    $global:submitApp = $false
  }
  else {
    $AppInformation.Add("AppSource", $AppSourceName) | Out-Null
    foreach ($item in $SourceInformatinMap) {
      $data = Get-UDElement -id $item.ID
      if ([String]::IsNullOrWhiteSpace($data.value) -and $item.required -and ($AppInformation.AppSource -in $item.required_for)) {
        Show-UDToast -Message "$($item.id) is required on the source tab." -Duration 3000 -Position "topCenter" -BackgroundColor "#FF0000"
        $global:submitApp = $false
      }
      else {
        if ($item.type -eq "switch" -and $null -ne $data.checked) {
          $AppInformation.Add($item.param, $data.checked) | Out-Null
        }
        else {
          if (-not [String]::IsNullOrWhiteSpace($data.value)) {
            $AppInformation.Add($item.param, $data.value) | Out-Null
          }
        }
      }                
    }
    if ($AppSourceName -eq "Evergreen") {
      foreach ($item in $FilterInformationMap) {
        $data = Get-UDElement -id $item.id
        if (-not [String]::IsNullOrWhiteSpace($data.value)) {
          $FilterInformation.Add($item.param, $data.value) | Out-Null
        }
      }
      $AppInformation.Add("filterOptions", $FilterInformation) | Out-Null
    }    
  }  
  return $AppInformation
}