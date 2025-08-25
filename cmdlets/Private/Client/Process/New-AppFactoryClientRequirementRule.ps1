function New-AppFactoryClientRequirementRule {
  [CmdletBinding()]
  [OutputType([ordered])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][PSCustomObject]$application,
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  # Construct table for supported architectures
  $ArchitectureTable = @{
    "x64" = "x64"
    "x86" = "x86"
    "All" = "x64,x86"
  }
  # Construct table for supported operating systems
  $OperatingSystemTable = @{
    "W10_1607" = "1607"
    "W10_1703" = "1703"
    "W10_1709" = "1709"
    "W10_1803" = "1803"
    "W10_1809" = "1809"
    "W10_1903" = "1903"
    "W10_1909" = "1909"
    "W10_2004" = "2004"
    "W10_20H2" = "2H20"
    "W10_21H1" = "21H1"
    "W10_21H2" = "Windows10_21H2"
    "W10_22H2" = "Windows10_22H2"
    "W11_21H2" = "Windows11_21H2"
    "W11_22H2" = "Windows11_22H2"
    "W11_23H2" = "Windows11_23H2"
  }  
  $RequirementRule = [ordered]@{
    "applicableArchitectures"        = $ArchitectureTable[$application.RequirementRule.Architecture]
    "minimumSupportedWindowsRelease" = $OperatingSystemTable[$application.RequirementRule.MinimumSupportedWindowsRelease]
  }
  if($application.RequirementRule.MinimumMemoryInMB){
    $RequirementRule.Add("MinimumMemoryInMB", $application.RequirementRule.MinimumMemoryInMB)
  }
  if($application.RequirementRule.MinimumFreeDiskSpaceInMB){
    $RequirementRule.Add("MinimumFreeDiskSpaceInMB", $application.RequirementRule.MinimumFreeDiskSpaceInMB)
  }  
  return $RequirementRule
}