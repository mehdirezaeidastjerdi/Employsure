
$SiteName = "SharePointTesting"
$SourceURL = "Shared Documents"
$TargetURL = "Archive"
$UnmatchedFilePath = "C:\temp\test\Unmatched_test.csv"
$ArchivedItemsPath = "C:\temp\test\ArchivedItems.csv"
$NotExistInSourceItemsPath = "C:\temp\test\NotExistInSourceItems.csv"
$NotExistInDestItemsPath = "C:\temp\test\NotExistInDestItems.csv"
$FullSiteUrl = "https://employsure.sharepoint.com/sites/SharePointTesting"
# Connect to SharePoint Online
Connect-PnPOnline -Url $FullSiteUrl -Interactive
# Load the Excel data
$Unmatched = Import-Csv $UnmatchedFilePath
$ArchivedItems = @()
$NotExistInSourceItems = @()
$NotExistInDestItems = @()
try {    
    # Iterate through each row in the Excel data
    foreach ($Row in $Unmatched) {        
        $fileLeafRef = $Row.'ClientTradingName'  # Replace with the actual column name containing file names
        $details = @{
            "Items" = $fileLeafRef
        }        
        $fileExists = Get-PnPFile -Url "$SourceURL/$fileLeafRef" -ErrorAction SilentlyContinue
        if($fileExists){
            # Copy the file into the Target library
            Write-Host "Copying '$fileLeafRef' to '$TargetURL'"
            Copy-PnPFile -SourceUrl "$SourceURL/$fileLeafRef" -TargetUrl "$TargetURL/$fileLeafRef" -Force 
            # Wait for a few seconds (optional)
            Write-Host "'$fileLeafRef' successfully copied to the destination library." -ForegroundColor Green
            # Check if the file exists in the target library
            $Folder = Get-PnPFolder -Url "$TargetURL/$fileLeafRef" -ErrorAction SilentlyContinue
            $File = Get-PnPFile -Url "$TargetURL/$fileLeafRef" -ErrorAction SilentlyContinue
            if ($Folder) {
                Write-Host "The folder '$Folder' exists in the target library."
                # Remove the folder from the source library
                Write-Host "Removing '$fileLeafRef' from '$SourceURL'"
                Remove-PnPFile -SiteRelativeUrl "$SourceURL/$fileLeafRef" -Force -Recycle
                Write-Host "Folder '$fileLeafRef' removed from the source library." -ForegroundColor Yellow                
                $ArchivedItems += New-Object PSObject -Property $details
                
            }elseif ($File) {
                Write-Host "The file '$fileLeafRef' exists in the destination library."
                # Remove the file from the source library
                Write-Host "Removing '$fileLeafRef' from '$SourceURL'"
                Remove-PnPFile -SiteRelativeUrl "$SourceURL/$fileLeafRef" -Force -Recycle
                Write-Host "File '$fileLeafRef' removed from source library." -ForegroundColor Yellow
                $ArchivedItems += New-Object PSObject -Property $details        
            }else {
                $NotExistInDestItems += New-Object PSObject -Property $details
                Write-Host "'$fileLeafRef' does not exist in the target library!"          
            }        
        } else{
            $NotExistInSourceItems += New-Object PSObject -Property $details
            Write-Host "'$fileLeafRef' does not exists in source library!"
        }            
    }
    
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
$ArchivedItems | Format-Table
$NotExistInSourceItems | Format-Table
$NotExistInDestItems | Format-Table
# Export to csv
$ArchivedItems | Export-Csv -Path $ArchivedItemsPath -NoTypeInformation
$NotExistInSourceItems | Export-Csv -Path $NotExistInSourceItemsPath -NoTypeInformation
$NotExistInDestItems | Export-Csv -Path $NotExistInDestItemsPath -NoTypeInformation