```ps
$vars = @{
  path = "C:\DevOps\ApplicationFactoryClient"
  createSecretVault = $true
  AppRegistrationClientID = "7da30c72-74e9-4c51-9938-f971eecfe673"
  AppRegistrationTenantID = "3308d5be-2e5b-4964-be18-0d6c3ee4c831"
  AppRegSecretName = "PSUAppRegSecretV2"
  AppRegSecretValue = "Test"
  APIEndpoint = "https://psu.purfidiom.com/AppFactoryClientV2"
  APISecretName = "PSUAPISecretV2"
  APISecretValue = "Test2"
}

New-AppFactoryClientSetup @vars
```