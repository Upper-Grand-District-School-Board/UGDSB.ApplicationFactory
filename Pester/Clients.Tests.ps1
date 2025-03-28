BeforeAll {
  # Because the Module Might change regulary, lets force it to reload
  Import-Module -Name "ApplicationFactory" -Force
  # Start the Application Factory Process
  Initialize-AppFactoryProcess -ApplicationServicePath "C:\DevOps\ApplicationFactoryApplications"
  # Read the configuration file into an object
  $configDetails = Get-Content -Path (Join-Path -Path "C:\DevOps\ApplicationFactoryApplications"-ChildPath "Configurations" -AdditionalChildPath "Configuration.json") -ErrorAction Stop | ConvertFrom-JSON  
  # Client Details that we are going to use to use in the test
  $clientTest = @{
    clientName = "Pester Test"
    clientContact = "pester@test.com","pester2@test.com"
  }
  $script:client = $null
}
Describe "New-AppFactoryClient" {
  It 'Create a new Client' {
    $script:client = New-AppFactoryClient @clientTest
    $script:client.Name | Should -Be "Pester Test"
    $script:client.Contacts -join "," | Should -Be "pester@test.com,pester2@test.com"
    Start-Sleep -Seconds 5
  }
  It 'Confirm created Azure Storage Container' {
    $storageAccountContext = New-AzStorageContext -StorageAccountName $configDetails.storage.deployments.name -StorageAccountKey (Get-Secret -Vault $configDetails.keyVault -Name $configDetails.storage.deployments.secret -AsPlainText)
    $container = Get-AzStorageContainer -Name $script:client.GUID -Context $storageAccountContext -ErrorAction "SilentlyContinue"
    $container | Should -Not -BeNullOrEmpty
  }
  It 'Confirm that we can read the details of the client' {
    $testclient = Get-AppFactoryClient -clientGUID $script:client.GUID
    $testclient.Name | Should -Be "Pester Test"
    $testclient.Contacts -join "," | Should -Be "pester@test.com,pester2@test.com"    
  }
  It 'Confirm that we can update the client details' {
    $updateClient = @{
      clientGUID = $script:client.GUID
      clientName = "Pester Test Updated"
      clientContact = "pester@test.com"
    }
    $testclient = Set-AppFactoryClient @updateClient
    $testclient.Name | Should -Be "Pester Test Updated"
    $testclient.Contacts -join "," | Should -Be "pester@test.com"
    Start-Sleep -Seconds 10
  }
  It 'Confirm that we can remove the client' {
    Remove-AppFactoryClient -clientGUID $script:client.GUID
    $testclient = Get-AppFactoryClient -clientGUID $script:client.GUID -ErrorAction "SilentlyContinue"
    $testclient | Should -BeNullOrEmpty
  }
}