# Connect to SharePoint Online
$SourceSite = "hs_au_copy"
$SiteUrl = "https://employsure.sharepoint.com/sites/$SourceSite"
Connect-PnPOnline -Url $SiteUrl -Interactive

# Specify the name or URL of the document library to restore
$LibraryName = "Test Library"

# Get the recycle bin items for the specified library
$RecycleBinItems = Get-PnPRecycleBinItem -SecondStage | Where-Object { $_.LeafName -eq "Test Library" -and $_.ItemType -eq 'List'}

$RecycleBinItems

Restore-PnPRecycleBinItem -Identity $item.Id

if ($RecycleBinItems.Count -gt 0) {
    # foreach ($item in $RecycleBinItems) {
        Write-Host "Restoring item $($item.LeafName)..."
        Restore-PnPRecycleBinItem -Identity $item.Id
        Write-Host "Item $($item.LeafName) restored successfully!" -ForegroundColor Green
    # }
} else {
    Write-Host "No items found in the recycle bin for library '$LibraryName'." -ForegroundColor Yellow
}

# Disconnect from SharePoint Online
Disconnect-PnPOnline


# $SourceSite = "hs_au_copy"
# $SiteUrl = "https://employsure.sharepoint.com/sites/$SourceSite"
# Connect-PnPOnline -Url $SiteUrl -Interactive

# # Get all recycle bin items
# $RecycleBinItems = Get-PnPRecycleBinItem -SecondStage

# # Display information about each recycle bin item
# foreach ($item in $RecycleBinItems) {
#     Write-Host "Item Title: $($item.Title)"
#     Write-Host "Item Type: $($item.ItemType)"
#     Write-Host "Item Location: $($item.DirName)"
#     Write-Host "Item Deletion Time: $($item.DeletedDate)"
#     Write-Host "------------------------------------"
# }

# Disconnect from SharePoint Online
# Disconnect-PnPOnline




$SourceSite = "hs_au_copy"
$SiteUrl = "https://employsure.sharepoint.com/sites/$SourceSite"

# Restore item from recycle bin
$itemId = "5075e1af-7c79-4951-b857-fd4a1136ced2" 
Restore-PnPRecycleBinItem -Identity $itemId

# Disconnect from SharePoint Online
Disconnect-PnPOnline
