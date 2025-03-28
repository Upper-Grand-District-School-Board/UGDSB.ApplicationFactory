<#
  .DESCRIPTION
  This cmdlet is designed to list out the clients that are configured
  .PARAMETER GUID
  The unique identifer for the specific client
  .PARAMETER Name
  Get an client based on the name
  .PARAMETER Contact
  Get clients that have a specific contact
  .PARAMETER LogLevel
  If logging is enabled, what level of logging do we want, default is verbose.

  .EXAMPLE
  Get all client
    Get-AppFactoryClient

  Get specific client by clientGUID
    Get-AppFactoryClient -clientGUID "### GUID ###"

  Get specific client by clientName
    Get-AppFactoryClient -clientName "### client Name ###"

  Get specific client by Contact
    Get-AppFactoryClient -clientContact "### Contact Name ###"
#>
function Get-AppFactoryServiceClient {
  [CmdletBinding()]
  [Alias("Get-AppFactoryOrganization")]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Alias("GUID")][Parameter()][ValidateNotNullOrEmpty()][string]$clientGUID,
    [Alias("Name")][Parameter()][ValidateNotNullOrEmpty()][string]$clientName,
    [Alias("Contact")][Parameter()][ValidateNotNullOrEmpty()][string]$clientContact,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  # Client Configuration Folder
  $clientsFolder = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Clients"
  if ($script:AppFactoryLogging) {
    Write-PSFMessage -Message "Reading client files in path <c='green'>$($clientsFolder)</c>" -Level $LogLevel -Tag "Clients" -Target "Application Factory Service"
  }
  # Get list of client configuration files
  $clientConfigs = Get-Childitem -Path $clientsFolder  
  # Create list that we will return with the clients configurations
  $clients = [System.Collections.Generic.List[PSCustomObject]]@()
  foreach ($file in $clientConfigs) {
    # Read the clients file
    $json = Get-Content $file.FullName | ConvertFrom-Json
    if ($PSBoundParameters.ContainsKey("clientGUID") -and $json.GUID -ne $clientGUID) { continue }
    # If Name is set, match the name variable.
    if ($PSBoundParameters.ContainsKey("clientName") -and $json.Name -notlike "$($clientName)") { continue }
    # If Contact is set, match entries that have that contact
    if ($PSBoundParameters.ContainsKey("clientContact") -and $Json.Contacts.indexOf($clientContact) -eq -1) { continue }
    if ($script:AppFactoryLogging) {
      Write-PSFMessage -Message "Reading client file <c='green'>$($file)</c>" -Level $LogLevel -Tag "Clients", "$($json.Name)" -Target "Application Factory Service"
    }
    # Add the path to the file for specific client
    $json | Add-Member -MemberType "NoteProperty" -Name "FileName" -Value $file.Name
    $clients.Add($json) | Out-Null    
  }
  # Return the clients list
  return $clients  
}