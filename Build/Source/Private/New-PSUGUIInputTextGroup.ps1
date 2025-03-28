function New-PSUGUIInputTextGroup {
  [cmdletbinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Label,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()][switch]$disabled,
    [Parameter()][string]$value = "",
    [Parameter()][string]$placeholder = "",
    [Parameter()][int]$label_width = 20,
    [Parameter()][int]$item_width = 30,
    [Parameter()][int]$label_colspan = 1,
    [Parameter()][int]$item_colspan = 1
  )
  New-UDElement -Tag "td" -Attributes @{
    Style   = @{
      width            = $label_width
      "vertical-align" = "bottom";
    }
    Colspan = $label_colspan
  } -Content {
    New-UDElement -Tag "span" -ClassName "appfactory-label" -Content { New-UDTypography -Text $Label }
  }  
  New-UDElement -Tag "td" -Attributes @{
    Style   = @{
      width            = $item_width
      "vertical-align" = "bottom";
    }
    Colspan = $item_colspan
  } -Content {
    #New-UDElement -Tag "input" -ClassName "appfactory-input" -id $id -Attributes @{
    #  value        = $value
    #  placeholder  = $placeholder
    #  "aria-label" = $placeholder
    #  type         = "input"
    #}
    New-UDTextBox -FullWidth -Placeholder $placeholder -id $id -Value $value -ClassName "appfactory-input" -Disabled:$disabled.IsPresent
  }
}