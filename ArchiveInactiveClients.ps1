# Update-Module -Name "SharePointPnPPowerShellOnline"
Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/hs_au" -UseWebLogin

# Specify the name of your document library
$SiteName = "hs_au"
$SourceURL = "Clients_DocLibrary"
$TargetURL = "Archive"
$DocumentLibrary = $SourceURL
$BatchSize = 2000

$SalesforceActiveClientsPath = "C:\temp\Salesforce Active Clients.csv"
$AllSarepointItemsPath = "C:\temp\AllSarepointItems.csv"
$MatchingItemsPath = "C:\temp\MatchedClients.csv"
$UnmatchedItemsPath = "C:\temp\UnmatchedClients.csv"
try {
    $timer = Measure-Command{
    #     Write-Host "Retrieve all files from the document library"
    #     $ListItems = Get-PnPListItem -List $DocumentLibrary -PageSize $BatchSize | Where-Object { $_["FileDirRef"] -eq "/sites/$SiteName/$DocumentLibrary" }
    #     Write-Host "Batch selected..."

    #     $AllSarepointItems = @()

    #     # Enumerate all list items to get file details
    #     foreach ($Item in $ListItems) {
    #         $AllSarepointItems += New-Object PSObject -Property @{
    #             ClientTradingName = $Item.FieldValues["FileLeafRef"]
    #         }
    # }

    # # Write-Host "All files:" -ForegroundColor Yellow
    # # $AllSarepointItems | Format-Table

    # $AllSarepointItems | Export-Csv -Path $AllSarepointItemsPath -NoTypeInformation
    }
    Write-host "Importing all sharepoint document library items..."
    $AllSarepointItems = Import-Csv -Path $AllSarepointItemsPath    
    Write-host "Elaped time to get List of all Items in DL : $($timer.TotalSeconds) seconds"
    $CsvData1 = Import-Csv -Path $SalesforceActiveClientsPath
    # Initialize arrays to store matching and unmatched items
    $MatchingItems = @()
    $timer = Measure-Command{
        # Loop through each item in the first CSV file
        foreach ($item in $CsvData1[0..99]) {
            # Check if the item exists in the second CSV file
            $matchingItem = $AllSarepointItems.ClientTradingName | Where-Object { $_ -match $item.Trading_Name__c -or $_ -match $item.Employsure_Client__c}
            if ($matchingItem -and $matchingItem -isnot [array]) {
                # Add the matching item to the array
                $MatchingItems += New-Object PSObject -Property @{
                    ClientTradingName = $matchingItem.ToString()
                }       
            }
        }

        $UnmatchedItems = $AllSarepointItems | Where-Object {$_.ClientTradingName -notin $MatchingItems.ClientTradingName}        
    }
    Write-host "Elaped time to compare items : $($timer.TotalSeconds) seconds"
    Write-Host "Matching items:" -ForegroundColor Green
    $MatchingItems | Format-Table

    Write-Host "Unmatched items:" -ForegroundColor Yellow
    $UnmatchedItems | Format-Table 
    # Export the matching and unmatched items to separate CSV files
    $MatchingItems | Export-Csv -Path $MatchingItemsPath -NoTypeInformation
    $UnmatchedItems | Export-Csv -Path $UnmatchedItemsPath -NoTypeInformation
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Disconnect-PnPOnline
