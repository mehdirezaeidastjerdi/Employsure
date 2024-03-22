
Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/SharePointTesting" -UseWebLogin

$AllFiles = @()


# Specify the name of your document library
$SourceURL = "Shared Documents"
$TargetURL = "Archive"
$DocumentLibrary = "Shared Documents"

Write-Host "Retrieve all files from the document library"
$ListItems = Get-PnPListItem -List $DocumentLibrary -PageSize 2000 | Where-Object { $_["FileDirRef"] -eq "/sites/SharePointTesting/$DocumentLibrary" } 
Write-Host "Batch selected..."
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

foreach ($File in $ListItems) {
    $fileLeafRef = $File.FieldValues.FileLeafRef
      Write-Host "'$fileLeafRef'"
      Copy-PnPFile -SourceUrl $SourceURL/$fileLeafRef -TargetUrl $TargetURL/$fileLeafRef -Force
    # }
}

# Export the file details to a CSV file
$AllFiles | Export-Csv -Path "C:\temp\SharePointTesting.csv" -NoTypeInformation -Encoding UTF8

Write-Host "SharePoint files report exported successfully" -ForegroundColor Green
Disconnect-PnPOnline