$ClientId = "e533e644-7841-414c-b988-3f5f668d388f"
$TenantId = "ef7f5213-d6d1-4d58-920b-f442749ee37d"
$CertificatePath = "C:\Certs\PnPCertificate.pfx"
# Get certifacate password from env variables
$CertificatePassword = ConvertTo-SecureString $env:PNP_CERT_PASSWORD -AsPlainText -Force
function Connect-WithCertificate {
    param ([string]$SiteUrl)
    Connect-PnPOnline `
        -Url $SiteUrl `
        -ClientId $ClientId `
        -Tenant $TenantId `
        -CertificatePath $CertificatePath `
        -CertificatePassword $CertificatePassword -ErrorAction Stop
    Write-Host "Connected to $SiteUrl"
}

function Copy-SPORootItems {
    param (
        [string]$CsvPath,
        [string]$SourceSite,
        [string]$SourceLib,
        [string]$DestSite,
        [string]$DestLib,
        [int]$PageSize = 2000
    )

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $CopiedItems = @()
    $FailedCopyItems = @()
    $FailedDeleteItems = @()

    $SourceSiteUrl = "https://employsure.sharepoint.com/sites/$SourceSite"
    $DestSiteUrl = "https://employsure.sharepoint.com/sites/$DestSite"

    
    Connect-WithCertificate -SiteUrl $DestSiteUrl
    Connect-WithCertificate -SiteUrl $SourceSiteUrl

    $RootPath = "/sites/$SourceSite/$SourceLib"

    Write-Host "Retrieving items from csv file..."

    $AllItems = Import-Csv $CsvPath
    
    
    foreach ($item in $AllItems) {
        $name = $item.name
        $sourceRelativeUrl = "$SourceLib/$name"
        $fullSourceUrl = "/sites/$SourceSite/$sourceRelativeUrl"
        $targetRelativeUrl = "/sites/$DestSite/$DestLib"
        $type = [bool]::Parse($item.Folder)
        $ref = $item.path
        Write-Host "Copying item '$name' from '$fullSourceUrl' to '$targetRelativeUrl'..."

        try {
            
            Copy-PnPFile -SourceUrl $sourceRelativeUrl -TargetUrl $targetRelativeUrl -Force -Overwrite
            Write-Host "Copied '$name' successfully."
            $CopiedItems += [PSCustomObject]@{ Name = $name; Status = "Copied" }

        }
        catch {
            Write-Host "Failed to copy item '$name': $($_.Exception.Message)" -ForegroundColor Red
            $FailedCopyItems += [PSCustomObject]@{ Name = $name; Error = $_.Exception.Message }
        }
        try {
                if (-not $type) { # if it's a file
                    Remove-PnPFile -Url $ref -Force
                }
                else {
                    # Extract parent folder path
                    $parentPath = ($ref -replace "/$name$", "")  # removes folder name from path
                    Remove-PnPFolder -Name $name -Folder $parentPath -Force
                }
                Write-Host "Deleted: $name"
        }
        catch {
                Write-Host "Failed to delete '$name': $($_.Exception.Message)" -ForegroundColor Red
                $FailedDeleteItems += [PSCustomObject]@{ Name = $name; Error = $_.Exception.Message }
            }
    }

    Disconnect-PnPOnline
    # Export logs
    $outputFolder = ".\Logs"
    if (!(Test-Path $outputFolder)) { New-Item -ItemType Directory -Path $outputFolder | Out-Null }
    $CopiedItems | Export-Csv "$outputFolder\CopiedItems_$timestamp.csv" -NoTypeInformation
    $FailedCopyItems | Export-Csv "$outputFolder\FailedToCopyItems_$timestamp.csv" -NoTypeInformation
    $FailedDeleteItems | Export-Csv "$outputFolder\FailedToDeleteItems_$timestamp.csv" -NoTypeInformation
    Write-Host "Logs saved in '$outputFolder'"

}

# Run the copy and remove process
Copy-SPORootItems `
    -CsvPath "C:\temp\Technology_Clients_EMP_Modified.csv" `
    -SourceSite "hs_au" `
    -SourceLib "Clients_EMP_Modified" `
    -DestSite "hs_au_arch" `
    -DestLib "Clients_EMP_Modified" `
    -PageSize 2000
