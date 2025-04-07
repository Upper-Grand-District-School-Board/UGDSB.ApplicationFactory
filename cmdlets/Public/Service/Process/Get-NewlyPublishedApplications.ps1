function Get-NewlyPublishedApplications {
  [CmdletBinding()]
  param(
    [Parameter()][datetime]$startDate = ((Get-Date).AddDays(-1)),
    [Parameter()][ValidateSet("Output", "Verbose")][string]$LogLevel = "Verbose"
  )
  # Connect to get graph token
  Get-GraphAccessToken -clientID $script:AppFactoryServiceClientID -tenantID $script:AppFactoryServiceTenantID -clientSecret (ConvertFrom-SecureString -SecureString $script:AppFactoryServiceSecret -AsPlainText) | Out-Null
  # Get the list of applications
  $UpdatedApplications = Get-AppFactoryApp -LogLevel $LogLevel | Where-Object { $null -ne $_.SourceFiles.LastUpdate -and $_.SourceFiles.LastUpdate -ne "" -and (Get-Date -Date $_.SourceFiles.LastUpdate) -ge $startDate }
  $Clients = Get-AppFactoryServiceClient -LogLevel $LogLevel
  foreach($client in $clients){
    $emailbody = [System.Collections.Generic.List[String]]::new()
    $emailBody.add("<html>")
    $emailBody.add("  <body>")
    $emailBody.add("    <h1>Newly Published Applications - Public</h1>")
    $emailBody.add("    <table style='width: 100%;'>")
    $emailBody.add("      <tr>")
    $emailbody.Add("        <th style='width: 33%;background-color:#c0c0c0;border:1px solid black;'>Application</th>")
    $emailbody.Add("        <th style='width: 33%;background-color:#c0c0c0;border:1px solid black;'>Version</th>")
    $emailbody.Add("        <th style='width: 33%;background-color:#c0c0c0;border:1px solid black;'>Updated</th>")
    $emailbody.Add("      </tr>")
    foreach($app in ($UpdatedApplications | Where-Object {-not $_.SourceFiles.publishTo})){
      $emailBody.add("      <tr>")
      $emailBody.Add("        <td>$($app.Information.DisplayName)</td>")
      $emailBody.Add("        <td>$($app.Information.AppVersion)</td>")
      $emailBody.Add("        <td>$($app.SourceFiles.LastUpdate)</td>")
      $emailBody.add("      </tr>")
    }
    $emailBody.add("    </table>")
    $emailBody.add("    <h1>Newly Published Applications - $($client.Name)</h1>")
    $emailBody.add("    <table style='width: 100%;'>")
    $emailBody.add("      <tr>")
    $emailbody.Add("        <th style='width: 33%;background-color:#c0c0c0;border:1px solid black;'>Application</th>")
    $emailbody.Add("        <th style='width: 33%;background-color:#c0c0c0;border:1px solid black;'>Version</th>")
    $emailbody.Add("        <th style='width: 33%;background-color:#c0c0c0;border:1px solid black;'>Updated</th>")
    $emailbody.Add("      </tr>")
    foreach($app in ($UpdatedApplications | Where-Object {$_.SourceFiles.publishTo})){
      if($client.guid -in $app.SourceFiles.publishTo){
        $emailBody.add("      <tr>")
        $emailBody.Add("        <td>$($app.Information.DisplayName)</td>")
        $emailBody.Add("        <td>$($app.Information.AppVersion)</td>")
        $emailBody.Add("        <td>$($app.SourceFiles.LastUpdate)</td>")
        $emailBody.add("      </tr>")  
      }
    }
    $emailBody.add("    </table>")    
    
    
    $emailBody.add("  </body>")
    $emailBody.add("</html>")
    if($client.Contacts){
      $params = @{
        from = $script:AppFactoryServiceSendMailAs
        subject = "Newly Published Applications"
        to = $clients.Contacts
        message = $emailbody
      }
      Send-GraphMailMessage @params
    }
  }


  
  #$UpdatedApplications.Information.DisplayName
}