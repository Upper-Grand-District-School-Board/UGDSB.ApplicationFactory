function Set-AppFactoryAppDetectionRule{
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$appGUID,
    [Parameter(Mandatory = $true)][ValidateSet("MSI","Registry","Script")][string]$Type,
    [Parameter()][ValidateSet("notConfigured","equal","notEqual","greaterThanOrEqual","greaterThan","lessThanOrEqual","lessThan")][string]$ProductVersionOperator = "notConfigured",
    [Parameter()][ValidateSet("Existence","VersionComparison")][string]$DetectionMethod,
    [Parameter()][ValidateNotNullOrEmpty()][string]$KeyPath = "###PRODUCTCODE###",
    [Parameter()][ValidateNotNullOrEmpty()][string]$ValueName = "DisplayVersion",
    [Parameter()][ValidateSet("exists","notExists")][string]$DetectionType,
    [Parameter()][switch]$Check32BitOn64System = $false,
    [Parameter()][Switch]$EnforceSignatureCheck = $false,
    [Parameter()][Switch]$RunAs32Bit = $false,
    [Parameter()][ValidateSet("notConfigured","equal","notEqual","greaterThanOrEqual","greaterThan","lessThanOrEqual","lessThan")][string]$Operator = "greaterThanOrEqual",
    [Parameter()][ValidateNotNullOrEmpty()][string]$ScriptFile = "detection.ps1",
    [Parameter()][ValidateSet("Output","Verbose")][string]$LogLevel = "Verbose"
  )
  # Get the application Config
  $configfile = Get-AppFactoryApp -appGUID $appGUID -LogLevel $LogLevel
  if (-not ($configfile)) {
    throw "Application with GUID $($GUID) does not exist."
  }  
  # Create a object with the details for the detection type
  $detectionRule = [PSCustomObject]@{
    "Type"                    = $Type
  }
  # Depending on the type, set the appropriate details
  switch($Type){
    "MSI"{
      $detectionRule | Add-Member -MemberType "NoteProperty" -Name "ProductCode" -Value "<replaced_by_pipeline>"
      $detectionRule | Add-Member -MemberType "NoteProperty" -Name "ProductVersionOperator" -Value $ProductVersionOperator
      if($ProductVersionOperator -ne "notConfigured"){
        $detectionRule | Add-Member -MemberType "NoteProperty" -Name "ProductVersion" -Value "<replaced_by_pipeline>"
      }
    }
    "Registry"{
      $detectionRule | Add-Member -MemberType "NoteProperty" -Name "DetectionMethod" -Value $DetectionMethod
      $detectionRule | Add-Member -MemberType "NoteProperty" -Name "KeyPath" -Value "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$($KeyPath)"
      $detectionRule | Add-Member -MemberType "NoteProperty" -Name "ValueName" -Value $ValueName
      if($DetectionType){
        $detectionRule | Add-Member -MemberType "NoteProperty" -Name "DetectionType" -Value $DetectionType
      }
      if($Operator){
        $detectionRule | Add-Member -MemberType "NoteProperty" -Name "Operator" -Value $Operator
        $detectionRule | Add-Member -MemberType "NoteProperty" -Name "Value" -Value "<replaced_by_pipeline>"
      }
      $detectionRule | Add-Member -MemberType "NoteProperty" -Name "Check32BitOn64System" -Value "$($Check32BitOn64System.IsPresent)"
    }
    "Script"{
      $detectionRule | Add-Member -MemberType "NoteProperty" -Name "ScriptFile" -Value $ScriptFile
      $detectionRule | Add-Member -MemberType "NoteProperty" -Name "EnforceSignatureCheck" -Value "$($EnforceSignatureCheck.IsPresent)"
      $detectionRule | Add-Member -MemberType "NoteProperty" -Name "RunAs32Bit" -Value "$($RunAs32Bit.IsPresent)"
      $detectionScriptPath = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath $configfile.Information.AppFolderName,"detection.ps1"
      if(-not (Test-Path $detectionScriptPath)){
        $detectiontemplate = Join-Path -Path $script:AppFactorySupportTemplateFolder -ChildPath "Application" -AdditionalChildPath "detection.ps1"
        Copy-Item -Path $detectiontemplate -Destination $detectionScriptPath
      }
    }
  }  
  $configfile.DetectionRule = ,$detectionRule
  try{
    Write-AppConfiguration -configfile $configfile -LogLevel $LogLevel
  }
  catch{
    Write-PSFMessage -Message "Error Encountered: $($_)" -Level "Error" -Tag "Application", "$($configfile.Information.displayName)", "$($configFIle.GUID)" -Target "Application Factory Service"
    throw $_
  }
}