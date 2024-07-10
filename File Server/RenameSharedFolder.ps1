# Define the folder path and new name
$folderPath = "L:\Service Data\3.Advice Services\1.Resources\1.A-Z"
$newFolderName = "1.Archived A-Z"

# Function to close all open files in the folder
function Close-OpenFilesInFolder {
    param (
        [string]$folderPath
    )

    $openFiles = Get-SmbOpenFile | Where-Object { $_.Path -like "$folderPath*" }
    foreach ($file in $openFiles) {
        Close-SmbOpenFile -FileId $file.FileId -Force
    }

    # Return the number of remaining open files
    return (Get-SmbOpenFile | Where-Object { $_.Path -like "$folderPath*" }).Count
}

# Close open files and wait until all files are closed
while ((Close-OpenFilesInFolder -folderPath $folderPath) -gt 0) {
    Write-Output "Waiting for files to close..."
    Start-Sleep -Seconds 5
}

# Rename the folder
Rename-Item -Path $folderPath -NewName $newFolderName

Write-Output "Folder renamed successfully to '$newFolderName'."
