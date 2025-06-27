$ClientId = "e533e644-7841-414c-b988-3f5f668d388f"
$TenantId = "ef7f5213-d6d1-4d58-920b-f442749ee37d"
$CertificatePath = "C:\Certs\PnPCertificate.pfx"
$CertificatePassword = ConvertTo-SecureString "****" -AsPlainText -Force

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

        }
        catch {
            Write-Host "Failed to copy item '$name': $($_.Exception.Message)" -ForegroundColor Red
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
                $DeletedItems += $name
        }
        catch {
                Write-Host "Failed to delete '$name': $($_.Exception.Message)" -ForegroundColor Red
                $FailedItems += $name
            }
    }

    Disconnect-PnPOnline
}

# Run the copy and remove process
Copy-SPORootItems `
    -SourceSite "hs_au_arch" `
    -SourceLib "Clients_EMP_Test" `
    -DestSite "Technology" `
    -DestLib "Clients_EMP_Modified_Test" `
    -PageSize 2000
