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

    Write-Host "Retrieving root-level items from '$SourceLib'..."

    $AllItems = Get-PnPListItem -List $SourceLib -PageSize $PageSize -Fields "FileLeafRef", "FileRef", "FileDirRef", "FSObjType" | Where-Object {
        $_["FileDirRef"] -eq $RootPath
    }

    Write-Host "Found $($AllItems.Count) root items."

    foreach ($item in $AllItems) {
        $name = $item["FileLeafRef"]
        $sourceRelativeUrl = "$SourceLib/$name"
        $fullSourceUrl = "/sites/$SourceSite/$sourceRelativeUrl"
        $targetRelativeUrl = "/sites/$DestSite/$DestLib"
        $type = $item["FSObjType"]
        $ref = $item["FileRef"]
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
                if ($type -eq 0) {
                    Remove-PnPFile -Url $ref -Force
                }
                elseif ($type -eq 1) {
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
    -SourceSite "Technology" `
    -SourceLib "Obsolete Clients" `
    -DestSite "technology_arch" `
    -DestLib "Obsolete Clients" `
    -PageSize 2000
