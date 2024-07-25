

Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ListAvailable | Select Name,Version

Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force -AllowClobber

Update-Module -Name Microsoft.Online.SharePoint.PowerShell


Connect-SPOService -Url https://employsure-admin.sharepoint.com

$site_script = '
 {
   "$schema": "https://developer.microsoft.com/json-schemas/sp/site-design-script-actions.schema.json",
     "actions": [
       {
         "verb": "createSPList",
         "listName": "Customer Tracking",
         "templateType": 100,
         "subactions": [
           {
             "verb": "setDescription",
             "description": "List of Customers and Orders"
           },
           {
             "verb": "addSPField",
             "fieldType": "Text",
             "displayName": "Customer Name",
             "isRequired": false,
             "addToDefaultView": true
           },
           {
             "verb": "addSPField",
             "fieldType": "Number",
             "displayName": "Requisition Total",
             "addToDefaultView": true,
             "isRequired": true
           },
           {
             "verb": "addSPField",
             "fieldType": "User",
             "displayName": "Contact",
             "addToDefaultView": true,
             "isRequired": true
           },
           {
             "verb": "addSPField",
             "fieldType": "Note",
             "displayName": "Meeting Notes",
             "isRequired": false
           }
         ]
       }
     ]
 }
 '
Add-SPOSiteScript -Title "Create customer tracking list" -Content $site_script -Description "Creates list for tracking customer contact information"

Write-Host "Complete."