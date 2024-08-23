# # Install the PnP PowerShell module if not already installed
# # Install-Module -Name "PnP.PowerShell"

# Connect to SharePoint Online
$SiteURL = "https://employsure.sharepoint.com/sites/hs_au"
Connect-PnPOnline -Url $SiteURL -Interactive

# # Specify the user and date
# $User = "Mehdi Rezaei"
# $SpecificDate = Get-Date "2024-08-05"  # Replace with the desired date
# $CsvFilePath = "C:\temp\hs_au_recyclebinItems.csv"
# $NumberOfItemsToRead = 500

# # Function to list items in batches and save to CSV
# function List-RecycleBinItems {

#     param (
#         [int]$BatchSize=1000
#     )

#     $ProcessedItems = 0
#     do {
#         # Get a batch of recycle bin items that match the criteria
#         $RecycleBinItems = Get-PnPRecycleBinItem -RowLimit $BatchSize | Where-Object {
#             $_.DeletedByName -eq $User -and $_.DeletedDate -ge $SpecificDate
#         }

#         # Add the items to the collection
#         $AllRecycleBinItems += $RecycleBinItems

#         $ProcessedItems += $RecycleBinItems.Count
#         Write-Host "processed items: $ProcessedItems" -f Green
#     } while ($ProcessedItems -lt $NumberOfItemsToRead)

#     # Save items to CSV
#     $AllRecycleBinItems | Select-Object Title, DeletedDate, DeletedByName, Id | Export-Csv -Path $CsvFilePath -NoTypeInformation

#     Write-Host "Listed items deleted by $User on $($SpecificDate.ToString('yy/MM/dd')) and saved to $CsvFilePath."
# }

# # List items in batches and save to CSV
# List-RecycleBinItems -BatchSize 200

# Read the CSV file and remove items from the recycle bin
$RecycleBinItems = Import-Csv -Path $CsvFilePath
foreach ($Item in $RecycleBinItems) {
    try {
        Clear-PnPRecycleBinItem -Identity $Item.Id -Force 
        Write-Host "$($Item.Title) removed from Recycle bin." -ForegroundColor Cyan
        Write-Host "Removed item: $($Item.Title)" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to remove item: $($Item.Title). Error: $_" -ForegroundColor Red
    }
}


# Disconnect-PnPOnline
