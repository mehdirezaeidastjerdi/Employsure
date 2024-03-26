# This script compare specific columns from two CSV files and list the matching results. 
# Below is a PowerShell script that achieves this:

# Specify the paths to your CSV files
$CsvFilePath1 = "C:\temp\SharePointTesting.csv"
$CsvFilePath2 = "C:\temp\All clients.csv"

# Specify the column header you want to compare (adjust as needed)
$ColumnToCompare = "FileName"

# Import the CSV data from both files
$CsvData1 = Import-Csv -Path $CsvFilePath1
$CsvData2 = Import-Csv -Path $CsvFilePath2

# Initialize an array to store the matching results
$MatchingResults = @()

# Loop through each row in the first CSV
foreach ($row1 in $CsvData1) {
    # Get the value from the specified column
    $valueToCompare = $row1.$ColumnToCompare

    # Check if the value exists in the second CSV
    if ($CsvData2.$ColumnToCompare -contains $valueToCompare) {
        # Add the matching row to the results
        $MatchingResults += $row1
    }
}

# Display the matching results (you can format this output as needed)
$MatchingResults | Format-Table

# Export the file details to a CSV file
$MatchingResults | Export-Csv -Path "C:\temp\MatchedItems.csv" -NoTypeInformation -Encoding UTF8

# Clean up (release memory)
Remove-Variable CsvData1, CsvData2, MatchingResults
