$ClientId = "e533e644-7841-414c-b988-3f5f668d388f"
$TenantId = "ef7f5213-d6d1-4d58-920b-f442749ee37d"
$CertificatePath = "C:\Certs\PnPCertificate.pfx"
$CertificatePassword = ConvertTo-SecureString "****" -AsPlainText -Force

Import-Module PnP.PowerShell

Get-Module
function Connect-WithCertificate {
    param (
        [string]$SiteUrl
    )
    try {
        Connect-PnPOnline `
            -Url $SiteUrl `
            -ClientId $ClientId `
            -Tenant $TenantId `
            -CertificatePath $CertificatePath `
            -CertificatePassword $CertificatePassword `
            -ErrorAction Stop
        Write-Host "Connected to: $SiteUrl" -ForegroundColor Green
    }
    catch {
        throw "Failed to connect to $SiteUrl : $($_.Exception.Message)"
    }
}

function Remove-SPORootItems {
    param (
        [string]$SourceSite,
        [string]$SourceLib,
        [int]$PageSize = 2000
    )
    $SourceSiteUrl = "https://employsure.sharepoint.com/sites/$SourceSite"
    $RootPath = "/sites/$SourceSite/$SourceLib"

    try {
        Connect-WithCertificate -SiteUrl $SourceSiteUrl 
        Write-Host "Retrieving root-level items from '$SourceLib' for deletion (PageSize=$PageSize)..."

        $AllItems = Get-PnPListItem -List $SourceLib -PageSize $PageSize -Fields "FileLeafRef", "FileRef", "FileDirRef", "FSObjType" | Where-Object {
            $_["FileDirRef"] -eq $RootPath
        }
        $DeletedItems = @()
        $FailedItems = @()

        foreach ($item in $AllItems) {

            $name = $item["FileLeafRef"]
            $ref = $item["FileRef"]
            $type = $item["FSObjType"]

            try {
                if ($type -eq 0) {
                    Remove-PnPFile -Url $ref -Force
                }
                elseif ($type -eq 1) {
                    # Extract parent folder path
                    $parentPath = ($ref -replace "/$name$", "")  # removes folder name from path
                    Remove-PnPFolder -Name $name -Folder $parentPath -Force
                }
                Write-Host "🗑️ Deleted: $name"
                $DeletedItems += $name
            }
            catch {
                Write-Host "Failed to delete '$name': $($_.Exception.Message)"
                $FailedItems += $name
            }
        }
        Disconnect-PnPOnline
        Write-Host ""
        Write-Host "Deletion completed."
        Write-Host "$($DeletedItems.Count) items deleted."
        if ($FailedItems.Count -gt 0) {
            Write-Host "$($FailedItems.Count) items failed to delete:"
            $FailedItems | ForEach-Object { Write-Host " - $_" }
        }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)"
    }
}
# Run the cleanup
Remove-SPORootItems -SourceSite "hs_au_arch" -SourceLib "Clients_EMP_Test" -PageSize 2000
