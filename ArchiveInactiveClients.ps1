# Update-Module -Name "SharePointPnPPowerShellOnline" 
Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/SharePointTesting" -UseWebLogin

# Specify the name of your document library
$SiteName = "SharePointTesting"
$SourceURL = "Shared Documents"
$TargetURL = "Archive"
$DocumentLibrary = $SourceURL
$BatchSize = 2000

try {
    Write-Host "Retrieve all files from the document library"
    $ListItems = Get-PnPListItem -List $DocumentLibrary -PageSize $BatchSize | Where-Object { $_["FileDirRef"] -eq "/sites/$SiteName/$DocumentLibrary" } 
    Write-Host "Batch selected..."
    
    $AllFiles = @()
    
    # Enumerate all list items to get file details
    foreach ($Item in $ListItems) {
        $AllFiles += New-Object PSObject -Property @{
            ClientTradingName = $Item.FieldValues["FileLeafRef"]   
        }
    }
    $AllFiles
    $MatchingFields = @()

    # Loop through each file in the $AllFiles array
    foreach($file in $AllFiles){
        $termFound = Search-CsvForTerm -SearchTerm $file.ClientTradingName
        if($termFound){
            $MatchingFields += $file
        }
    }



    # Export the file details to a CSV file
    $MatchingFields | Export-Csv -Path "C:\temp\MatchingFields.csv" -NoTypeInformation -Encoding UTF8

    Write-Host "MatchingFields exported successfully" -ForegroundColor Green
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Disconnect-PnPOnline
# ******************************************************************************
# ******************************************************************************
function Search-CsvForTerm {
    param (
        [string]$SearchTerm
    )

    # Hardcoded path to your CSV file
    $CsvFilePath = "C:\temp\All clients_old.csv"

    # Import the CSV file
    $CsvData = Import-Csv -Path $CsvFilePath

    # Check if the search term exists in any column
    foreach ($row in $CsvData) {
        if ($row.Client_Number__c | ForEach-Object { $_ -match $SearchTerm }) {
            return $true
        }
    }

    # If no match is found, return false
    return $false
}


