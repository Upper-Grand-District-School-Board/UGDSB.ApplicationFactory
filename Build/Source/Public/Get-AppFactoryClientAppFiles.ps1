function Get-AppFactoryClientAppFiles {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(  
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$applications,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"  
  )
  $downloadFolder = Join-Path -Path $script:AppFactoryClientWorkspace -ChildPath "Downloads" -AdditionalChildPath $application.IntuneAppName
  if(Test-Path $downloadFolder){
    Remove-Item -Path $downloadFolder -Force -Recurse -ErrorAction SilentlyContinue
  }
  New-Item -Path $downloadFolder -ItemType Directory | Out-Null
  $container = $script:AppFactoryClientSASPublicContainerName
  $sas = $script:AppFactoryClientSASpublic
  if($application.container -ne $script:AppFactoryClientSASPublicContainerName){
    $container = $script:AppFactoryClientSASOrganizationContainerName
    $sas = $script:AppFactoryClientSASorganization
  }
  $endpoint = "$($script:AppFactoryClientSASStoragePath)/$($container)/$($application.GUID)/$($application.AppVersion)"
  if($script:AppFactoryClientLogging){
    Write-PSFMessage -Message "[<c='green'>$($application.IntuneAppName)</c>] Downloading files from $($endpoint)" -Level $LogLevel -Tag "Applications","$($application.IntuneAppName)" -Target "Application Factory Client"
  }
  $filelist = @("$($application.IntuneAppName).intunewin","App.json")
  foreach($file in $filelist){
    try{
      Invoke-WebRequest -Uri "$($endpoint)/$($file)?$($sas)" -OutFile "$($downloadFolder)\$($file)" | Out-Null
    }
    catch{
      throw "[<c='green'>$($application.IntuneAppName)</c>] Failed to download $($file) from $($baseURI). $($_.Exception.Message)"
    }    
  }
  $AppData = Get-Content "$($downloadFolder)\App.json" | ConvertFrom-JSON
  $downloadFiles = [System.Collections.Generic.List[String]]@()
  $downloadFiles.Add($AppData.PackageInformation.IconFile) | Out-Null
  if($AppData.DetectionRule.Type -eq "Script"){
    $downloadFiles.Add($AppData.DetectionRule.ScriptFile) | Out-Null
  }
  foreach($file in $downloadFiles){
    try{
      Invoke-WebRequest -Uri "$($endpoint)/$($file)?$($sas)" -OutFile "$($downloadFolder)\$($file)" | Out-Null
    }
    catch{
      throw "[<c='green'>$($application.IntuneAppName)</c>] Failed to download $($file) from $($baseURI). $($_.Exception.Message)"
    }
  }  
}