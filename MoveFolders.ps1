# PowerShell Script for Moving Folders in SharePoint Online
# Set source and destination URLs
# Update-Module SharePointPnPPowerShellOnline
$siteUrl = "https://employsure.sharepoint.com/sites/SharePointTesting"
$sourceLibrary = "Shared Documents" 
$destLibrary = "Archive"

# Connect to SharePoint Online
Connect-PnPOnline -Url $siteUrl -Interactive
Write-Host "Checking source and destination Libraries..."
Write-Host "Source URL: $sourceLibrary"
Write-Host "Destination URL: $destLibrary"

# Get folders that haven't been modified in 5 years
$folders = Get-PnPFolder -List $sourceLibrary #| Where-Object { $_.TimeLastModified -lt (Get-Date).AddYears(-5) }

# Move each folder to the destination library
foreach ($folder in $folders) {
    Write-Host "Moving folder $($folder.Name)..."
    Move-PnPFolder -Folder $folder -TargetFolder $destLibrary 
}
