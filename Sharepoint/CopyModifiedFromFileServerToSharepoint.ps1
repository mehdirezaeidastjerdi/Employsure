# Prerequisites
$rootDirectory = "C:\temp\Modified data"
$startDate = Get-Date "2024-07-18"
# $endDate = Get-Date "2024-07-19"
$outputCsv = "C:\Temp\ModifiedFoldersAfter-18072024.csv"
$results = @()

function Get-ModifiedItems($directory, $startDate) {
    Get-ChildItem -Path $directory -Directory | Where-Object {
        $_.LastWriteTime -ge $startDate 
    }
}

$excludeFolders = @("New folder", "New folder (2)")
$clientDirectories = Get-ChildItem -Path $rootDirectory -Directory | Where-Object {
    $excludeFolders -notcontains $_.Name
}

foreach ($clientDirectory in $clientDirectories) {
    Write-Host "Checking folder: $($clientDirectory.FullName)"
    $modifiedItems = Get-ModifiedItems -directory $clientDirectory.FullName -startDate $startDate
    
    if ($modifiedItems.Count -gt 0) {
        foreach ($item in $modifiedItems) {
            $results += [PSCustomObject]@{
                "Client Folder" = $clientDirectory.FullName
                "Modified Folder" = $item.FullName
                "Last Modified" = $item.LastWriteTime
            }
        }
    }
}
$results | Format-Table -AutoSize
$results | Export-Csv -Path $outputCsv -NoTypeInformation

# SharePoint Online Connection
$siteUrl = "https://employsure.sharepoint.com/sites/Testsite"
Connect-PnPOnline -Url $siteUrl -UseWebLogin

# Function to upload files
function  UploadFilesToSharePoint{
    param (
        [string]$sourceFolder,
        [string]$destinationFolder
    )
    $items = Get-ChildItem -Path $sourceFolder -Recurse

    foreach ($item in $items) {
        $relativePath = $item.FullName.Substring($sourceFolder.Length).TrimStart("\")
        $destinationPath = Join-Path -Path $destinationFolder -ChildPath $relativePath

        if ($item.PSIsContainer) {
            # Create folder if it doesn't exist
            $folderExists = Test-PnPListItem -List $destinationLibrary -ItemUrl $destinationPath
            if (-not $folderExists) {
                New-PnPFolder -Name $destinationPath -Folder (Split-Path $destinationPath -Parent)
            }
        } else {
            Write-Host "Uploading file $($item.FullName) to $destinationPath"
            Add-PnPFile -Path $item.FullName -Folder $destinationPath
        }
    }
}

# Copy Modified Folders
$destinationLibrary = "Documents"

foreach ($result in $results) {
    $sourceFolder = $result.'Modified Folder'
    $destinationFolder = "$destinationLibrary/$($result.'Client Folder')"

    Write-Host "Copying $sourceFolder to $destinationFolder"

    # Ensure the destination folder exists
    $folderExists = Get-PnPFolder -Url "$destinationFolder" -ErrorAction SilentlyContinue
    if (-not $folderExists) {
        New-PnPFolder -Name $destinationFolder -Folder (Split-Path $destinationFolder -Parent)
    }

    # Upload files to SharePoint
    UploadFilesToSharePoint -sourceFolder $sourceFolder -destinationFolder $destinationFolder
}

Write-Host "Modified Folders:" -BackgroundColor Yellow
Write-Host "Results have been saved to $outputCsv"
