BeforeAll {
  # Because the Module Might change regulary, lets force it to reload
  Import-Module -Name "ApplicationFactory" -Force
  # Start the Application Factory Process
  Initialize-AppFactoryProcess -ApplicationServicePath "C:\DevOps\ApplicationFactoryApplications"
  # Read the configuration file into an object
  $configDetails = Get-Content -Path (Join-Path -Path "C:\DevOps\ApplicationFactoryApplications"-ChildPath "Configurations" -AdditionalChildPath "Configuration.json") -ErrorAction Stop | ConvertFrom-JSON  
  $script:TestApp1 = $null
  $script:commonAppParams = @{
    publisher                      = "Pester"
    notes                          = "This is a test application"
    owner                          = "ECNO"
    informationURL                 = "https://www.pester.com/info"
    PrivacyURL                     = "https://www.pester.com/privacy"
    ExtraFiles                     = "pester.txt"
    publishTo                      = "AAAA-BBBB-CCCC-DDDD"
    InstallExperience              = "System"
    DeviceRestartBehavior          = "Suppress"
    MinimumSupportedWindowsRelease = "W10_2004"
    Architecture                   = "All"
  }
}
Describe "New-AppFactoryApp PSADT" {
  It 'Create a new PSADT Application' {
    $psadtApplication = @{
      displayName                    = "Pester Test PSADT"
      description                    = "This is a pester test for PSADT type of appplication"
      AppSource                      = "PSADT" 
    }
    $script:TestApp1 = New-AppFactoryApp @script:commonAppParams @psadtApplication
    $script:TestApp1.Information.DisplayName | Should -Be "Pester Test PSADT"
    $script:TestApp1.Information.Description | Should -Be "This is a pester test for PSADT type of appplication"
    $script:TestApp1.Information.Publisher | Should -Be "Pester"
    $script:TestApp1.Information.Notes | Should -Be "This is a test application"
    $script:TestApp1.Information.owner | Should -Be "ECNO"
    $script:TestApp1.Information.informationURL | Should -Be "https://www.pester.com/info"
    $script:TestApp1.Information.PrivacyURL | Should -Be "https://www.pester.com/privacy"
    $script:TestApp1.SourceFiles.AppSource | Should -Be "PSADT"
    $script:TestApp1.SourceFiles.ExtraFiles | Should -Be "pester.txt"
    ($script:TestApp1.SourceFiles.publishTo -Join ",") | Should -Be "AAAA-BBBB-CCCC-DDDD"
    $script:TestApp1.Program.InstallExperience | Should -Be "System"
    $script:TestApp1.Program.DeviceRestartBehavior | Should -Be "Suppress"
    $script:TestApp1.Program.AllowAvailableUninstall | Should -Be $true
    $script:TestApp1.RequirementRule.MinimumSupportedWindowsRelease | Should -Be "W10_2004"
    $script:TestApp1.RequirementRule.Architecture | Should -Be "All"
  }
  It 'Read Application Cofniguration by display name' {
    $test = Get-AppFactoryApp -displayName "Pester Test PSADT"
    $test.GUID | Should -Be $script:TestApp1.GUID
  }
  It 'Read Application Cofniguration by appGUID' {
    $test = Get-AppFactoryApp -appGUID $script:TestApp1.GUID
    $test.Information.DisplayName | Should -Be "Pester Test PSADT"
  }
  It 'Update Application configuration' {
    $psadtApplication = @{
      appGUID     = $script:TestApp1.GUID
      description = "This is a pester test for PSADT type of appplication - Updated"
    }
    $script:TestApp1 = Set-AppFactoryApp @psadtApplication
    $script:TestApp1.Information.Description | Should -Be "This is a pester test for PSADT type of appplication - Updated"
  }
  It 'Remova PSADT Test Applications' {
    Remove-AppFactoryApp -appGUID $script:TestApp1.GUID
    $test = Get-AppFactoryApp -appGUID $script:TestApp1.GUID -ErrorAction "SilentlyContinue"
    $test | Should -BeNullOrEmpty
  }
}
Describe "New-AppFactoryApp ECNO" {
  It 'Create a new PSADT Application' {
    $ecnoApplication = @{
      displayName                    = "Pester Test ECNO"
      description                    = "This is a pester test for ECNO type of appplication"
      AppSource                      = "ECNO" 
    }
    $script:TestApp1 = New-AppFactoryApp @script:commonAppParams @ecnoApplication
    $script:TestApp1.Information.DisplayName | Should -Be "Pester Test ECNO"
    $script:TestApp1.SourceFiles.AppSource | Should -Be "ECNO"
  }
  It 'Remova ECNO Test Applications' {
    Remove-AppFactoryApp -appGUID $script:TestApp1.GUID
    $test = Get-AppFactoryApp -appGUID $script:TestApp1.GUID -ErrorAction "SilentlyContinue"
    $test | Should -BeNullOrEmpty
  }  
}
Describe "New-AppFactoryApp StorageAccount" {
  It 'Create a new Azure Storage Application' {
    $azureStorageParams = @{
      displayName                    = "Pester Test Azure Storage"
      description                    = "This is a pester test for Azure Storage type of appplication"
      AppSource                      = "StorageAccount" 
      appSetupName                   = "Pester.exe"
      storageContainerName           = "PesterTest"
    }
    $script:TestApp1 = New-AppFactoryApp @script:commonAppParams @azureStorageParams
    $script:TestApp1.Information.DisplayName | Should -Be "Pester Test Azure Storage"
    $script:TestApp1.Information.Description | Should -Be "This is a pester test for Azure Storage type of appplication"
    $script:TestApp1.SourceFiles.AppSource | Should -Be "StorageAccount"
    $script:TestApp1.SourceFiles.AppSetupFileName | Should -Be "Pester.exe"
    $script:TestApp1.SourceFiles.StorageAccountContainerName | Should -Be "PesterTest"
  }
  It 'Remova Azure Storage Test Applications' {
    Remove-AppFactoryApp -appGUID $script:TestApp1.GUID
    $test = Get-AppFactoryApp -appGUID $script:TestApp1.GUID -ErrorAction "SilentlyContinue"
    $test | Should -BeNullOrEmpty
  }  
}
Describe "New-AppFactoryApp Sharepoint" {
  It 'Create a new Sharepoint Application' {
    $sharepointParams = @{
      displayName                    = "Pester Test Sharepoint"
      description                    = "This is a pester test for Sharepoint type of appplication"
      AppSource                      = "Sharepoint" 
      appSetupName                   = "Pester.exe" 
    } 
    $script:TestApp1 = New-AppFactoryApp @script:commonAppParams @sharepointParams
    $script:TestApp1.Information.DisplayName | Should -Be "Pester Test Sharepoint"
    $script:TestApp1.Information.Description | Should -Be "This is a pester test for Sharepoint type of appplication"
    $script:TestApp1.SourceFiles.AppSource | Should -Be "Sharepoint"
    $script:TestApp1.SourceFiles.AppSetupFileName | Should -Be "Pester.exe"      
  }
  It 'Remova Azure Storage Test Applications' {
    Remove-AppFactoryApp -appGUID $script:TestApp1.GUID
    $test = Get-AppFactoryApp -appGUID $script:TestApp1.GUID -ErrorAction "SilentlyContinue"
    $test | Should -BeNullOrEmpty
  }    
}
Describe "New-AppFactoryApp Winget" {
  It 'Create a new Winget Application' {
    $wingetParams = @{
      displayName                    = "Pester Test Winget"
      description                    = "This is a pester test for Winget type of appplication"
      AppSource                      = "Winget" 
      appID                          = "Pester.Pester"
      appSetupName                   = "Pester.exe"
    }
    $script:TestApp1 = New-AppFactoryApp @script:commonAppParams @wingetParams
    $script:TestApp1.Information.DisplayName | Should -Be "Pester Test Winget"
    $script:TestApp1.Information.Description | Should -Be "This is a pester test for Winget type of appplication"
    $script:TestApp1.SourceFiles.AppSource | Should -Be "Winget"
    $script:TestApp1.SourceFiles.AppID | Should -Be "Pester.Pester"     
    $script:TestApp1.SourceFiles.AppSetupFileName | Should -Be "Pester.exe"      
  }
  It 'Remova Winget Test Applications' {
    Remove-AppFactoryApp -appGUID $script:TestApp1.GUID
    $test = Get-AppFactoryApp -appGUID $script:TestApp1.GUID -ErrorAction "SilentlyContinue"
    $test | Should -BeNullOrEmpty
  }   
}
Describe "New-AppFactoryApp Evergreen" {
  It 'Create a new Evergreen Application' {
    $evergreenParams = @{
      displayName                    = "Pester Test Evergreen"
      description                    = "This is a pester test for Evergreen type of appplication"
      AppSource                      = "Evergreen" 
      appID                          = "Pester.Pester"
      appSetupName                   = "Pester.exe"
      FilterOptions                  = @{
        Architecture = "x64"
      }
    } 
    $script:TestApp1 = New-AppFactoryApp @script:commonAppParams @evergreenParams
    $script:TestApp1.Information.DisplayName | Should -Be "Pester Test Evergreen"
    $script:TestApp1.Information.Description | Should -Be "This is a pester test for Evergreen type of appplication"
    $script:TestApp1.SourceFiles.AppSource | Should -Be "Evergreen"
    $script:TestApp1.SourceFiles.AppID | Should -Be "Pester.Pester"     
    $script:TestApp1.SourceFiles.AppSetupFileName | Should -Be "Pester.exe"           
    ($script:TestApp1.SourceFiles.FilterOptions | ConvertTo-JSON) | Should -Be "{
  `"Architecture`": `"x64`"
}"
  }
  It 'Remova Evergreen Test Applications' {
    Remove-AppFactoryApp -appGUID $script:TestApp1.GUID
    $test = Get-AppFactoryApp -appGUID $script:TestApp1.GUID -ErrorAction "SilentlyContinue"
    $test | Should -BeNullOrEmpty
  }    
}
Describe "New-AppFactoryApp LocalStorage" {
  It 'Create a new Local Storage Application' {
    $localStorageParams = @{
      displayName                    = "Pester Test Local Storage"
      description                    = "This is a pester test for Local Storage type of appplication"
      AppSource                      = "LocalStorage" 
      appSetupName                   = "Pester.exe"
      storageContainerName           = "c:\PesterTest"      
    }    
    $script:TestApp1 = New-AppFactoryApp @script:commonAppParams @localStorageParams
    $script:TestApp1.Information.DisplayName | Should -Be "Pester Test Local Storage"
    $script:TestApp1.Information.Description | Should -Be "This is a pester test for Local Storage type of appplication"
    $script:TestApp1.SourceFiles.AppSource | Should -Be "LocalStorage"
    $script:TestApp1.SourceFiles.AppSetupFileName | Should -Be "Pester.exe"
    $script:TestApp1.SourceFiles.StorageAccountContainerName | Should -Be "c:\PesterTest"
  }
  It 'Remova Local Stornage Test Applications' {
    Remove-AppFactoryApp -appGUID $script:TestApp1.GUID
    $test = Get-AppFactoryApp -appGUID $script:TestApp1.GUID -ErrorAction "SilentlyContinue"
    $test | Should -BeNullOrEmpty
  }   
}
