# Install the PnP.PowerShell module if not already installed
# Install-Module -Name "PnP.PowerShell"

$SourceSite = "hs_au"
$SourceLib = "Clients_DocLibrary"
$MatchedFilePath = "C:\temp\Technology_Clients_EMP_Old_Complete.csv"
$ExistingFilesPath = "C:\temp\ExistingFiles.csv"
$SourceSiteUrl = "https://employsure.sharepoint.com/sites/$SourceSite"

# Connect to SharePoint Online
Connect-PnPOnline -Url $SourceSiteUrl -UseWebLogin

# Load the CSV data
$Matched = Import-Csv $MatchedFilePath
$ExistingFiles = @()
Write-Host "Waite... Checking if the Clients exist." -ForegroundColor Blue
foreach ($Row in $Matched) {
    
    $fileLeafRef = $Row.'ClientTradingName'  # Replace with the actual column name
    $fileExists = Get-PnPFile -Url "/$SourceLib/$fileLeafRef" -ErrorAction SilentlyContinue
    $FolderExists = Get-PnpFolder -Url "/$SourceLib/$fileLeafRef" -ErrorAction SilentlyContinue
    
    if ($FolderExists -or $fileExists) {
        Write-Host "'$fileLeafRef' exists in the source library." -ForegroundColor Green
        $ExistingFiles += [PSCustomObject]@{
            "ClientTradingName" = $fileLeafRef
        }
    }
}

# Export the existing files to CSV
$ExistingFiles | Export-Csv -Path $ExistingFilesPath -NoTypeInformation -Append

Write-Host "Process completed. Existing files saved to $ExistingFilesPath" -ForegroundColor Blue

# Disconnect from SharePoint Online
Disconnect-PnPOnline
