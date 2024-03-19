# In sharepoint, there are some restrictions on the position of characters within a file or folder name:
# You cannot use the period character consecutively in the middle of a file or folder name.
# The period character cannot be used at the end of a file or folder name.
# A file or folder name cannot start with a period character.
# If you use an underscore character (_) at the beginning of a file or folder name, it will be considered a hidden file or folder.

# Specify the SharePoint site URL
$siteUrl = "https://employsure.sharepoint.com/sites/SharepointTestJembson"
$libraryName = "Test"
# Connect to SharePoint Online
Connect-PnPOnline -Url $siteUrl -UseWebLogin

# Get all files in the document library (you can modify this to target a specific library)
$files = Get-PnPListItem -List $libraryName -Fields "FileLeafRef"

foreach ($file in $files) {
    $originalFileName = $file["FileLeafRef"]

    # Replace invalid characters (including asterisk, colon, less than, greater than, question mark, forward slash, backslash, and pipe) with underscores
    $newFileName = $originalFileName -replace '[^\w\d*:<>\?/\\|]+', '_'

    # Remove leading and trailing underscores
    $newFileName = $newFileName.Trim('_')

    if ($originalFileName -ne $newFileName) {
        # Rename the file
        Rename-PnPFile -List "Documents" -Identity $file.Id -TargetFileName $newFileName
        Write-Host "Renamed file '$originalFileName' to '$newFileName'"
    }
}
