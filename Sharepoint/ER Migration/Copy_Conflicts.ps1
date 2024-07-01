$SourceSite = "ER"
$SourceLib = "Clients"
$DestSite = "hs_au"
$DestLib = "Clients_DocLibrary"
$ConflictFolder = "ER Conflicts"
$NotExistInSourceItemsPath = "C:\temp\ER\Conflicts\NotExistInSourceItems.csv"
$ConflictedItemsPath = "C:\temp\ER\Conflicts\ConflictedItems2.csv"
$CopiedItemsPath= "C:\temp\ER\Conflicts\copiedItems.csv"
$SourceSiteUrl = "https://employsure.sharepoint.com/teams/$SourceSite"
$DestSiteUrl = "https://employsure.sharepoint.com/sites/$DestSite"

# Connect to SharePoint Online
Connect-PnPOnline -Url $DestSiteUrl -Interactive
Connect-PnPOnline -Url $SourceSiteUrl -Interactive

# Load the CSV data
$Conflicts = Import-Csv $ConflictedItemsPath

$NotExistInSourceItems = @()
$CopiedItems = @()

foreach ($Row in $Conflicts) {
    $fileLeafRef = $Row.'ClientTradingName'  # Replace with the actual column name containing file names
    $fileExists = Get-PnPFile -Url "$SourceLib/$fileLeafRef" -ErrorAction SilentlyContinue
    $FolderExists = Get-PnpFolder -Url "$SourceLib/$fileLeafRef" -ErrorAction SilentlyContinue 

    $details = @{
        "ClientTradingName" = $fileLeafRef
    }

    # Check if the item exists in the source library
    if ($fileExists -or $FolderExists) {
        Write-Host "Copying $fileLeafRef to destination..."
        try {
            # Try to copy the file to the destination
            Copy-PnPFile -SourceUrl "/teams/$SourceSite/$SourceLib/$fileLeafRef" -TargetUrl "/sites/$DestSite/$DestLib/$ConflictFolder" -Force 
            Write-Host "'$fileLeafRef' copied to destination!" -ForegroundColor Green
            $CopiedItems += New-Object PSObject -Property $details
        } catch {
            $errorMessage = $_.Exception.Message
            Write-Host "Error copying $fileLeafRef $errorMessage" -ForegroundColor Red
        }
    } else {
        Write-Host "'$fileLeafRef' does not exist in source library!" -ForegroundColor Yellow
        $NotExistInSourceItems += New-Object PSObject -Property $details
    }
}

Write-Host "Copied items:" -BackgroundColor Green
$CopiedItems | Format-Table

Write-Host "Not exist in source library items ($SourceLib):" -BackgroundColor Yellow
$NotExistInSourceItems | Format-Table


# Export copied, non-existent, and conflict items to CSV
$CopiedItems | Export-Csv -Path $CopiedItemsPath -NoTypeInformation
$NotExistInSourceItems | Export-Csv -Path $NotExistInSourceItemsPath -NoTypeInformation

Write-Host "Copying process finished and files exported." -ForegroundColor Blue
# Disconnect from SharePoint Online
Disconnect-PnPOnline
