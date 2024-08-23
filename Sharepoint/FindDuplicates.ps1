# Define the path to the input CSV file and output CSV file
$inputCsvPath = "M:\AllMigrationDataClients.csv"
$outputCsvPath = "M:\AllMigrationDataClients_Duplicates.csv"

# Specify the column to check for duplicates
$columnToCheck = "ClientTradingName"  # Replace with the actual column name

# Import the CSV file
$data = Import-Csv -Path $inputCsvPath

# Group the data by the specified column and filter out duplicates
$duplicates = $data | Group-Object -Property $columnToCheck | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Group }

# Flatten the grouped data and export to a new CSV file
$duplicates | Export-Csv -Path $outputCsvPath -NoTypeInformation

Write-Host "Duplicates have been exported to $outputCsvPath"
