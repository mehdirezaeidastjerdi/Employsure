
$SiteName = "SharePointTesting"
$SourceURL = "Shared Documents"
$TargetURL = "Archive"
$UnmatchedFilePath = "C:\temp\Unmatched_test.csv"
$FullSiteUrl = "https://employsure.sharepoint.com/sites/SharePointTesting"

# Connect to SharePoint Online
Connect-PnPOnline -Url $FullSiteUrl -Interactive

try {
    # Load the Excel data
    $Unmatched = Import-Csv -Path $UnmatchedFilePath

    # Iterate through each row in the Excel data
    foreach ($Row in $Unmatched.ClientTradingName) {
        
        $fileLeafRef = $Row  # Replace with the actual column name containing file names

        # Copy the file into the Target library
        Write-Host "Copying '$fileLeafRef' to '$TargetURL'"
        Copy-PnPFile -SourceUrl "$SourceURL/$fileLeafRef" -TargetUrl "$TargetURL/$fileLeafRef" -Force 
        # Wait for a few seconds (optional)
        Write-Host "'$ROw' successfully copied to the destination." -ForegroundColor Green
       

        # Check if the file exists in the target library
        $Folder = Get-PnPFolder -Url "$TargetURL/$fileLeafRef" -ErrorAction SilentlyContinue
        $File = Get-PnPFile -Url "$TargetURL/$fileLeafRef" -ErrorAction SilentlyContinue
        if ($Folder) {
            Write-Host "The folder '$Folder' exists in the target library."
            # Remove the folder from the source library
            Write-Host "Removing '$fileLeafRef' from '$SourceURL'"
            Remove-PnPFile -SiteRelativeUrl "$SourceURL/$fileLeafRef" -Force -Recycle
            Write-Host "Folder '$fileLeafRef' removed from the source library." -ForegroundColor Green
        }elseif ($File) {
            Write-Host "The file '$File' exists in the target library."
            # Remove the file from the source library
            Write-Host "Removing '$fileLeafRef' from '$SourceURL'"
            Remove-PnPFile -SiteRelativeUrl "$SourceURL/$fileLeafRef" -Force -Recycle
            Write-Host "File '$fileLeafRef' removed from the source library." -ForegroundColor Green
            
        }else {
            Write-Host "The file does not exist in the target library. Check the copy operation."
        }
    }
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}


