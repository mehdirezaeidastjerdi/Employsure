# Update-Module -Name "SharePointPnPPowerShellOnline"
Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/SharePointTesting" -UseWebLogin

# Specify the name of your document library
$SiteName = "SharePointTesting"
$SourceURL = "Shared Documents"
$TargetURL = "Archive"
$DocumentLibrary = $SourceURL
$BatchSize = 2000

$CsvAllClientsPath = "C:\temp\All clients_old.csv"
$OutputCsvPath = "C:\temp\OutputResult.csv"

try {
    Write-Host "Retrieve all files from the document library"
    $ListItems = Get-PnPListItem -List $DocumentLibrary -PageSize $BatchSize | Where-Object { $_["FileDirRef"] -eq "/sites/$SiteName/$DocumentLibrary" }
    Write-Host "Batch selected..."

    $AllFiles = @()

    # Enumerate all list items to get file details
    foreach ($Item in $ListItems) {
        $AllFiles += New-Object PSObject -Property @{
            ClientTradingName = $Item.FieldValues["FileLeafRef"]
        }
    }

    $CsvData1 = Import-Csv -Path $CsvAllClientsPath

    # Initialize arrays to store matching and unmatched items
    $MatchingItems = @()
    $UnmatchedItems = @()

    # Loop through each item in the first CSV file
    foreach ($item in $CsvData1[0..99]) {
        # Check if the item exists in the second CSV file
        $matchingItem = $AllFiles.ClientTradingName | Where-Object { $_ -match $item.Trading_Name__c }
        if ($matchingItem) {
            # Add the matching item to the array
            $MatchingItems += New-Object PSObject -Property @{
                ClientTradingName = $matchingItem
            }
        } else {
            # Add the unmatched item to the array
            $UnmatchedItems += New-Object PSObject -Property @{
                ClientTradingName = $item.Trading_Name__c
            }
        }
    }

    Write-Host "Matching items:" -ForegroundColor Green
    $MatchingItems | Format-Table

    Write-Host "Unmatched items:" -ForegroundColor Yellow
    $UnmatchedItems | Format-Table

    # Export the matching and unmatched items to separate CSV files
    $MatchingItems | Export-Csv -Path $OutputCsvPath -NoTypeInformation
    $UnmatchedItems | Export-Csv -Path "C:\temp\UnmatchedResult.csv" -NoTypeInformation
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Disconnect-PnPOnline
