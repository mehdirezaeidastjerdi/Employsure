# Specify the paths to your CSV files
$CsvFilePath1 = "C:\temp\All clients_old.csv"
$CsvFilePath2 = "C:\temp\SharePointTesting_old.csv"
$OutputCsvPath = "C:\temp\comparedOutput.csv"

# Import the CSV files
$CsvData1 = Import-Csv -Path $CsvFilePath1
$CsvData2 = Import-Csv -Path $CsvFilePath2

# Initialize an array to store matching items
$MatchingItems = @()

# Loop through each item in the first CSV file
foreach ($item in $CsvData1[0..1000]) {
    # Check if the item exists in the second CSV file
    $matchingItem = $CsvData2.FileName | Where-Object { $_ -match $item.Trading_Name__c}
    if ($matchingItem) {
        # Add the matching item to the array
        $MatchingItems += $matchingItem
    }
}
Write-Host "Matching items" -ForegroundColor Green
# Export the matching items to another CSV file
$MatchingItems
# $MatchingItems | Export-Csv -Path $OutputCsvPath -NoTypeInformation

# $MatchingItems | Format-Table
# Display a success message




