# Specify the path to your CSV file
$CsvFilePath = "C:\temp\All clients.csv"

# Specify the search term (e.g., partial match)
$searchTerm = "Management Accountants"

# Import the CSV file
$CsvData = Import-Csv -Path $CsvFilePath

# Initialize an array to store the results
$Results = @()

# Loop through each row in the CSV
foreach ($row in $CsvData) {
    # Check if the search term is found in any column
    if ($row | ForEach-Object { $_ -match $searchTerm }) {
        # Process the data (you can customize this part)
        $Results += $row
    }
}

# Display the results (you can format this output as needed)
$Results | Format-Table
# Clean up (release memory)
Remove-Variable CsvData, Results


