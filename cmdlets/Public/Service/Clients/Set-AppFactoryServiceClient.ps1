<#
  .DESCRIPTION
  This cmdlet is designed to update the details of an client
  .PARAMETER GUID
  The unique identifier for the client that we want to work with
    .PARAMETER name
  The name of the client
  .PARAMETER contactList
  The list of contacts for the client
  .PARAMETER LogLevel
  If logging is enabled, what level of logging do we want, default is verbose.

  .EXAMPLE

  Update an client name
    Set-AppFactoryClient -clientGUID "### GUID ###" -clientName "### Client Name ###"

  Update an client cotacts
    Set-AppFactoryClient -clientGUID "### GUID ###" -clientContact "### Contact 1 ###","### Contact 2 ###"
#>
function Set-AppFactoryServiceClient{
  [CmdletBinding()]
  [Alias("Set-AppFactoryOrganization")]
  param(  
    [Alias("GUID")][Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$clientGUID,
    [Alias("Name")][Parameter()][ValidateNotNullOrEmpty()][string]$clientName,
    [Alias("contactList")][Parameter()][string[]]$clientContact,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  )  
  # Get Client Configuration Files
  $client = Get-AppFactoryServiceClient -GUID $clientGUID -LogLevel $LogLevel
  if ($null -eq $client) {
    Write-PSFMessage -Message "Error Encountered: Client not found." -Level "Error" -Tag "Client","$($clientGUID)" -Target "Application Factory Service"
    throw "CLient not found." 
  }
  # Flag to know if we actually updated anything
  $changed = $false
  # If Contact List is Set to Be Updated
  if($null-ne $clientContact -and $clientContact -ne "" -and $PSBoundParameters.ContainsKey("clientContact")){
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "[$($client.Name)] Updating Contact List - <c='green'>$($clientContact -join ",")</c>" -Level $LogLevel -Tag "Clients","ContactList","$($client.Name)","$($clientGUID)" -Target "Application Factory Service"
    }
    $client.Contacts = $clientContact
    $changed = $true
  }
  # If the contact list is meant to be cleaned
  elseif($PSBoundParameters.ContainsKey("clientContact")){
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "[$($client.Name)] Clearning contact list." -Level $LogLevel -Tag "Clients","ContactList","$($client.Name)","$($clientGUID)" -Target "Application Factory Service"
    }
    $client.Contacts = @()
    $changed = $true
  }
  if($PSBoundParameters.ContainsKey("clientName")){
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "[$($client.Name)] Updating Name - <c='green'>$($clientName)</c>" -Level $LogLevel -Tag "Clients","clientName","$($client.Name)","$($clientGUID)" -Target "Application Factory Service"
    }
    $client.Name = $clientName
    $changed = $true    
  }
  # If something has been changed, lets do some updates
  if($changed){
    # Get Current Path of client File
    $fileName = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Clients" -AdditionalChildPath $client.FileName
    # Remove the filename property since we will be writing out the configuration
    $client.PsObject.properties.Remove("fileName")
    try{
      $client | ConvertTo-Json -Depth 3 | Out-File $fileName
      if($script:AppFactoryLogging){
        Write-PSFMessage -Message "[$($client.Name)] Saved configuration file" -Level $LogLevel -Tag "Clients","$($client.Name)","$($clientGUID)" -Target "Application Factory Service"
      }      
      # If the client name is to be changed. update the filename to match.
      if($PSBoundParameters.ContainsKey("clientName")){
        Rename-Item -Path $fileName -NewName "$($clientName).json" -Force
        if($script:AppFactoryLogging){
          Write-PSFMessage -Message "[$($client.Name)] Renamed configuration file" -Level $LogLevel -Tag "Clients","$($client.Name)","$($clientGUID)" -Target "Application Factory Service"
        }        
      }
    }
    catch{
      Write-PSFMessage -Message "Error Encountered: $($_)" -Level "Error" -Tag "Clients","$($client.Name)","$($clientGUID)" -Target "Application Factory Service"
      throw $_   
    }    
  }  
  return $client
}