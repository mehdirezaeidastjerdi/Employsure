# # PowerShell Script for Moving Folders in SharePoint Online
# # Set source and destination URLs
# # Update-Module SharePointPnPPowerShellOnline
# $siteUrl = "https://employsure.sharepoint.com/sites/SharePointTesting"
# $sourceLibrary = "Shared Documents" 
# $destLibrary = "Archive"

# # Connect to SharePoint Online
# Connect-PnPOnline -Url $siteUrl -Interactive
# Write-Host "Checking source and destination Libraries..."
# Write-Host "Source URL: $sourceLibrary"
# Write-Host "Destination URL: $destLibrary"

# # Get folders that haven't been modified in 5 years
# $folders = Get-PnPFolder -List $sourceLibrary #| Where-Object { $_.TimeLastModified -lt (Get-Date).AddYears(-5) }

# # Move each folder to the destination library
# foreach ($folder in $folders) {
#     Write-Host "Moving folder $($folder.Name)..."
#     Move-PnPFolder -Folder $folder -TargetFolder $destLibrary 
# }

$FullSiteUrl = "https://employsure.sharepoint.com/sites/SharePointTesting"
Connect-PnPOnline -Url $FullSiteUrl -Interactive

# Specify the source and target document libraries
$SourceURL = "Shared Documents"
$TargetURL = "Archive"

# Get all items from the source library (excluding subfolders)
# $items = Get-PnPListItem -List $SourceURL
$items = Get-PnPListItem -List $SourceURL -Fields "FileLeafRef", "FSObjType" 
# Iterate through each item and copy files
foreach ($item in $items) {
    $fileLeafRef = $item.FieldValues.FileLeafRef
    $itemType = $item["FSObjType"]
    Write-Host "'$SourceURL/$fileLeafRef'"
    # Check if the item is a file or folder
    if ($itemType -eq 1) {
      Copy-PnPFile -SourceUrl $SourceURL/$fileLeafRef -TargetUrl $TargetURL/$fileLeafRef -Force 
    }
}




#Read more: https://www.sharepointdiary.com/2018/08/sharepoint-online-powershell-to-get-all-files-in-document-library.html#ixzz8V9g379kE
Disconnect-PnPOnline
