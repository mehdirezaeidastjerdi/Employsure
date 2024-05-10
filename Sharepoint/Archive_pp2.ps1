# Install the SharePoint PnP PowerShell module if not already installed
$SourceSite = "SharePointTesting"
$SourceLib = "DocLibrary2"
$DestSite = "hs_au_copy"
$DestLib = "Test Library"
$MatchedFilePath = "C:\temp\test2\Matched_Test.csv"
$CopiedItemsPath = "C:\temp\test2\CopiedItems.csv"
$NotExistInSourceItemsPath = "C:\temp\test2\NotExistInSourceItems.csv"
$SourceSiteUrl = "https://employsure.sharepoint.com/sites/$SourceSite"
$DestSiteUrl = "https://employsure.sharepoint.com/sites/$DestSite"

# Connect to SharePoint Online
Connect-PnPOnline -Url $DestSiteUrl -Interactive
Connect-PnPOnline -Url $SourceSiteUrl -Interactive

# Load the Excel data
$Matched = Import-Csv $MatchedFilePath

# Print out the values of the "ClientTradingName" column
Write-Host "ClientTradingName values in CSV file:"
$Matched.'ClientTradingName'

# Process all items in parallel
$CopiedItems = $Matched | ForEach-Object -Parallel {
    param($Row)

    $fileLeafRef = $Row.'ClientTradingName'

    if ([string]::IsNullOrWhiteSpace($fileLeafRef)) {
        Write-Host "Skipping processing for empty or whitespace file name."
        return $null
    }

    Write-Host "Processing file: $fileLeafRef"

    # Define function to copy file
    function Copy-File {
        param ($Row)
        $fileLeafRef = $Row.'ClientTradingName'
        $fileExists = Get-PnPFile -Url "$using:SourceLib/$fileLeafRef" -ErrorAction SilentlyContinue
        $FolderExists = Get-PnpFolder -Url "$using:SourceLib/$fileLeafRef" -ErrorAction SilentlyContinue

        $details = @{
            "ClientTradingName" = $fileLeafRef
        }

        if ($fileExists -or $FolderExists) {
            try {
                Write-Host "Copying $fileLeafRef to destination..."
                Copy-PnPFile -SourceUrl "/sites/$using:SourceSite/$using:SourceLib/$fileLeafRef" -TargetUrl "/sites/$using:DestSite/$using:DestLib" -Force -Overwrite
                Write-Host "'$fileLeafRef' copied to destination!" -ForegroundColor Green
                return New-Object PSObject -Property $details
            }
            catch {
                Write-Host "Error copying '$fileLeafRef': $_" -ForegroundColor Red
                return $null
            }
        } else {
            Write-Host "'$fileLeafRef' does not exist in source library!" -ForegroundColor Yellow
            return $null
        }
    }

    # Call the function to copy file
    Copy-File -Row $Row
} -ThrottleLimit 5  # Adjust the throttle limit as needed

# Filter out null values (items that were not copied)
$CopiedItems = $CopiedItems | Where-Object { $_ -ne $null }

# Export results to CSV
$CopiedItems | Export-Csv -Path $CopiedItemsPath -NoTypeInformation

Write-Host "Copying process finished" -ForegroundColor Blue
