# Connect to SharePoint Online
Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/SharePointTesting" -Interactive

# Specify the document library name
$LibraryName = "DocLibrary1"

# Set batch size (adjust as needed)
$BatchSize = 100
$counter = 0
Try {
    # Get all files from the document library
    $Files = Get-PnPListItem -List $LibraryName -PageSize $BatchSize | Sort-Object ID -Descending

    Write-Host "Deleting each file that starts with '~$'"
    ForEach ($File in $Files) {
        if ($File.FieldValues.FileLeafRef.StartsWith("~$")) {
            Remove-PnPListItem -List $LibraryName -Identity $File.Id -Recycle -Force
            $counter = $counter + 1
            Write-Host "$counter files Removed from document library."
            
        }       
    }
} Catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}







