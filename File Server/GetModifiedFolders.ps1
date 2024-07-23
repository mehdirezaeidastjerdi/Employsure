# Define the root directory
$rootDirectory = "O:\5.Clients\1.Current clients"
# Define the date range
# $startDate = Get-Date "2023-11-17"   #The date that we start migration
$startDate = Get-Date "2024-07-18"
# $startDate = Get-Date "2024-04-02"
$endDate = Get-Date "2024-07-22"
# Define the output CSV file
$outputCsv = "C:\Temp\111ModifiedFolders.csv"

# Initialize an empty array to store results
$results = @()

# Function to get items modified within the date range
function Get-ModifiedItems($directory, $startDate, $endDate) {
    Get-ChildItem -Path $directory -Directory | Where-Object {
        $_.LastWriteTime -ge $startDate -and $_.LastWriteTime -le $endDate
    }
}
# Exclude new folders
$excludeFolders = @("New folder", "New folder (2)")

# Get all client directories, excluding "New folder" and "New folder (2)"
$clientDirectories = Get-ChildItem -Path $rootDirectory -Directory | Where-Object {
    $excludeFolders -notcontains $_.Name
}

# Process each client directory
foreach ($clientDirectory in $clientDirectories) {
    Write-Host "Checking folder: $($clientDirectory.FullName)"
    $modifiedItems = Get-ModifiedItems -directory $clientDirectory.FullName -startDate $startDate -endDate $endDate
    
    # Add the modified items to the results array
    if ($modifiedItems.Count -gt 0) {
        foreach ($item in $modifiedItems) {
            $results += [PSCustomObject]@{
                "Client Folder" = $clientDirectory.FullName
                "Modified Folder" = $item.FullName
                "Last Modified" = $item.LastWriteTime
            }
        }
    }
}

$results | Format-Table -AutoSize
# Export the results to a CSV file
$results | Export-Csv -Path $outputCsv -NoTypeInformation
Write-Host "Modified Folders:" -BackgroundColor Yellow
# Write-Host "Results have been saved to $outputCsv"
