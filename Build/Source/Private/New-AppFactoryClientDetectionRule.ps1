function New-AppFactoryClientDetectionRule {
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(  
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$ApplicationFolder,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )  
  $rules = [System.Collections.Generic.List[PSCustomObject]]@() 
  $DetectionRules = $application.DetectionRule
  foreach ($DetectionRuleItem in $DetectionRules) {
    switch ($DetectionRuleItem.Type) {
      "MSI" {
        if ($script:AppFactoryClientLogging) {
          Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Adding MSI Detection Rule" -Level $LogLevel -Tag "Applications", "Intune", "$($application.Information.DisplayName)" -Target "Application Factory Client"
        }
        $DetectionRule = [ordered]@{
          "@odata.type"            = "#microsoft.graph.win32LobAppProductCodeDetection"
          "productCode"            = $DetectionRuleItem.ProductCode
          "productVersionOperator" = $DetectionRuleItem.ProductVersionOperator
          "productVersion"         = $DetectionRuleItem.ProductVersion
        }        
      } 
      "Script" {
        if ($script:AppFactoryClientLogging) {
          Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Adding Script Detection Rule" -Level $LogLevel -Tag "Applications", "Intune", "$($application.Information.DisplayName)" -Target "Application Factory Client"
        }
        # Create a PowerShell script based detection rule
        $ScriptContent = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Content -Path (Join-Path -Path $ApplicationFolder -ChildPath $DetectionRuleItem.ScriptFile) -Raw -Encoding UTF8)))
        $DetectionRule = [ordered]@{
          "@odata.type"           = "#microsoft.graph.win32LobAppPowerShellScriptDetection"
          "enforceSignatureCheck" = [System.Convert]::ToBoolean($DetectionRuleItem.EnforceSignatureCheck)
          "runAs32Bit"            = [System.Convert]::ToBoolean($DetectionRuleItem.RunAs32Bit)
          "scriptContent"         = $ScriptContent
        }
      } 
      "Registry" {
        if ($script:AppFactoryClientLogging) {
          Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Adding Registry Detection Rule" -Level $LogLevel -Tag "Applications", "Intune", "$($application.Information.DisplayName)" -Target "Application Factory Client"
        }
        switch ($DetectionRuleItem.DetectionMethod) {
          "Existence" {
            $DetectionRule = [ordered]@{
              "@odata.type"          = "#microsoft.graph.win32LobAppRegistryDetection"
              "operator"             = "notConfigured"
              "detectionValue"       = $null
              "check32BitOn64System" = [System.Convert]::ToBoolean($DetectionRuleItem.Check32BitOn64System)
              "keyPath"              = $DetectionRuleItem.KeyPath
              "valueName"            = $DetectionRuleItem.ValueName
              "detectionType"        = $DetectionRuleItem.DetectionType
            }
          }
          "VersionComparison" {
            $DetectionRule = [ordered]@{
              "@odata.type"          = "#microsoft.graph.win32LobAppRegistryDetection"
              "operator"             = $DetectionRuleItem.Operator
              "detectionValue"       = $DetectionRuleItem.Value
              "check32BitOn64System" = [System.Convert]::ToBoolean($DetectionRuleItem.Check32BitOn64System)
              "keyPath"              = $DetectionRuleItem.KeyPath
              "valueName"            = $DetectionRuleItem.ValueName
              "detectionType"        = "version"
            }
          }
          "StringComparison" {
            $DetectionRule = [ordered]@{
              "@odata.type"          = "#microsoft.graph.win32LobAppRegistryDetection"
              "operator"             = $DetectionRuleItem.Operator
              "detectionValue"       = $DetectionRuleItem.Value
              "check32BitOn64System" = [System.Convert]::ToBoolean($DetectionRuleItem.Check32BitOn64System)
              "keyPath"              = $DetectionRuleItem.KeyPath
              "valueName"            = $DetectionRuleItem.ValueName
              "detectionType"        = "string"
            }
          }
          "IntegerComparison" {
            $DetectionRule = [ordered]@{
              "@odata.type"          = "#microsoft.graph.win32LobAppRegistryDetection"
              "operator"             = $DetectionRuleItem.Operator
              "detectionValue"       = $DetectionRuleItem.Value
              "check32BitOn64System" = [System.Convert]::ToBoolean($DetectionRuleItem.Check32BitOn64System)
              "keyPath"              = $DetectionRuleItem.KeyPath
              "valueName"            = $DetectionRuleItem.ValueName
              "detectionType"        = "integer"
            }
          }
          
        }
      }
      "File" {
        if ($script:AppFactoryClientLogging) {
          Write-PSFMessage -Message "[<c='green'>$($application.Information.DisplayName)</c>] Adding File Detection Rule" -Level $LogLevel -Tag "Applications", "Intune", "$($application.Information.DisplayName)" -Target "Application Factory Client"
        }
        switch ($DetectionRuleItem.DetectionMethod) {
          "Existence" {
            $DetectionRule = [ordered]@{
              "@odata.type" = "#microsoft.graph.win32LobAppFileSystemDetection"
              "operator" = "notConfigured"
              "detectionValue" = $null
              "path" = $DetectionRuleItem.Path
              "fileOrFolderName" = $DetectionRuleItem.FileOrFolder
              "check32BitOn64System" = [System.Convert]::ToBoolean($DetectionRuleItem.Check32BitOn64System)
              "detectionType" = $DetectionRuleItem.DetectionType
          }            
          }
          "DateModified" {
            [datatime]$InputObject = [datatime]$DetectionRuleItem.DateTimeValue
            $DateValueString = Get-Date -Year $InputObject.Year -Month $InputObject.Month -Day $InputObject.Day -Hour $InputObject.Hour -Minute $InputObject.Minute -Second $InputObject.Second -UFormat '+%Y-%m-%dT%H:%M:%S.000Z'
            $DetectionRule = [ordered]@{
              "@odata.type" = "#microsoft.graph.win32LobAppFileSystemDetection"
              "operator" = $DetectionRuleItem.Operator
              "detectionValue" = $DateValueString
              "path" = $DetectionRuleItem.Path
              "fileOrFolderName" = $DetectionRuleItem.FileOrFolder
              "check32BitOn64System" = [System.Convert]::ToBoolean($DetectionRuleItem.Check32BitOn64System)
              "detectionType" = "modifiedDate"
          }            
          }
          "DateCreated" {
            [datatime]$InputObject = [datatime]$DetectionRuleItem.DateTimeValue
            $DateValueString = Get-Date -Year $InputObject.Year -Month $InputObject.Month -Day $InputObject.Day -Hour $InputObject.Hour -Minute $InputObject.Minute -Second $InputObject.Second -UFormat '+%Y-%m-%dT%H:%M:%S.000Z'   
            $DetectionRule = [ordered]@{
              "@odata.type" = "#microsoft.graph.win32LobAppFileSystemDetection"
              "operator" = $DetectionRuleItem.Operator
              "detectionValue" = $DateValueString
              "path" = $DetectionRuleItem.Path
              "fileOrFolderName" = $DetectionRuleItem.FileOrFolder
              "check32BitOn64System" = [System.Convert]::ToBoolean($DetectionRuleItem.Check32BitOn64System)
              "detectionType" = "createdDate"
          }                     
          }
          "Version" {
            $DetectionRule = [ordered]@{
              "@odata.type" = "#microsoft.graph.win32LobAppFileSystemDetection"
              "operator" = $DetectionRuleItem.Operator
              "detectionValue" = $DetectionRuleItem.VersionValue
              "path" = $DetectionRuleItem.Path
              "fileOrFolderName" = $DetectionRuleItem.FileOrFolder
              "check32BitOn64System" = [System.Convert]::ToBoolean($DetectionRuleItem.Check32BitOn64System)
              "detectionType" = "version"
          }            
          }
          "Size" {
            $DetectionRule = [ordered]@{
              "@odata.type" = "#microsoft.graph.win32LobAppFileSystemDetection"
              "operator" = $DetectionRuleItem.Operator
              "detectionValue" = $DetectionRuleItem.SizeInMBValue
              "path" = $DetectionRuleItem.Path
              "fileOrFolderName" = $DetectionRuleItem.FileOrFolder
              "check32BitOn64System" = [System.Convert]::ToBoolean($DetectionRuleItem.Check32BitOn64System)
              "detectionType" = "sizeInMB"
          }            
          }
        }
      }      
    }
    # Add detection rule to list
    $rules.Add($DetectionRule) | Out-Null    
  }  
  return $rules  
}