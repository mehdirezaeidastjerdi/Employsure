
# Resource: https://learn.microsoft.com/en-us/sharepointmigration/overview-spmt-ps-cmdlets
# Define SharePoint target
$SPOUrl = "https://employsure.sharepoint.com/sites/Testsite"
$TargetListName = "Shared Documents"


# Define File Share data source
$FileshareSource = "\\hsvmempdc1\Modified Clients\ACT Interiors_EMP23211"

# Import SPMT Migration Module
Import-Module "C:\Users\Mehdi.Rezaei\Documents\WindowsPowerShell\Modules\Microsoft.SharePoint.MigrationTool.PowerShell"

# Register the SPMT session with SharePoint credentials
Register-SPMTMigration -Force

# Verify the target site and document library
$siteExists = (Invoke-WebRequest -Uri $SPOUrl -UseDefaultCredentials).StatusCode
if ($siteExists -eq 200) {
    Write-Output "Target site exists. Proceeding with migration."
    
    # Add a task to the session
    Add-SPMTTask -FileShareSource $FileshareSource -TargetSiteUrl $SPOUrl -TargetList $TargetListName

    # Start Migration
    Start-SPMTMigration
} else {
    Write-Error "The target site $SPOUrl does not exist."
}
