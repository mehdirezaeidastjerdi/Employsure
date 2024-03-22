
Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/SharePointTesting" -UseWebLogin

# Specify the name of your document library
$SiteName = "SharePointTesting"
$SourceURL = "Shared Documents"
$TargetURL = "Archive"
$DocumentLibrary = "Shared Documents"

Write-Host "Retrieve all files from the document library"
$ListItems = Get-PnPListItem -List $DocumentLibrary -PageSize 2000 | Where-Object { $_["FileDirRef"] -eq "/sites/$SiteName/$DocumentLibrary" } 
Write-Host "Batch selected..."
# Enumerate all list items to get file details

foreach ($File in $ListItems) {
      $fileLeafRef = $File.FieldValues.FileLeafRef
      Write-Host "'$fileLeafRef'"
      Copy-PnPFile -SourceUrl $SourceURL/$fileLeafRef -TargetUrl $TargetURL/$fileLeafRef -Force
}

Write-Host "Document library successfully copied to destination." -ForegroundColor Green

Disconnect-PnPOnline