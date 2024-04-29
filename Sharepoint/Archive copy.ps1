
$SourceSite = "hs_au"
$SourceLib = "Clients_DocLibrary"

$DestSite = "hs_au_copy"
$DestLib = "Clients_Copy"

$MatchedFilePath = "C:\temp\test2\Matched - Copy.csv"

$SourceSiteUrl = "https://employsure.sharepoint.com/sites/$SourceSite"
$DestSiteUrl = "https://employsure.sharepoint.com/sites/$DestSite"
# Connect to SharePoint Online
Connect-PnPOnline -Url $SourceSiteUrl -Interactive
Connect-PnPOnline -Url $DestSiteUrl -Interactive
# Load the Excel data

$Matched = Import-Csv $MatchedFilePath

try {
  
    foreach ($Row in $Matched) {
        $fileLeafRef = $Row.'ClientTradingName'  # Replace with the actual column name containing file names
        Write-Host "Copying $fileLeafRef to destination"
        Copy-PnPFile -SourceUrl "/sites/$SourceSite/$SourceLib/$fileLeafRef" -TargetUrl "/sites/$DestSite/$DestLib" -Force
    }

    Write-Host "All files successfully copied to destination." -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Disconnect-PnPOnline