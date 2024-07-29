
# Reference: https://learn.microsoft.com/en-us/sharepoint/dev/declarative-customization/site-design-json-schema
#Get-Module -Name Microsoft.Online.SharePoint.PowerShell -ListAvailable | Select Name,Version

#Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force -AllowClobber

Import-Module -Name Microsoft.Online.SharePoint.PowerShell


Connect-SPOService -Url https://employsure-admin.sharepoint.com

 $site_script2 = '
 {
   "$schema": "https://developer.microsoft.com/json-schemas/sp/site-design-script-actions.schema.json",
   "actions": [
   {
      "verb": "setSiteExternalSharingCapability",
      "capability": "ExternalUserSharingOnly"
   },
   {
      "verb": "setRegionalSettings", 
      "timeZone": 76, /* Canberra, Melbourne, Sydney */
      "locale": 3081, /* Australia */
      "sortOrder": 25, /* General */
      "hourFormat": "24"
   },
    {
        "verb": "setSiteLogo", /*This action only works on the communication site template (68).*/
        "url": "https://employsureintune.blob.core.windows.net/intune-public/Images/Secondary-Peninsula-Logo-RGB_Peninsula-Red 1.png"
    },
    {
      "verb": "setSiteBranding",
      "navigationLayout": "Cascade",
      "headerLayout": "Compact",
      "headerBackground": "None",
      "showFooter": true
    }
   ]
 }
'
Add-SPOSiteScript -Title "Creates a custom template" -Content $site_script2 -Description "Creates a custom template"
Add-SPOSiteDesign -Title "Employsure hub site template V2" -WebTemplate "64" -SiteScripts "8806dd5b-2ff3-4a6c-ac7b-d85f631ec498" -Description "change logo, External sharing, reginal setting and branding"
Remove-SPOSiteDesign "c1c9971d-20c8-4759-b1f4-81e3963e1a73" #Remove a custome template by it's ID
Get-SPOSiteDesign
Write-Host "Complete."