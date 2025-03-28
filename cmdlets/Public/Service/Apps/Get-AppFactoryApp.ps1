<#
  .DESCRIPTION
  This cmdlet returns a list of applications that are part of the packaging process
  .PARAMETER appSource
  This is a filtering parameter for specific appsources
  .PARAMETER GUID
  The unique identifier for the application that we want to work with
  .PARAMETER displayName
  The unique name of the application that we want to work with
  .PARAMETER AppID
  This is a filtering parameter for specific AppID
  .PARAMETER AppPublisher
  This is a filtering parameter for specific application publisher
  .PARAMETER StorageAccountContainerName
  This is a filtering parameter for specific application azure storage container
  .PARAMETER publishTo
  This is a filtering parameter for specific organization
  .PARAMETER public
  This is a filtering parameter for all public applications
  .PARAMETER LogLevel
  If logging is enabled, what level of logging do we want, default is verbose.

  .EXAMPLE

  Get a list of all applications
  Get-AppFactoryApp

  Get a list of specific application sources
  Get-AppFactoryApp -appSource "### Application Source ###"

  Get a list of applications based on GUID
  Get-AppFactoryApp -GUID "### GUID ###"

  Get a list of applications based on AppID
  Get-AppFactoryApp -AppID "### AppID ###"

  Get a list of applications based on Application Publisher
  Get-AppFactoryApp -AppPublisher "### Publisher ###"

  Get a list of applications based on Publish To a client
  Get-AppFactoryApp -publishTo "### Client ###"

  Get a list of all public applications
  Get-AppFactoryApp -public

  Get a list of all application with logging enabled
  Get-AppFactoryApp -LogLevel "Output"
#>
function Get-AppFactoryApp{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter()][ValidateSet("StorageAccount", "Sharepoint", "Winget", "Evergreen", "PSADT", "ECNO", "LocalStorage")][string]$appSource,
    [Parameter()][ValidateNotNullOrEmpty()][string]$appGUID,
    [Parameter()][ValidateNotNullOrEmpty()][string]$displayName,
    [Parameter()][ValidateNotNullOrEmpty()][string]$AppID,
    [Parameter()][ValidateNotNullOrEmpty()][string]$Publisher,
    [Parameter()][ValidateNotNullOrEmpty()][string]$StorageAccountContainerName,
    [Parameter()][ValidateNotNullOrEmpty()][string]$publishTo,
    [Parameter()][ValidateNotNullOrEmpty()][string]$dependsOn,
    [Parameter()][switch]$public,
    [Parameter()][switch]$active,
    [Parameter()][ValidateSet("Output","Verbose")][string]$LogLevel = "Verbose"
  )  
  # Get the path to where the application configs are stored
  $applicationFolders = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps"
  # Get a list of all the configuration files for the applications
  $ApplicationConfigFiles = Get-Childitem -Path $applicationFolders -Recurse -Filter "ApplicationConfig.json"  
  if($script:AppFactoryLogging){
    Write-PSFMessage -Message "Retrieved Application Configurations at path <c='green'>$($applicationFolders)</c>" -Level $LogLevel -Tag "Application" -Target "Application Factory Service"
  }  
  # Create an empty array to store the application objects
  $applicaitonList =  [System.Collections.Generic.List[PSCustomObject]]@()
  # Perform any needed filtering based on passed variables
  foreach($file in $ApplicationConfigFiles){
    $json = Get-Content $file.FullName | ConvertFrom-Json
    # If specific parameters are passed, filter the list of applications based on those parameters
    if($PSBoundParameters.ContainsKey("appGUID") -and $json.GUID -ne $appGUID){continue}
    if($PSBoundParameters.ContainsKey("appSource") -and $json.SourceFiles.appSource -ne $appSource){continue}
    if($PSBoundParameters.ContainsKey("displayName") -and $json.Information.displayName -notlike "$($displayName)"){continue}
    if($PSBoundParameters.ContainsKey("AppID") -and $json.SourceFiles.AppID -ne $AppID){continue}
    if($PSBoundParameters.ContainsKey("Publisher") -and $json.Information.Publisher -ne $AppPublisher){continue}
    if($PSBoundParameters.ContainsKey("StorageAccountContainerName") -and $json.SourceFiles.StorageAccountContainerName -ne $StorageAccountContainerName){continue}
    if($PSBoundParameters.ContainsKey("publishTo") -and $publishTo -notin $json.SourceFiles.publishTo){continue}
    if($PSBoundParameters.ContainsKey("dependsOn") -and $dependsOn -notin $json.SourceFiles.dependsOn){continue}
    if($PSBoundParameters.ContainsKey("dependsOn") -and $dependsOn -notin $json.SourceFiles.dependsOn){continue}
    if($active.IsPresent -and (-not $json.SourceFiles.Active)){continue}
    if($public.IsPresent -and $json.SourceFiles.publishTo.count -ne 0){continue}
    if($script:AppFactoryLogging){
      Write-PSFMessage -Message "Reading Application: <c='green'>$($json.Information.displayName) ($($json.GUID))</c>"-Level $LogLevel -Tag "Application","$($json.displayName)","$($json.GUID)" -Target "Application Factory Service"
    }
    $applicaitonList.Add($json) | Out-Null
  }
  # Return the application list
  return $applicaitonList  
}