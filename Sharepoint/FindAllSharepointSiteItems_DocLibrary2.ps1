# Install the SharePoint PnP PowerShell module if not already installed
# Install-Module -Name "SharePointPnPPowerShellOnline"

# Define variables for site name, source and target URLs, and document library
$SiteName = "file_server_clients"
$SourceURL = "File Server Clients"
$DocumentLibrary = $SourceURL

# Connect to the specified SharePoint Online site using web login
Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/$SiteName" -Interactive

# Define file paths for various CSV files
$AllSharepointItemsPath = "C:\temp\test\newsharepointitems.csv"
$PageSize = 10 # Set the number of items to retrieve

# Try block to handle potential errors
try {
    # Measure the time taken to execute the script block
    $timer = Measure-Command {
        Write-Host "Retrieve all files from the document library"
        
        # Retrieve list items from the specified document library, limited by the ItemCount
        $ListItems = Get-PnPListItem -List $DocumentLibrary -PageSize $PageSize -Fields FileLeafRef | Where-Object { $_["FileDirRef"] -eq "/sites/$SiteName/$DocumentLibrary"}
        Write-Host "Batch selected..."

        # Initialize an array to store SharePoint items
        $AllSharepointItems = @()

        # Loop through each item and create a custom object with the client trading name
        foreach ($Item in $ListItems) {
            $AllSharepointItems += New-Object PSObject -Property @{
                ClientTradingName = $Item.FieldValues["FileLeafRef"]
            }
        }
    }
    # Export the array of SharePoint items to a CSV file
    Write-Host "Elapsed time: $timer"
    Write-Host "All SharePoint items exported to $AllSharepointItemsPath"
    $AllSharepointItems | Export-Csv -Path $AllSharepointItemsPath -NoTypeInformation
    $AllSharepointItems | Format-Table
}
catch {
    # Catch block to handle and display errors
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
