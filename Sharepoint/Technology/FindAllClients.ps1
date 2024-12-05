# Install the SharePoint PnP PowerShell module if not already installed
#Install-Module -Name "SharePointPnPPowerShellOnline"
# Define variables for site name, source and target URLs, and document library
$SiteName = "Technology"
$DocumentLibrary = "Clients_EMP_OLD"

# Connect to the specified SharePoint Online site using web login
Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/$SiteName" -UseWebLogin

# Define file paths for various CSV files

$AllItemsPath = "C:\temp\Technology_Clients_EMP_Old_Count.csv"
$BatchSize = 2000
# Try block to handle potential errors
try {
    # Measure the time taken to execute the script block
    $timer = Measure-Command{
        Write-Host "Retrieve all files from the document library"
        
        # Retrieve list items from the specified document library, filtered by folder paths
        $ListItems = Get-PnPListItem -List $DocumentLibrary -PageSize $BatchSize | Where-Object { $_["FileDirRef"] -eq "/sites/$SiteName/$DocumentLibrary"             
        }
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
     Write-host "Elabsed time: $timer"
     Write-Host "All sharepoint Items exported to $AllSarepointItemsPath"
     $AllSharepointItems | Export-Csv -Path $AllItemsPath -NoTypeInformation -Append
     $AllSharepointItems | Format-Table        
}
catch {
    # Catch block to handle and display errors
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
Disconnect-PnPOnline