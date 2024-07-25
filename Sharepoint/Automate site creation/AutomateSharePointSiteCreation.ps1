<#
Resources:
https://www.c-sharpcorner.com/article/provisioning-sites-from-site-designs-using-pnp-powershell-pros-consof-using/
https://www.c-sharpcorner.com/article/automate-sharepoint-site-creation-with-powershell-and-pnp/
https://learn.microsoft.com/en-us/sharepoint/dev/declarative-customization/site-design-overview
https://www.sharepointdiary.com/2019/06/sharepoint-online-apply-theme-using-pnp-provisioning-template.html
#>
# Source Site URL input
$SourceSiteURL = "https://employsure.sharepoint.com"

# Path to XML file
$SchmaXMLPath = "C:\temp\SiteSchema.xml"

# Connect to PnP Online to take template backup
Connect-PnPOnline -Url $SourceSiteURL -Interactive

# Get Site Schema and save to file
Get-PnPSiteTemplate -Out $SchmaXMLPath -Handlers Lists -ExcludeHandlers "SiteSecurity,TermGroups,Fields,ContentTypes" -Force
# Take Admin center URL as input
$AdminCenterURL = "https://employsure-admin.sharepoint.com"

# Connect to admin center
Connect-PnPOnline -Url $AdminCenterURL -Interactive

# Variables
$SiteName = "TestSiteFromTemplate"
$SiteURL = "https://employsure.sharepoint.com/sites/TestSiteFromTemplate"

# # Create new site
$NewWeb = New-PnPSite -Title $SiteName -Url $SiteURL -Type CommunicationSite

# Remove-PnPTenantSite -Url https://employsure.sharepoint.com/sites/TestSiteFromTemplate -Force
# Unregister-PnPHubSite -Site "https://employsure.sharepoint.com/sites/TestSiteFromTemplate"


# Connect to PnP Online to destination site
Connect-PnPOnline -Url $SiteURL -Interactive
# Apply PnP Provisioning Template
Invoke-PnPSiteTemplate -Path $SchmaXMLPath 
Write-Host "Template applied successfully."

