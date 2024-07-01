# Install the SharePoint PnP PowerShell module if not already installed
$SourceSite = "ER"
$SourceLib = "Clients"
$DestSite = "hs_au"
$DestLib = "Clients_DocLibrary"
$ConflictFolder = "ER Conflicts"
$MatchedFilePath = "C:\temp\ER\ERAllSiteClients.csv"
$CopiedItemsPath = "C:\temp\ER\successfullyCopiedItems.csv"
$NotExistInSourceItemsPath = "C:\temp\ER\NotExistInSourceItems.csv"
$ConflictItemsPath = "C:\temp\ER\ConflictItems.csv"
$SourceSiteUrl = "https://employsure.sharepoint.com/teams/$SourceSite"
$DestSiteUrl = "https://employsure.sharepoint.com/sites/$DestSite"

# Connect to SharePoint Online
Connect-PnPOnline -Url $DestSiteUrl -Interactive
Connect-PnPOnline -Url $SourceSiteUrl -Interactive

# Load the CSV data
$Matched = Import-Csv $MatchedFilePath

$NotExistInSourceItems = @()
$CopiedItems = @()
$ConflictItems = @()

foreach ($Row in $Matched) {
    $fileLeafRef = $Row.'ClientTradingName'  # Replace with the actual column name containing file names
    $fileExists = Get-PnPFile -Url "$SourceLib/$fileLeafRef" -ErrorAction SilentlyContinue
    $FolderExists = Get-PnpFolder -Url "$SourceLib/$fileLeafRef" -ErrorAction SilentlyContinue 

    $details = @{
        "ClientTradingName" = $fileLeafRef
    }

    # Check if the item exists in the source library
    if ($fileExists -or $FolderExists) {
        Write-Host "Copying $fileLeafRef to destination..."
        try {
            # Try to copy the file to the destination
            Copy-PnPFile -SourceUrl "/teams/$SourceSite/$SourceLib/$fileLeafRef" -TargetUrl "/sites/$DestSite/$DestLib" -Force
            Write-Host "'$fileLeafRef' copied to destination!" -ForegroundColor Green
            $CopiedItems += New-Object PSObject -Property $details
        } catch {
            $errorMessage = $_.Exception.Message
            Write-Host "Error copying $fileLeafRef $errorMessage" -ForegroundColor Red

            if ($errorMessage -match "A file or folder with the name") {
                Write-Host "Item $fileLeafRef exists in destination. Copying to $ConflictFolder..."

                # Ensure the conflict folder exists in the destination
                $conflictFolderExists = Get-PnPFolder -Url "$DestLib/$ConflictFolder" -ErrorAction SilentlyContinue
                if (-not $conflictFolderExists) {
                    Write-Host "Creating conflict folder $ConflictFolder in destination..."
                    New-PnPFolder -Name $ConflictFolder -Folder "$DestLib"
                }

                # Try to copy the file to the conflict folder
                try {
                    Copy-PnPFile -SourceUrl "/teams/$SourceSite/$SourceLib/$fileLeafRef" -TargetUrl "/sites/$DestSite/$DestLib/$ConflictFolder" -Force
                    Write-Host "'$fileLeafRef' copied to conflict folder!" -ForegroundColor Green
                    $ConflictItems += New-Object PSObject -Property $details
                } catch {
                    Write-Host "Error copying $fileLeafRef to conflict folder: $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Host "Unhandled error: $errorMessage" -ForegroundColor Red
                throw $_
            }
        }
    } else {
        Write-Host "'$fileLeafRef' does not exist in source library!" -ForegroundColor Yellow
        $NotExistInSourceItems += New-Object PSObject -Property $details
    }
}

Write-Host "Copying process finished" -ForegroundColor Blue

Write-Host "Copied items:" -BackgroundColor Green
$CopiedItems | Format-Table

Write-Host "Not exist in source library items ($SourceLib):" -BackgroundColor Yellow
$NotExistInSourceItems | Format-Table

Write-Host "Conflict items:" -BackgroundColor Yellow
$ConflictItems | Format-Table

# Export copied, non-existent, and conflict items to CSV
$CopiedItems | Export-Csv -Path $CopiedItemsPath -NoTypeInformation
$NotExistInSourceItems | Export-Csv -Path $NotExistInSourceItemsPath -NoTypeInformation
$ConflictItems | Export-Csv -Path $ConflictItemsPath -NoTypeInformation

# Disconnect from SharePoint Online
Disconnect-PnPOnline
