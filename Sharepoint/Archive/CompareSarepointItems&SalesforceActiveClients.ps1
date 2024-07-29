# Update-Module -Name "SharePointPnPPowerShellOnline"
# Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/SharePointTesting" -UseWebLogin

# Specify the name of your document library
$SiteName = "SharePointTesting"
$SourceURL = "Shared Documents"
$TargetURL = "Archive"
$DocumentLibrary = $SourceURL
$BatchSize = 2000

$SalesforceActiveClientsPath = "C:\temp\Salesforce Active Clients.csv"
$AllSarepointItemsPath = "C:\temp\AllSharepointItems.csv"
$MatchingItemsPath = "C:\temp\Matched.csv"
$UnmatchedItemsPath = "C:\temp\Unmatched.csv"

# Read the CSV files
$SalesForceActiveClients = Import-Csv $SalesforceActiveClientsPath
$AllSharepointItems = Import-Csv $AllSarepointItemsPath

# Arrays to store matched and unmatched items
$matchedItems = @()
$unmatchedItems = @()

# Process each item from AllSharepointItems CSV
foreach ($item in $AllSharepointItems){
    
    $itemName = $item.'ClientTradingName'
    $empNumber = $null
    $brandName = $null
    # Check the format of the item
    if ($itemName -match '^(?<brand>.+)_EMP(?<empNumber>\d+)$' -or $itemName -match '^(?<brand>.+) EMP(?<empNumber>\d+)$') {
        $brandName = $matches['brand']
        $empNumber = "EMP" + $matches['empNumber']
        Write-Host "barand name: $brandName"
        write-host "employsure Number: $empNumber"


        # Check if EMP number exists in SalesForceActiveClients Employsure-Number column
        if ($SalesForceActiveClients.'Employsure_Client__c' -eq $empNumber) {
            $matchedItems += $item
        } else {
            # Check if Brand Name exists in SalesForceActiveClients Trading_Name__c column with partial match
            $matched = $SalesForceActiveClients | Where-Object { $_.'Trading_Name__c' -like "*$brandName*" }
            if ($matched) {
                $matchedItems += $item
            } else {
                $unmatchedItems += $item
            }
        }
    } elseif ($itemName -match '^EMP(\d+)$') {
        $empNumber = "EMP" + $matches[1]
        Write-Host "EMPNumber: $empNumber"

        # Check if EMP number exists in SalesForceActiveClients Employsure-Number column
        if ($SalesForceActiveClients.'Employsure_Client__c' -eq $empNumber) {
            $matchedItems += $item
        } else {
            $unmatchedItems += $item
        }
    } else {
        Write-Host "Item Name: $itemName"
        # # Check if Brand Name exists in SalesForceActiveClients Trading_Name__c column with partial match
        $matched = $SalesForceActiveClients | Where-Object { $_.'Trading_Name__c' -like "*$itemName*" }
        if ($matched) {
            $matchedItems += $item
        } else {
            $unmatchedItems += $item
        }
    }
}

# Output the results
Write-Host "Matched Items:" -BackgroundColor Green
$matchedItems | Format-Table
$matchedItems | Export-Csv $MatchingItemsPath -NoTypeInformation


Write-Host "Unmatched Items:" -BackgroundColor Yellow
$unmatchedItems | Format-Table
$unmatchedItems | Export-Csv $UnmatchedItemsPath -NoTypeInformation