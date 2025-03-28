function Invoke-Process{
  [CmdletBinding()]
  [OutputType([System.Collections.Generic.List[PSCustomObject]])]
  param(
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String]$FileName,
    [Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][String]$Arguments,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$CreateNoWindow = $false,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$UseShellExecute = $true,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$RedirectStandardOutput = $false,
    [Parameter()][ValidateNotNullOrEmpty()][bool]$RedirectStandardError = $false
  )
  try{
    $ProcessInfo = New-object -TypeName "System.Diagnostics.ProcessStartInfo"
    $ProcessInfo.FileName = $FileName
    $ProcessInfo.CreateNoWindow = $CreateNoWindow
    $ProcessInfo.UseShellExecute = $UseShellExecute
    $ProcessInfo.RedirectStandardOutput = $RedirectStandardOutput
    $ProcessInfo.RedirectStandardError = $RedirectStandardError
    $ProcessInfo.Arguments = $Arguments
    $Process = New-Object -TypeName "System.Diagnostics.Process"
    $Process.StartInfo = $ProcessInfo
    [void]$Process.Start()
    $Process.WaitForExit()
    return [PSCustomObject]@{
      ExitCode = $Process.ExitCode
    }    
  }
  catch{
    throw $_
  }
}