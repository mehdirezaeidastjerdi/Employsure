# In sharepoint, there are some restrictions on the position of characters within a file or folder name:
# You cannot use the period character consecutively in the middle of a file or folder name.
# The period character cannot be used at the end of a file or folder name.
# A file or folder name cannot start with a period character.
# If you use an underscore character (_) at the beginning of a file or folder name, it will be considered a hidden file or folder.
# ****************************************************************
# https://pnp.github.io/powershell/cmdlets/Rename-PnPFolder.html
# ****************************************************************
# Specify the SharePoint site URL
$siteUrl = "https://employsure.sharepoint.com/sites/SharePointTesting"
$siteName = "SharePointTesting" 
$libraryName = "DocLibrary1"
# Connect to SharePoint Online
Connect-PnPOnline -Url $siteUrl -Interactive

# Set the batch size
$BatchSize = 5000

try {
    # Get all files and folders in the document library (you can modify this to target a specific library)
    $items = Get-PnPListItem -List $libraryName -PageSize $BatchSize -Fields "FileLeafRef", "FSObjType" | Sort-Object Id -Descending
    # Construct the full server-relative URL
    $serverRelativeUrl = "/sites/$siteName/$libraryName"
    foreach ($item in $items) {
        $originalName = $item["FileLeafRef"]
        $itemType = $item["FSObjType"]
    
        # Replace invalid characters (including asterisk, colon, less than, greater than, question mark, forward slash, backslash, and pipe) with underscores
        # Allow space character
        $newName = $originalName -replace '[*:<>\\?/\\\\|]+', '_'
    
        # Remove leading and trailing underscores
        $newName = $newName.Trim('_').Trim()
    
        if ($originalName -ne $newName) {
            
            # Check if the item is a file or folder
            if ($itemType -eq 0) {
                # It's a file, rename it
                Rename-PnPFile -ServerRelativeUrl $serverRelativeUrl/$originalName -TargetFileName $newName -Force 
                Write-Host "Renamed file '$originalName' to '$newName'"
            }
            else {
                # It's a folder, handle it accordingly (e.g., log or skip)
                Rename-PnPFolder -Folder $libraryName/$originalName -TargetFolderName $newName
                Write-Host "Renamed folder '$originalName' to '$newName'"
            }
        }
    }
        
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

