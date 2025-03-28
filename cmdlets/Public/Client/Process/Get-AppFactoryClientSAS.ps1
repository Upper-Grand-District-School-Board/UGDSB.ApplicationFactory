function Get-AppFactoryClientSAS{
  [CmdletBinding()]
  param(
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"    
  )
  # What is the PSU Endpoint we should be using
  $PSUEndpoint = "$($script:AppFactoryClientApiEndpoint)/SAS"
  # Retrieve Data
  $headers = @{
    "content-type"  = "application/json"
    "authorization" = "bearer $(ConvertFrom-SecureString $script:AppFactoryClientAPISecret -AsPlainText)"
  }
  $sas = Invoke-RestMethod -Method "GET" -Uri $PSUEndpoint -Headers $headers -StatusCodeVariable "statusCode" 
  $script:AppFactoryClientSASorganization = $sas.organization
  $script:AppFactoryClientSASPublicContainerName = $sas.PublicContainerName
  $script:AppFactoryClientSASStoragePath = $sas.StoragePath
  $script:AppFactoryClientSASOrganizationContainerName = $sas.OrganizationContainerName
  $script:AppFactoryClientSASpublic = $sas.public
}