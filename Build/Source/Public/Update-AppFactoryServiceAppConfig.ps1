function Update-AppFactoryServiceAppConfig{
  [cmdletbinding()]
  param()
  $ApplicationsPath = Join-Path -Path $script:AppFactorySourceDir -ChildPath "Apps"
  $TemplatePath = Join-Path -Path $script:AppFactorySupportTemplateFolder -ChildPath "Application" -AdditionalChildPath "ApplicationConfig.json"
  $AllApps = Get-ChildItem -Path $ApplicationsPath -Filter "ApplicationConfig.json" -Recurse
  $TemplateSections = @("Information","SourceFiles","Install","Uninstall")
  $Template = Get-Content -Path $TemplatePath -Raw | ConvertFrom-JSON -Depth 10
  foreach($app in $AllApps){
    $AppDetails = Get-Content -path $app.FullName -Raw | ConvertFrom-JSON -Depth 10
    foreach($obj in $TemplateSections){
      $properties = $Template.$obj | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
      foreach($property in $properties){
        if(-not ($AppDetails.$obj.PSObject.Properties.Name -contains $property)){
          $AppDetails.$obj | Add-Member -MemberType NoteProperty -Name $property -Value $Template.$obj.$property
        }
      }
    }
    $AppDetails | ConvertTo-JSON -depth 10 | Out-File -FilePath $app.FullName -Force
  } 
}