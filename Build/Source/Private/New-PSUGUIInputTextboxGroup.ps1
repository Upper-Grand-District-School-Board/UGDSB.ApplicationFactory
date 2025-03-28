function New-PSUGUIInputTextboxGroup {
  [cmdletbinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Label,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()][switch]$disabled,
    [Parameter()][string]$placeholder = "",
    [Parameter()][int]$label_width = 20,
    [Parameter()][int]$item_width = 30,
    [Parameter()][int]$label_colspan = 1,
    [Parameter()][int]$item_colspan = 1,
    [Parameter()][int]$rows = 5
  )
  New-UDElement -Tag "td" -Attributes @{
    Style = @{
      width = $label_width
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
    New-UDTextbox -Multiline -Rows $rows -FullWidth -id $id -ClassName "appfactory-textbox" -Disabled:$disabled.IsPresent
  }
}