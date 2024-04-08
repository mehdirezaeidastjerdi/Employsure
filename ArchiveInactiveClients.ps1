# Update-Module -Name "SharePointPnPPowerShellOnline"
Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/hs_au" -UseWebLogin

# Specify the name of your document library
$SiteName = "hs_au"
$SourceURL = "Clients_DocLibrary"
$TargetURL = "Archive"
$DocumentLibrary = $SourceURL
$BatchSize = 2000

$SalesforceActiveClientsPath = "C:\temp\Salesforce Active Clients.csv"
$AllSarepointItemsPath = "C:\temp\test\AllSarepointItems.csv"
$MatchingItemsPath = "C:\temp\Matched.csv"
$UnmatchedItemsPath = "C:\temp\Unmatched.csv"
try {
        $timer = Measure-Command{
            Write-Host "Retrieve all files from the document library"
            # Retrieve all files from the document library
            $ListItems = Get-PnPListItem -List $DocumentLibrary -PageSize $BatchSize | Where-Object { $_["FileDirRef"] -eq "/sites/$SiteName/$DocumentLibrary" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/S" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/T" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/U" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/V" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/W" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/X" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/Y" `
            -or $_["FileDirRef"] -eq "/sites/$SiteName/$DocumentLibrary/Z"}
            Write-Host "Batch selected..."

            $AllSharepointItems = @()
            # Enumerate all list items to get file details
            foreach ($Item in $ListItems) {      
                    # Process items within specified folders
                    $AllSharepointItems += New-Object PSObject -Property @{
                    ClientTradingName = $Item.FieldValues["FileLeafRef"]
                    
                }
            }

            # Export the results to CSV
            $AllSharepointItems | Export-Csv -Path $AllSarepointItemsPath -NoTypeInformation
            Write-Host "All sharepoint Items exported to $AllSarepointItemsPath"
    }     
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Disconnect-PnPOnline






