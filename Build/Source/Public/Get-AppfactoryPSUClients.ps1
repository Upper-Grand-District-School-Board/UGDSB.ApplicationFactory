function Get-AppfactoryPSUClients {
  [cmdletbinding()]
  param()
  New-UDElement -Tag "figure" -ClassName "text-center" -Content {
    New-UDElement -Tag "h4" -ClassName "display-4" -Content { "Application Factory Clients" }
  }
  New-UDElement -Tag "div" -ClassName "container-fluid" -Content {
    New-UDElement -Tag "div" -ClassName "row justify-content-start" -Content {
      New-UDElement -Tag "div" -ClassName "col-7" -Content {
        New-UDElement -Tag "div" -ClassName "card-body rounded" -Content {
          New-UDTypography -Text "Client Lists" -Variant "h5" -ClassName "card-title rounded x-card-title"
          New-UDElement -Tag "div" -id "ClientList" -Content {
            New-UDDataGrid -id "ClientTableData" -LoadRows {
              Initialize-AppFactoryProcess -ApplicationServicePath $AppFactory_ApplicationPath
              Get-AppFactoryServiceClient | Select-Object -Property @{Label = "ID"; expression = { $_.GUID } }, Name, Contacts | Out-UDDataGridData -Context $EventData -TotalRows $Rows.Length
            } -Columns @(
              New-UDDataGridColumn -Field Name -Flex 1.5
              New-UDDataGridColumn -Field Contacts -Flex 1.5 -Render { $EventData.Contacts -join ", " }
            ) -StripedRows -AutoHeight $true -PageSize 1000 -DefaultSortColumn Name -OnSelectionChange {
              $TableData = Get-UDElement -Id "ClientTableData"
              $selectedRow = ((Get-UDElement -Id "ClientTableData").selection)[0]
              $selectedRowData = $TableData.Data.Rows | Where-Object {$_.ID -eq $selectedRow}
              Set-UDElement -id "clientNameText" -Properties @{
                Attributes = @{
                  value = $selectedRowData.Name
                  type  = "text"
                  class = "form-control"
                  classname = $null
                  placeholder = "Client Name"
                }
              }
              Set-UDElement -id "contactListTextArea" -Properties @{
                Tag = "textarea"
                Attributes = @{
                  value = ($selectedRowData.Contacts -join "`n")
                  type  = "text"
                  class = "form-control"
                  classname = $null
                  rows = 4
                  placeholder = "Contact List. One per line."
                }
              }  
              Set-UDElement -id "UpdateClient" -Properties @{
                Disabled = $false
              }
              Set-UDElement -id "deleteClient" -Properties @{
                Disabled = $false
              }    
            }  
          }
        }
      }
      New-UDElement -Tag "div" -ClassName "col-1" -Content {}
      New-UDElement -Tag "div" -ClassName "col-4" -Content {
        New-UDElement -Tag "div" -ClassName "card-body rounded" -Content {
          New-UDTypography -Text "Client Details" -Variant "h5" -ClassName "card-title rounded x-card-title"
          New-UDButton -Id "NewClient" -Text "New Client" -ClassName "btn btn-primary" -OnClick {
            $clientName = (Get-UDElement -id "clientNameText").Attributes.Value
            $contactList = (Get-UDElement -id "contactListTextArea").Attributes.Value -split "\n"
            if ([string]::IsNullOrEmpty($clientName)){
              Show-UDToast -Message "Client Name is Required" -Duration 5000 -Position "topCenter" -BackgroundColor "#FF0000"
              return
            }
            New-AppFactoryServiceClient -clientName $clientName -clientContacts $contactList
            Sync-UDElement -Id 'ClientTableData'
            Set-UDElement -id "clientNameText" -Properties @{
              Attributes = @{
                value = ""
                type  = "text"
                class = "form-control"
                classname = $null
                placeholder = "Client Name"
              }
            }
            Set-UDElement -id "contactListTextArea" -Properties @{
              Attributes = @{
                value = ""
                type  = "text"
                class = "form-control"
                classname = $null
                rows = 4
                placeholder = "Contact List. One per line."
              }
            }            
          }
          New-UDButton -Id "UpdateClient" -Text "Update Client" -ClassName "btn btn-primary" -Disabled -OnClick {
            Show-UDModal -MaxWidth lg -Content {
              $clientName = (Get-UDElement -id "clientNameText").Attributes.Value
              New-UDTypography -Text "Are you sure you want to update this client? $($clientName)" -Variant "h5"
              New-UDButton -Text "Yes"  -ClassName "btn btn-primary" -OnClick {
                $TableData = Get-UDElement -Id "ClientTableData"
                $selectedRow = ((Get-UDElement -Id "ClientTableData").selection)[0]
                $selectedRowData = $TableData.Data.Rows | Where-Object {$_.ID -eq $selectedRow}                
                $clientName = (Get-UDElement -id "clientNameText").Attributes.Value
                $contactList = (Get-UDElement -id "contactListTextArea").Attributes.Value -split "\n"
                $params = @{
                  clientGUID = $selectedRow
                }
                $updated = $false
                if(($contactList -join ", ") -ne $selectedRowData.renderedcontacts){
                  $updated = $true
                  $params.Add("clientContact",$contactList)
                }
                if($clientName -ne $selectedRowData.Name){
                  $updated = $true
                  $params.Add("clientName",$clientName)
                }
                if($updated){
                  Set-AppFactoryServiceClient @params
                  Sync-UDElement -Id 'ClientTableData'
                  Hide-UDModal
                }
              }
              New-UDButton -Text "No"  -ClassName "btn btn-primary" -OnClick {
                Hide-UDModal
              }              
            }
          }
          New-UDButton -Id "deleteClient" -Text "Delete Client" -ClassName "btn btn-primary" -Disabled -OnClick {
            Show-UDModal -MaxWidth lg -Content {
              $clientName = (Get-UDElement -id "clientNameText").Attributes.Value
              New-UDTypography -Text "Are you sure you want to delete this client? $($clientName)" -Variant "h5"
              New-UDButton -Text "Yes"  -ClassName "btn btn-primary" -OnClick {
                $clientGUID = ((Get-UDElement -Id "ClientTableData").selection)[0]
                Remove-AppFactoryServiceClient -clientGUID $clientGUID
                Sync-UDElement -Id 'ClientTableData'
                Set-UDElement -id "clientNameText" -Properties @{
                  Attributes = @{
                    value = ""
                    type  = "text"
                    class = "form-control"
                    classname = $null
                    placeholder = "Client Name"
                  }
                }
                Set-UDElement -id "contactListTextArea" -Properties @{
                  Attributes = @{
                    value = ""
                    type  = "text"
                    class = "form-control"
                    classname = $null
                    rows = 4
                    placeholder = "Contact List. One per line."
                  }
                }                             
                Hide-UDModal
              }
              New-UDButton -Text "No"  -ClassName "btn btn-primary" -OnClick {
                Hide-UDModal
              }
            }
          }
          New-UDElement -Tag "div" -ClassName "mb-3" -Content {
            New-UDElement -Tag "label" -Attributes @{
              for   = "Client Name"
              class = "form-label"
            } -Content {
              "Client Name"
            }
            New-UDElement -Tag "input" -id "clientNameText" -Attributes @{
              type        = "text"
              class       = "form-control"
              placeholder = "Client Name"
            }
          }
          New-UDElement -Tag "div" -ClassName "mb-3" -Content {
            New-UDElement -Tag "label" -Attributes @{
              for   = "Contact List"
              class = "form-label"
            } -Content {
              "Client List"
            }
            New-UDElement -Tag "textarea" -id "contactListTextArea" -Attributes @{
              rows        = "4"
              class       = "form-control"
              placeholder = "Contact List. One per line."
            }
          }          
        }
      }
    }
  }
}
<#
New-UDApp -Content { 
    $Rows = 1..100 | % {
        @{ Id = $_; Name = 'Adam'; Number = Get-Random}
    } 
    New-UDDataGrid -id DataGrid -LoadRows {  
    $Rows| Out-UDDataGridData -Context $EventData -TotalRows $Rows.Length
} -Columns @(
    New-UDDataGridColumn -Field name
    New-UDDataGridColumn -Field number
) -AutoHeight $true -Pagination -CheckboxSelection -CheckboxSelectionVisibleOnly -DisableRowSelectionOnClick
#>