function New-PSUGUUploadIcon {
  [cmdletbinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Label,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$output,
    [Parameter()][string]$default_icon,
    [Parameter()][string]$placeholder = "",
    [Parameter()][int]$label_width = 20,
    [Parameter()][int]$item_width = 30,
    [Parameter()][int]$label_colspan = 1,
    [Parameter()][int]$item_colspan = 1
  )
  New-UDElement -Tag "td" -Attributes @{
    Style   = @{
      width            = $label_width
      "vertical-align" = "top";
    }
    Colspan = $label_colspan
  } -Content {
    New-UDElement -Tag "span" -ClassName "appfactory-label" -Content { New-UDTypography -Text $Label }
  }  
  New-UDElement -Tag "td" -Attributes @{
    Style = @{
      width = $item_width
      "vertical-align" = "bottom";
    }
    Colspan = $item_colspan
  } -Content {
    if([String]::IsNullOrWhiteSpace($default_icon)){
      $default_icon = Join-Path -Path $script:AppFactorySupportTemplateFolder -ChildPath "PSADT" -AdditionalChildPath "Assets","AppIcon.png"
    }
    New-UDElement -Tag "table" -Content {
      New-UDElement -Tag "tr" -Content {
        New-UDElement -Tag "td" -Content {
          New-UDUpload -Id $id -Text $placeholder -OnUpload {
            $Data = $Body | ConvertFrom-Json
            $bytes = [System.Convert]::FromBase64String($Data.Data)
            [System.IO.File]::WriteAllBytes("$($env:TEMP)\PSUApp_Icon.png", $bytes)    
            Set-UDElement -Id "imgdiv" -Content {}
            Set-UDElement -Id "imgdiv" -Content {
              New-UDImage -Id "appimage" -Path "$($env:TEMP)\PSUApp_Icon.png" -Width 50 -Height 50
            }   
          }
        }
        New-UDElement -Tag "td" -Content {
          New-UDElement -Tag "div" -Id "imgdiv" -Content {
            New-UDImage -Id "appimage" -Path $default_icon -Width 50 -Height 50
          }          
        }
      }
    }
    #New-UDTextbox -Multiline -Rows 6 -FullWidth -id $id -ClassName "appfactory-textbox"
  }
}