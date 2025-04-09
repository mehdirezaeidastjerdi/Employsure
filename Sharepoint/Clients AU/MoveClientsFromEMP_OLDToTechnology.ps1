# Install the PnP.PowerShell module if not already installed
# Install-Module -Name "PnP.PowerShell"
$SourceSite = "hs_au"
$SourceLib = "Clients_EMP_OLD"
# $SourceFolder = "Obsolete2024"
$DestSite = "Technology"
$DestLib = "Clients_EMP_OLD"
$MatchedFilePath = "C:\temp\AllSharepointItems_Clients_EMP_OLD.csv"
$CopiedItemsPath = "C:\temp\successfullyCopiedItems_Clients_EMP_OLD.csv"
$NotExistInSourceItemsPath = "C:\temp\NotExistInSourceItems_Clients_EMP_OLD.csv"
$SourceSiteUrl = "https://employsure.sharepoint.com/sites/$SourceSite"
$DestSiteUrl = "https://employsure.sharepoint.com/sites/$DestSite"
# Connect to SharePoint Online
Connect-PnPOnline -Url $DestSiteUrl -Interactive
Connect-PnPOnline -Url $SourceSiteUrl -Interactive

# Load the CSV data
$Matched = Import-Csv $MatchedFilePath

$NotExistInSourceItems = @()
$CopiedItems = @()
 
foreach ($Row in $Matched[0..2]) {
    
    $fileLeafRef = $Row.'ClientTradingName'  # Replace with the actual column name containing file names
    $fileExists = Get-PnPFile -Url "$SourceSiteUrl/$SourceLib/$fileLeafRef" -ErrorAction SilentlyContinue
    $FolderExists = Get-PnpFolder -Url "$SourceSiteUrl/$SourceLib/$fileLeafRef" -ErrorAction SilentlyContinue 
    $details = @{
        "ClientTradingName" = $fileLeafRef
    }
    # Check if the item exists in the source library
    if ($fileExists -or $FolderExists) {          
            try {
                Write-Host "Copying $fileLeafRef to destination."
                # Try to copy the file to the destination
                Copy-PnPFile -SourceUrl "$SourceLib/$fileLeafRef" -TargetUrl "/sites/$DestSite/$DestLib" -Force
                
                Write-Host "'$fileLeafRef' copied to destination!" -ForegroundColor Green
                $CopiedItems += New-Object PSObject -Property $details
                Write-Host "Removing $fileLeafRef from source."
                # Delete the file from the source
                Remove-PnPFile -ServerRelativeUrl "/sites/$SourceSite/$SourceLib/$fileLeafRef" -Force 
                Write-Host "'$fileLeafRef' deleted from source!" -ForegroundColor Green
            } catch {
                $errorMessage = $_.Exception.Message
                Write-Host "Error copying or deleting $fileLeafRef $errorMessage" -ForegroundColor Red            
            }        
    } else {
        Write-Host "'$fileLeafRef' does not exist in source library!" -ForegroundColor Yellow
        $NotExistInSourceItems += New-Object PSObject -Property $details
    }
}

Write-Host "Copying and deleting process finished" -ForegroundColor Blue

Write-Host "Copied and deleted items:" -ForegroundColor Green
$CopiedItems | Format-Table

Write-Host "Not exist in source library items ($SourceLib):" -ForegroundColor DarkCyan
$NotExistInSourceItems | Format-Table

# Export copied, non-existent, and conflict items to CSV
$CopiedItems | Export-Csv -Path $CopiedItemsPath -NoTypeInformation -Append
$NotExistInSourceItems | Export-Csv -Path $NotExistInSourceItemsPath -NoTypeInformation -Append
# Disconnect from SharePoint Online
# Disconnect-PnPOnline
