# Install the PnP.PowerShell module if not already installed
# Install-Module -Name "PnP.PowerShell"

$SiteName = "hs_au"
$SourceLib = "Shared Documents"
$DestLib = "Shared Documents"
$SourceSiteUrl = "https://employsure.sharepoint.com/sites/$SiteName"

# Paths to CSV files
$ItemsToCopyPath = "C:\temp\ItemsToCopy.csv"
$CopiedItemsPath = "C:\temp\CopiedItems.csv"
$FailedItemsPath = "C:\temp\FailedItems.csv"

# Connect to SharePoint Online
Connect-PnPOnline -Url $SourceSiteUrl -Interactive

# Define the page size for retrieval
$PageSize = 2000

# Try block to handle potential errors
try {
    # Measure the time taken to execute the script block
    $timer = Measure-Command {
        Write-Host "Retrieve all files from the root of the document library"
        
        # Retrieve list items from the specified document library
        $ListItems = Get-PnPListItem -List $SourceLib -PageSize $PageSize -Fields FileLeafRef, FileDirRef
        
        if ($ListItems -eq $null) {
            Write-Host "No items retrieved from the document library" -ForegroundColor Yellow
            return
        }
        
        Write-Host "Batch selected..."

        # Initialize an array to store SharePoint items
        $ItemsToCopy = @()

        # Loop through each item and filter to get only items in the root folder
        foreach ($Item in $ListItems) {
            if ($Item["FileDirRef"] -eq "/sites/$SiteName/$SourceLib") {
                $ItemsToCopy += New-Object PSObject -Property @{
                    FileLeafRef = $Item.FieldValues["FileLeafRef"]
                    SourceItemUrl = $Item.FieldValues["FileDirRef"] + "/" + $Item.FieldValues["FileLeafRef"]
                }
            }
        }
        
        if ($ItemsToCopy.Count -eq 0) {
            Write-Host "No items matched the specified directory reference" -ForegroundColor Yellow
            return
        }
        
        # Export the array of SharePoint items to a CSV file
        $ItemsToCopy | Export-Csv -Path $ItemsToCopyPath -NoTypeInformation -Force
        Write-Host "Elapsed time: $timer"
        Write-Host "All SharePoint items exported to $ItemsToCopyPath"
    }
}
catch {
    # Catch block to handle and display errors
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}


# Load the CSV data
$ItemsToCopy = Import-Csv -Path $ItemsToCopyPath

$CopiedItems = @()
$FailedItems = @()

foreach ($Item in $ItemsToCopy) {
    $fileLeafRef = $Item.FileLeafRef
    $SourceItemUrl = $Item.SourceItemUrl
    $DestItemUrl = "/sites/$SiteName/$DestLib/$fileLeafRef"

    $details = @{
        "ClientTradingName" = $fileLeafRef
    }

    Write-Host "Copying $fileLeafRef to $DestLib..."

    try {
        # Copy the file to the destination library with overwrite
        # Copy-PnPFile -SourceUrl $SourceItemUrl -TargetUrl $DestItemUrl -Overwrite -Force
        
        Write-Host "'$fileLeafRef' copied to $DestLib!" -ForegroundColor Green
        $CopiedItems += New-Object PSObject -Property $details
        
        # Optionally delete the source file after copying
        # Remove-PnPFile -ServerRelativeUrl $SourceItemUrl -Force
        Write-Host "'$fileLeafRef' deleted from source!" -ForegroundColor Green
    } catch {
        $errorMessage = $_.Exception.Message
        Write-Host "Error copying $fileLeafRef $errorMessage" -ForegroundColor Red
        $FailedItems += New-Object PSObject -Property $details
    }
}

Write-Host "Copying process finished" -ForegroundColor Blue

Write-Host "Copied items:" -ForegroundColor Green
$CopiedItems | Format-Table

Write-Host "Failed items:" -ForegroundColor Red
$FailedItems | Format-Table

# Export copied and failed items to CSV
$CopiedItems | Export-Csv -Path $CopiedItemsPath -NoTypeInformation -Append
$FailedItems | Export-Csv -Path $FailedItemsPath -NoTypeInformation -Append

# Disconnect from SharePoint Online
Disconnect-PnPOnline
