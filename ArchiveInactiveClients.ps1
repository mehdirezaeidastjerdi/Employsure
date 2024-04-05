# Update-Module -Name "SharePointPnPPowerShellOnline"
Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/SharePointTesting" -UseWebLogin

# Specify the name of your document library
$SiteName = "SharePointTesting"
$SourceURL = "Shared Documents"
$TargetURL = "Archive"
$DocumentLibrary = $SourceURL
$BatchSize = 2000

$SalesforceActiveClientsPath = "C:\temp\Salesforce Active Clients.csv"
$AllSarepointItemsPath = "C:\temp\AllSarepointItems.csv"
$MatchingItemsPath = "C:\temp\Matched.csv"
$UnmatchedItemsPath = "C:\temp\Unmatched.csv"
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
    #     # Write-host "Importing all sharepoint document library items..."
        $AllSarepointItems = Import-Csv -Path $AllSarepointItemsPath    
    }
    
    Write-host "Elaped time to get List of all Items in DL : $($timer.TotalSeconds) seconds"
    $SalesforceActiveClient = Import-Csv -Path $SalesforceActiveClientsPath
    
    
    # Initialize arrays to store matching and unmatched items
    $Matched = @()
    $Unmatched = @()
    $timer = Measure-Command{
        # Loop over each row in the first CSV file
        foreach ($row1 in $AllSarepointItems) {
            
            $foundMatch = $false
            foreach($row2 in $SalesforceActiveClient) {
                
                # Compare each combination of columns
                if($row1.ClientTradingName -match $row2.Employsure_Client__c ){
                    # If similarity found
                        $Matched += $row1
                        $foundMatch = $true
                        break 
                    }
                elseif ( $row1.ClientTradingName -match $row2.Trading_Name__c ){
                   # If similarity found
                   $Matched += $row1
                   $foundMatch = $true
                   break
                }                    
            }
            
            if(-not $foundMatch){
                $Unmatched += $row1
             }
                
        }
            
            
        } #end of timer 
            
  
        

 
    Write-host "Elaped time to compare items : $($timer.TotalSeconds) seconds"
    Write-Host "Matching items:" -ForegroundColor Green
    $Matched | Format-Table

    Write-Host "Unmatched items:" -ForegroundColor Yellow
    $Unmatched | Format-Table 
    # Export the matching and unmatched items to separate CSV files
    $Matched | Export-Csv -Path $MatchingItemsPath -NoTypeInformation
    $Unmatched | Export-Csv -Path $UnmatchedItemsPath -NoTypeInformation
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Disconnect-PnPOnline
