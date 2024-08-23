# Install the PnP.PowerShell module if not already installed
# Install-Module -Name "PnP.PowerShell"
$SourceSite = "hs_au"
$SourceLib = "Clients_DocLibrary"
# $SourceFolder = "Obsolete2024"
$DestSite = "hs_au"
$DestLib = "Clients_EMP_OLD"
$MatchedFilePath = "C:\temp\New EMP\AllSharepointItems.csv"
$CopiedItemsPath = "C:\temp\New EMP\successfullyCopiedItems.csv"
$NotExistInSourceItemsPath = "C:\temp\New EMP\NotExistInSourceItems.csv"
$SourceSiteUrl = "https://employsure.sharepoint.com/sites/$SourceSite"
$DestSiteUrl = "https://employsure.sharepoint.com/sites/$DestSite"
# Connect to SharePoint Online
Connect-PnPOnline -Url $DestSiteUrl -Interactive
Connect-PnPOnline -Url $SourceSiteUrl -Interactive

# Load the CSV data
$Matched = Import-Csv $MatchedFilePath

$NotExistInSourceItems = @()
$CopiedItems = @()
 
foreach ($Row in $Matched) {
    
    $fileLeafRef = $Row.'ClientTradingName'  # Replace with the actual column name containing file names
    $fileExists = Get-PnPFile -Url "$SourceSiteUrl/$SourceLib/$fileLeafRef" -ErrorAction SilentlyContinue
    $FolderExists = Get-PnpFolder -Url "$SourceSiteUrl/$SourceLib/$fileLeafRef" -ErrorAction SilentlyContinue 
    $details = @{
        "ClientTradingName" = $fileLeafRef
    }

    # Check if the item exists in the source library
    if ($fileExists -or $FolderExists) {
        
        # Get the modified date of the file or folder
        $item = Get-PnPListItem -List $SourceLib -Query "<View><Query><Where><Eq><FieldRef Name='FileLeafRef'/><Value Type='Text'>$fileLeafRef</Value></Eq></Where></Query></View>"
        $modifiedDate = [datetime]$item.FieldValues.Modified
        Write-Host $Row.'ClientTradingName'
        # Check if the modified date is before today
        if ($modifiedDate -lt "08/11/2024") {
            Write-Host "Copying $fileLeafRef to destination that is modified on $modifiedDate..."
            
            try {
                # Try to copy the file to the destination
                Copy-PnPFile -SourceUrl "$SourceLib/$fileLeafRef" -TargetUrl "/sites/$DestSite/$DestLib" -Force
                
                Write-Host "'$fileLeafRef' copied to destination!" -ForegroundColor Green
                $CopiedItems += New-Object PSObject -Property $details
                
                # Delete the file from the source
                Remove-PnPFile -ServerRelativeUrl "/sites/$SourceSite/$SourceLib/$fileLeafRef" -Force 
                Write-Host "'$fileLeafRef' deleted from source!" -ForegroundColor Green
            } catch {
                $errorMessage = $_.Exception.Message
                Write-Host "Error copying or deleting $fileLeafRef $errorMessage" -ForegroundColor Red            
            }
        } else {
            Write-Host "'$fileLeafRef' was modified after today, skipping..." -ForegroundColor Yellow
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
