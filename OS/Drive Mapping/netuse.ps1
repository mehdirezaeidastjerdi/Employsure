$storageAccount = "itteam01"
$container = "mappeddrive-reports"
$sasToken = "?sp=cw&st=2026-02-06T03:35:37Z&se=2026-02-07T11:50:37Z&spr=https&sv=2024-11-04&sr=c&sig=txd3EdZc8VAjYl%2FCB9so2XmpC0K7LTMbGuGdsxqf1Jc%3D"

# https://itteam01.blob.core.windows.net/mappeddrive-reports?sp=acw&st=2026-02-06T03:09:42Z&se=2026-02-06T11:24:42Z&spr=https&sv=2024-11-04&sr=c&sig=StipJ9OTGlo1%2FppPAm4RtB6XGiGoQJFqmaEAAvjunxQ%3D
$blobName = "$env:COMPUTERNAME-$env:USERNAME-$(Get-Date -Format yyyyMMdd-HHmmss).txt"

$report = net use | Out-String
$tempFile = Join-Path $env:TEMP $blobName
$report | Out-File $tempFile -Encoding UTF8

$uri = "https://$storageAccount.blob.core.windows.net/$container/$blobName$sasToken"

Invoke-RestMethod -Uri $uri `
    -Method Put `
    -InFile $tempFile `
    -Headers @{ "x-ms-blob-type" = "BlockBlob" }
