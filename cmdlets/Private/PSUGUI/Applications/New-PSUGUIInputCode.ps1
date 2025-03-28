function New-PSUGUIInputCode{
  [cmdletbinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$id,
    [Parameter()][Object[]]$Code,
    [Parameter()][int]$item_height = 400,
    [Parameter()][int]$item_colspan = 1,
    [Parameter()][string]$language = "powershell"
  )
  New-UDElement -Tag "td" -Attributes @{
    Style = @{
      "vertical-align" = "bottom";
    }
    Colspan = $item_colspan
  } -Content {
    New-UDCodeEditor -Height $item_height -Language $language -id $id -Code ($Code -Join "`n")
  }  
}