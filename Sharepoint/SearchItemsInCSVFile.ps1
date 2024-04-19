# # Specify the path to your CSV file
# $CsvFilePath = "C:\temp\test\SharePointTesting_test.csv"

# # Specify the search term (e.g., partial match)
# $searchTerm = "Offiscape"

# # Import the CSV file
# $CsvData = Import-Csv -Path $CsvFilePath

# # Initialize an array to store the results
# $Results = @()

# # Loop through each row in the CSV
# foreach ($row in $CsvData) {
#     # Check if the search term is found in any column
#     if ($row | ForEach-Object { $_ -match $searchTerm }) {
#         # Process the data (you can customize this part)
#         $Results += $row
#     }
# }
# # Display the results (you can format this output as needed)
# $Results | Format-Table
# # Clean up (release memory)
# Remove-Variable CsvData, Results
# ***************************************************************
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




