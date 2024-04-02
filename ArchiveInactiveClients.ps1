# Update-Module -Name "SharePointPnPPowerShellOnline"
Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/hs_au" -UseWebLogin

# Specify the name of your document library
$SiteName = "hs_au"
$SourceURL = "Clients_DocLibrary"
$TargetURL = "Archive"
$DocumentLibrary = $SourceURL
$BatchSize = 2000



try {
    $timer = Measure-Command{
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

    # Write-Host "All files:" -ForegroundColor Yellow
    # $AllFiles | Format-Table

    $AllFiles | Export-Csv -Path "C:\temp\AllFiles.csv" -NoTypeInformation
    }

    Write-host "Elaped time to get List of Items in DL : $($timer.TotalSeconds) seconds"
    $CsvData1 = Import-Csv -Path "C:\temp\All clients_old.csv"
    # Initialize arrays to store matching and unmatched items
    $MatchingItems = @()
    $timer = Measure-Command{
        # Loop through each item in the first CSV file
        foreach ($item in $CsvData1) {
            # Check if the item exists in the second CSV file
            $matchingItem = $AllFiles.ClientTradingName | Where-Object { $_ -match $item.Trading_Name__c }
            if ($matchingItem -and $matchingItem -isnot [array]) {
                # Add the matching item to the array
                $MatchingItems += New-Object PSObject -Property @{
                    ClientTradingName = $matchingItem.ToString()
                }       
            }
        }

        $UnmatchedItems = $AllFiles | Where-Object {$_.ClientTradingName -notin $MatchingItems.ClientTradingName}
        
        Write-Host "Matching items:" -ForegroundColor Green
        $MatchingItems | Format-Table

        Write-Host "Unmatched items:" -ForegroundColor Yellow
        $UnmatchedItems | Format-Table 
        # Export the matching and unmatched items to separate CSV files
        $MatchingItems | Export-Csv -Path "C:\temp\MatchedResult.csv" -NoTypeInformation
        $UnmatchedItems | Export-Csv -Path "C:\temp\UnmatchedResult.csv" -NoTypeInformation

        Write-host "Elaped time to compare items : $($timer.TotalSeconds) seconds"
    }
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Disconnect-PnPOnline
