# Install the SharePoint PnP PowerShell module if not already installed
# Connect to SharePoint Online
$SourceSite = "hs_au_copy"
$SourceLib = "Clients_Copy"
$DestSite = "hs_au_copy"
$DestLib = "Test Library1"
$MatchedFilePath = "C:\temp\test2\Matched_Test.csv"
$CopiedItemsPath = "C:\temp\test2\CopiedItems.csv"
$NotExistInSourceItemsPath = "C:\temp\test2\NotExistInSourceItems.csv"
$SourceSiteUrl = "https://employsure.sharepoint.com/sites/$SourceSite"
$DestSiteUrl = "https://employsure.sharepoint.com/sites/$DestSite"
# Connect to SharePoint Online
Connect-PnPOnline -Url $DestSiteUrl  -Interactive
Connect-PnPOnline -Url $SourceSiteUrl -Interactive
# Load the Excel data
$Matched = Import-Csv $MatchedFilePath
$NotExistInSourceItems = @()
$CopiedItems = @()
try {
    $Matched | ForEach-Object -Parallel {
                
        $fileLeafRef = $_.ClientTradingName        
        $details = @{
            "ClientTradingName" = $fileLeafRef
        }        
        try {
            # Check if the item exists in the source library
            $fileExists = Get-PnPFile -Url "$using:SourceLib/$fileLeafRef" -ErrorAction SilentlyContinue
            $folderExists = Get-PnPFolder -Url "$using:SourceLib/$fileLeafRef" -ErrorAction SilentlyContinue
            
            if ($fileExists -or $folderExists) {
                Write-Host "Copying $fileLeafRef to destination..."
                Copy-PnPFile -SourceUrl "/sites/$using:SourceSite/$using:SourceLib/$fileLeafRef" -TargetUrl "/sites/$using:DestSite/$using:DestLib" -Force -Overwrite
                Write-Host "'$fileLeafRef' copied to destination!" -ForegroundColor Green
                $CopiedItems += New-Object PSObject -Property $details
            } else {
                Write-Host "'$fileLeafRef' does not exist in source library!" -ForegroundColor Yellow
                $NotExistInSourceItems += New-Object PSObject -Property $details
            }
        } catch {
            Write-Host "Error copying '$fileLeafRef': $_" -ForegroundColor Red
        }
    } -ThrottleLimit 10  # Adjust the throttle limit as needed
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Write-Host "Copying process finished" -ForegroundColor Blue    
    Write-Host "Copied items:" -BackgroundColor Green
    $CopiedItems | Format-Table
    Write-Host "Not exist in source library items ($SourceURL):" -BackgroundColor Yellow
    $NotExistInSourceItems | Format-Table  
    $CopiedItems | Export-Csv -Path $CopiedItemsPath -NoTypeInformation
    $NotExistInSourceItems | Export-Csv -Path $NotExistInSourceItemsPath -NoTypeInformation
    
    Disconnect-PnPOnline
}
