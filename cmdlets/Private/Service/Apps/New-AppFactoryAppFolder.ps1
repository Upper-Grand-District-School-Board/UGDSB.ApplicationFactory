<#
  .DESCRIPTION
  This cmdlet is designed to create a new application to be handled by the automated process
  .PARAMETER DisplayName
  The DisplayName of the application that we are creating
  .PARAMETER force
  Continue even if the folder already exists, overwriting the current details
  .PARAMETER LogLevel
  If logging is enabled, what level of logging do we want, default is verbose.

  .EXAMPLE

  Create a new application folder
  New-AppFactoryAppFolder -DisplayName "### DisplayName ###" -LogLevel "Output"
#>
function New-AppFactoryAppFolder {
  [CmdletBinding()]
  [OutputType([string])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String]$DisplayName,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String]$folderName,
    [Parameter()][bool]$force,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  # Path to the new app folder
  $appFolderPath = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps" -AdditionalChildPath $folderName
  if ($script:AppFactoryLogging) {
    Write-PSFMessage -Message "[$($DisplayName)] Template folder used <c='green'>$($script:AppFactorySupportTemplateFolder)</c>" -Level $LogLevel -Tag "Application", "$($DisplayName)" -Target "Application Factory Service"
  }
  # Create New Application Folder
  try {
    if ((Test-Path $appFolderPath) -and -not $force) {
      throw "Folder Already Exists $($script:AppFactorySupportTemplateFolder) and force was not set"
    }
    New-Item -Path $appFolderPath -ItemType Directory -Force | Out-Null
    Write-PSFMessage -Message "[$($DisplayName)] Created application folder <c='green'>$($appFolderPath)</c>" -Level $LogLevel -Tag "Application", "$($DisplayName)" -Target "Application Factory Service"
  }
  catch {
    Write-PSFMessage -Message "Error Encountered: $($_)" -Level "Error" -Tag "Application", "$($DisplayName)" -Target "Application Factory Service"
    throw $_
  }
  try {
    # Placeholder Icon File
    $iconFile = Join-Path -Path $script:AppFactorySupportTemplateFolder -ChildPath "PSADT" -AdditionalChildPath "Assets", "AppIcon.png"
    Copy-Item -Path $iconFile -Destination "$($appFolderPath)\Icon.png" -ErrorAction Stop -Force
    Write-PSFMessage -Message "[$($DisplayName)] Copying Placeholder Icon file to <c='green'>$($appFolderPath)</c>" -Level $LogLevel -Tag "Application", "$($DisplayName)" -Target "Application Factory Service"
  }
  catch {
    Remove-Item -Path $appFolderPath -Force
    Write-PSFMessage -Message "Error Encountered: $($_)" -Level "Error" -Tag "Application", "$($DisplayName)" -Target "Application Factory Service"
    throw $_    
  }
  return $appFolderPath
}