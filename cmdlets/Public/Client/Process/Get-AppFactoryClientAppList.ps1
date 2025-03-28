function Get-AppFactoryClientAppList {
  [CmdletBinding()]
  param(
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"    
  )
  # Where to save file
  $ApplicationFolder = Join-Path -Path $script:AppFactoryClientSourceDir -ChildPath "Apps" 
  # Create the folder if it doesn't exist
  Remove-Item -Path $ApplicationFolder -Force -Recurse
  if (-not (Test-Path -Path $ApplicationFolder)) {
    New-Item -Path $ApplicationFolder -ItemType Directory | Out-Null
  }
  # What is the PSU Endpoint we should be using
  $PSUEndpoint = "$($script:AppFactoryClientApiEndpoint)/AppList"   
  # Retrieve Data
  $headers = @{
    "content-type"  = "application/json"
    "authorization" = "bearer $(ConvertFrom-SecureString $script:AppFactoryClientAPISecret -AsPlainText)"
  }
  $applicationList = Invoke-RestMethod -Method "GET" -Uri $PSUEndpoint -Headers $headers -StatusCodeVariable "statusCode"
  foreach($application in $applicationList){
    $applicationPath = Join-Path -Path $ApplicationFolder -ChildPath "$($application.IntuneAppName).json"
    $application | ConvertTo-Json -Depth 10 | Out-File -FilePath $applicationPath -Force
  }
  
}