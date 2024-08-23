# Define variables for site name, document library, and output CSV path
$SiteName = "hs_au"
$DocumentLibrary = "Clients_EMP_OLD"
$OutputCsvPath = "C:\temp\FilteredFolders.csv"

# Date to compare
$DateToCheck = Get-Date "2023-09-01"

# Array of users to exclude
$ExcludedUsers = @("Mehdi Rezaei", "Mehdi Rezaei Admin")

# Connect to the specified SharePoint Online site using web login
Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/$SiteName" -Interactive

# Initialize an array to store folders that meet the criteria
$FilteredFolders = @()

# Try block to handle potential errors
try {
    # Measure the time taken to execute the script block
    $timer = Measure-Command {
        Write-Host "Retrieving all items from the document library..."

        # Retrieve all list items from the specified document library
        $ListItems = Get-PnPListItem -List $DocumentLibrary -PageSize 2000 -Fields FileLeafRef, FileDirRef, Modified, Editor

        if ($ListItems -eq $null) {
            Write-Host "No items retrieved from the document library" -ForegroundColor Yellow
            return
        }

        Write-Host "Items retrieved. Processing..."

        # Group items by folder path
        $Folders = $ListItems | Group-Object { $_["FileDirRef"] }

        # Loop through each folder group
        foreach ($FolderGroup in $Folders) {
            $FolderPath = $FolderGroup.Name

            # Check if any file in the folder meets the conditions
            $Matches = $FolderGroup.Group | Where-Object {
                ($_["Modified"] -gt $DateToCheck) -and
                ($ExcludedUsers -notcontains $_["Editor"].LookupValue)
            }

            # If any match is found, add the folder name and editor to the list
            if ($Matches.Count -gt 0) {
                # Create a list of editors who modified the files in this folder
                $Editors = $Matches | Select-Object -ExpandProperty Editor | Select-Object -Unique -ExpandProperty LookupValue
                $FilteredFolders += New-Object PSObject -Property @{
                    FolderName = $FolderPath
                    ModifiedBy = -join $Editors -join ", " # Combine editor names into a string
                }
            }
        }
    }
    # Export the array of filtered folders to a CSV file
    Write-Host "Elapsed time: $timer"
    Write-Host "Filtered folders exported to $OutputCsvPath"
    $FilteredFolders | Export-Csv -Path $OutputCsvPath -NoTypeInformation
    $FilteredFolders | Format-Table
}
catch {
    # Catch block to handle and display errors
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
