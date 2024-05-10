# Install the SharePoint PnP PowerShell module if not already installed
$SourceSite = "hs_au"
$SourceLib = "Clients_DocLibrary"
$DestSite = "hs_au_copy"
$DestLib = "Clients_Copy"
$MatchedFilePath = "C:\temp\test2\Matched.csv"
$CopiedItemsPath = "C:\temp\test2\CopiedItems.csv"
$NotExistInSourceItemsPath = "C:\temp\test2\NotExistInSourceItems.csv"
$SourceSiteUrl = "https://employsure.sharepoint.com/sites/$SourceSite"
$DestSiteUrl = "https://employsure.sharepoint.com/sites/$DestSite"
# Connect to SharePoint Online
Connect-PnPOnline -Url $DestSiteUrl -Interactive
Connect-PnPOnline -Url $SourceSiteUrl -Interactive

# Load the Excel data
$Matched = Import-Csv $MatchedFilePath

$NotExistInSourceItems = @()
$CopiedItems = @()

try {
    $startIndex = 11910
    $endIndex = 12001
    $batchSize = 50
    $batchCount = [math]::Ceiling(($endIndex - $startIndex + 1) / $batchSize)

    for ($batchIndex = 0; $batchIndex -lt $batchCount; $batchIndex++) {
        $batchStart = $startIndex + $batchIndex * $batchSize
        $batchEnd = [math]::Min($startIndex + ($batchIndex + 1) * $batchSize - 1, $endIndex)

        for ($index = $batchStart; $index -le $batchEnd; $index++) {
            $Row = $Matched[$index]

            $fileLeafRef = $Row.'ClientTradingName'  # Replace with the actual column name containing file names
            $fileExists = Get-PnPFile -Url "$SourceLib/$fileLeafRef" -ErrorAction SilentlyContinue
            $FolderExists = Get-PnpFolder -Url "$SourceLib/$fileLeafRef" -ErrorAction SilentlyContinue 

            $details = @{
                "ClientTradingName" = $fileLeafRef
            }

            # Check if the item exists in the source library
            if ($fileExists -or $FolderExists) { 
                Write-Host "Copying $fileLeafRef to destination..."
                # Copy the file with -NoWait parameter
                Copy-PnPFile -SourceUrl "/sites/$SourceSite/$SourceLib/$fileLeafRef" -TargetUrl "/sites/$DestSite/$DestLib" -Force -Overwrite -NoWait
                Write-Host "'$fileLeafRef' copied to destination!" -ForegroundColor Green
                $CopiedItems += New-Object PSObject -Property $details
            } else {
                Write-Host "'$fileLeafRef' does not exist in source library!" -ForegroundColor Yellow
                $NotExistInSourceItems += New-Object PSObject -Property $details
            }
        }

        # Wait for at least 30 minutes after copying each batch
        Write-Host "Waiting for 30 minutes..."
        Start-Sleep -Seconds (10 * 60)  # Wait for 30 minutes
    }

    Write-Host "Copying process finished" -ForegroundColor Blue
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "Copied items:" -BackgroundColor Green
$CopiedItems | Format-Table

Write-Host "Not exist in source library items ($SourceURL):" -BackgroundColor Yellow
$NotExistInSourceItems | Format-Table

# Export copied and non-existent items to CSV
$CopiedItems | Export-Csv -Path $CopiedItemsPath -NoTypeInformation
$NotExistInSourceItems | Export-Csv -Path $NotExistInSourceItemsPath -NoTypeInformation

# Disconnect from SharePoint Online
Disconnect-PnPOnline
