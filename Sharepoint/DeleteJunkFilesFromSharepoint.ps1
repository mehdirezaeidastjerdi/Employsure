# Connect to SharePoint Online
Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/hs_au" -UseWebLogin

# Specify the document library name
$LibraryName = "Clients_DocLibrary"

# Set batch size (adjust as needed)
$BatchSize = 2000
$counter = 0
# Try {
    # Get all files from the document library
    Write-Host "Getting list of all files. The batch size is '$BatchSize'"
    $Files = Get-PnPListItem -List $LibraryName -PageSize $BatchSize | Sort-Object ID -Descending
    Write-Host "Deleting each file that starts with '~$'"
    ForEach ($File in $Files) {
        if ($File.FieldValues.FileLeafRef.StartsWith("~$")) {
            Remove-PnPListItem -List $LibraryName -Identity $File.Id -Recycle -Force
            Write-Host "Deleted file: $($File.FieldValues.FileLeafRef)"         
        }       
    # }
# } Catch {
    # Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
# }
# Write-Host "$counter files Removed from document library."
    }

Disconnect-PnPOnline




