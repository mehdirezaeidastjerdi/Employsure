# Connect to SharePoint Online
Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/SharepointTestJembson" -Interactive

# Specify the document library name
$LibraryName = "Test"

# Set batch size (adjust as needed)
$BatchSize = 5000

Try {
    # Get all files from the document library
    $Files = Get-PnPListItem -List $LibraryName -PageSize $BatchSize | Sort-Object ID -Descending

    # Delete each file that starts with '~$'
    ForEach ($File in $Files) {
        if ($File.FieldValues.FileLeafRef.StartsWith("~$")) {
            Remove-PnPListItem -List $LibraryName -Identity $File.Id -Recycle -Force
            Write-Host "Removed Temp File: $($File.FieldValues.FileRef)"
        }
    }
} Catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
