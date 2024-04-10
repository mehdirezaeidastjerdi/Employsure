# Specify the name of your document library
$SiteName = "SharePointTesting"
$SourceURL = "Shared Documents"
$TargetURL = "Archive"
$DocumentLibrary = $SourceURL
$BatchSize = 2000
$SpecificDate = "2017-03-22"
$FullSiteUrl = "https://employsure.sharepoint.com/sites/SharePointTesting"
Connect-PnPOnline -Url $FullSiteUrl -UseWebLogin
try {
    Write-Host "Retrieve all files from the document library"
    $ListItems = Get-PnPListItem -List $DocumentLibrary -PageSize $BatchSize | Where-Object { $_["FileDirRef"] -eq "/sites/$SiteName/$DocumentLibrary"  } 
    Write-Host "Batch selected..."
    $AllFiles = @()
    # Enumerate all list items to get file details
    foreach ($Item in $ListItems) {
        $AllFiles += New-Object PSObject -Property @{
        FileName = $Item.FieldValues["FileLeafRef"]
        FileID = $Item.FieldValues["UniqueId"]
        FileType = $Item.FieldValues["File_x0020_Type"]
        Directory = $Item.FieldValues["FileDirRef"]
        RelativeURL = $Item.FieldValues["FileRef"]
        CreatedByEmail = $Item.FieldValues["Author"].Email
        CreatedTime = $Item.FieldValues["Created"]
        LastModifiedTime = $Item.FieldValues["Modified"]
        ModifiedByEmail = $Item.FieldValues["Editor"].Email
        FileSize_KB = [Math]::Round(($Item.FieldValues["File_x0020_Size"] / 1024), 2)
        }
    }

    # Export the file details to a CSV file
    $AllFiles | Export-Csv -Path "C:\temp\SharePointTesting.csv" -NoTypeInformation -Encoding UTF8

    Write-Host "SharePoint files report exported successfully" -ForegroundColor Green

    foreach ($File in $ListItems) {
      $fileLeafRef = $File.FieldValues.FileLeafRef
      Copy-PnPFile -SourceUrl $SourceURL/$fileLeafRef -TargetUrl $TargetURL/$fileLeafRef -Force
    }
    Write-Host "All files successfully copied to destination." -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Disconnect-PnPOnline