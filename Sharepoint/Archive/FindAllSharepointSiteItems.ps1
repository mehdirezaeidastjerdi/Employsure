# Install the SharePoint PnP PowerShell module if not already installed
#Install-Module -Name "SharePointPnPPowerShellOnline"
# Define variables for site name, source and target URLs, and document library
$SiteName = "hs_au"
$DocumentLibrary = "Migration Data"

# Connect to the specified SharePoint Online site using web login
Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/$SiteName" -UseWebLogin

# Define file paths for various CSV files

$AllMigrationDataItemsPath = "C:\temp\AllMigrationDataClients.csv"
$BatchSize = 2000
# Try block to handle potential errors
try {
    # Measure the time taken to execute the script block
    $timer = Measure-Command{
        Write-Host "Retrieve all files from the document library"
        
        # Retrieve list items from the specified document library, filtered by folder paths
        $ListItems = Get-PnPListItem -List $DocumentLibrary -PageSize $BatchSize | Where-Object { $_["FileDirRef"] -eq "/sites/$SiteName/$DocumentLibrary" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/A" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/B" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/C" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/D" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/E" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/F" `
            -or $_["FileDirRef"] -eq "/sites/$SiteName/$DocumentLibrary/G"  `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/H" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/I" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/J" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/K" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/L" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/M" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/N" `
            -or $_["FileDirRef"] -eq "/sites/$SiteName/$DocumentLibrary/O"  `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/P" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/Q" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/R" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/S" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/T" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/U" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/V" `
            -or $_["FileDirRef"] -eq "/sites/$SiteName/$DocumentLibrary/W"  `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/X" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/Y" `
            -or $_["FileDirRef"]  -eq "/sites/$SiteName/$DocumentLibrary/Z"        
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
     $AllSharepointItems | Export-Csv -Path $AllMigrationDataItemsPath -NoTypeInformation
     $AllSharepointItems | Format-Table        
}
catch {
    # Catch block to handle and display errors
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
