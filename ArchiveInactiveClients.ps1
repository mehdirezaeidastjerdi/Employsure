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
    
    $timer = Measure-Command{

        $ListItems = Get-PnPListItem -List $DocumentLibrary -PageSize $BatchSize | Where-Object { $_["FileDirRef"] -eq "/sites/$SiteName/$DocumentLibrary" } 
        Write-Host "Batch selected..."
    
        $AllFiles = @()
        
        # Enumerate all list items to get file details
        foreach ($Item in $ListItems) {
            $AllFiles += New-Object PSObject -Property @{
                ClientTradingName = $Item.FieldValues["FileLeafRef"]   
            }
        }

        $AllFiles | Export-Csv -Path "C:\temp\AllFiles.csv"

    }

    Write-host "Elaped time to get ListItems : $($timer.TotalSeconds) seconds"
    
    
    # get list of all active clients from csv file
    $CsvData1 = Import-Csv -Path $CsvAllClientsPath
    

    # Initialize an array to store matching items
    $MatchingItems = @()

    Write-Host "Comparing Items with all active clients..."

    $timer = Measure-Command{
        # Loop through each item in the first CSV file
        foreach ($item in $CsvData1[0..1000]) {
            # Check if the item exists in the second CSV file
            $matchingItem = $AllFiles.ClientTradingName | Where-Object { $_ -match $item.Trading_Name__c}
            if ($matchingItem) {
                # Add the matching item to the array
                $MatchingItems += New-Object PSObject -Property @{
                    ClientTradingName = $matchingItem
                }
            }
        }
        Write-Host "Matching items:" -ForegroundColor Green
        # Export the matching items to another CSV file
        $MatchingItems | Format-Table
        $MatchingItems | Export-Csv -Path $OutputCsvPath -NoTypeInformation
        
    }
    Write-host "Elaped time to compare 1000 items : $($timer.TotalSeconds) seconds"

}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Disconnect-PnPOnline