# Assuming you have the Excel file path and sheet name
$ExcelFilePath = "C:\Path\To\Your\ExcelFile.xlsx"
$SheetName = "Sheet1"

# Load the Excel data
$ExcelData = Import-Excel -Path $ExcelFilePath -WorksheetName $SheetName

# Iterate through each row in the Excel data
foreach ($Row in $ExcelData) {
    $fileLeafRef = $Row.ColumnName # Replace with the actual column name containing file names
    Copy-PnPFile -SourceUrl "$SourceURL/$fileLeafRef" -TargetUrl "$TargetURL/$fileLeafRef" -Force
}

Write-Host "All files successfully copied to destination." -ForegroundColor Green
