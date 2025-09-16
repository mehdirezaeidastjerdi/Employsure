$ClientId = "e533e644-7841-414c-b988-3f5f668d388f"
$TenantId = "ef7f5213-d6d1-4d58-920b-f442749ee37d"
$CertificatePath = "C:\Certs\PnPCertificate.pfx"
$CertificatePassword = ConvertTo-SecureString $env:PNP_CERT_PASSWORD -AsPlainText -Force

Import-Module PnP.PowerShell

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
        [string]$SourceLib
    )

    $SourceSiteUrl = "https://employsure.sharepoint.com/sites/$SourceSite"
    $RootPath = "/sites/$SourceSite/$SourceLib"

    try {
        Connect-WithCertificate -SiteUrl $SourceSiteUrl 
        Write-Host "Deleting items from CSV for '$SourceLib'..."

        # Import CSV and clean up column values
        $AllItems = Import-Csv -Path "C:\temp\technology_Obsolete_Clients.csv" | ForEach-Object {
            [PSCustomObject]@{
                Name       = $_.Name.Trim()
                Path       = $_.Path.Trim()
                Folder     = $_.Folder.Trim()
                FileDirRef = $_.FileDirRef.Trim()
            }
        }

        $DeletedItems = @()
        $FailedItems = @()
        $rowIndex = 1

        foreach ($item in $AllItems) {
            $name = $item.Name
            $ref = $item.Path
            $isFolder = $false

            # Validate row
            if ([string]::IsNullOrWhiteSpace($ref)) {
                Write-Host "⚠️ Row $rowIndex Skipping — Path is empty." -ForegroundColor Yellow
                $rowIndex++
                continue
            }

            try {
                # Convert Folder string (TRUE/FALSE) to boolean
                $isFolder = [System.Convert]::ToBoolean($item.Folder)

                if ($isFolder) {
                    # Extract parent folder path
                    $parentPath = ($ref -replace "/$([regex]::Escape($name))$", "")
                    Write-Host "Deleting folder: $ref"
                    Remove-PnPFolder -Name $name -Folder $parentPath -Force -ErrorAction Stop
                }
                else {
                    Write-Host "Deleting file: $ref"
                    Remove-PnPFile -ServerRelativeUrl $ref -Force -ErrorAction Stop
                }

                Write-Host "🗑️ Row $rowIndex Deleted '$name'" -ForegroundColor Green
                $DeletedItems += $name
            }
            catch {
                Write-Host "❌ Row $rowIndex Failed to delete '$name': $($_.Exception.Message)" -ForegroundColor Red
                $FailedItems += $name
            }

            $rowIndex++
        }

        Disconnect-PnPOnline

        Write-Host ""
        Write-Host "✅ Deletion completed."
        Write-Host "$($DeletedItems.Count) items deleted."
        if ($FailedItems.Count -gt 0) {
            Write-Host "$($FailedItems.Count) items failed to delete:"
            $FailedItems | ForEach-Object { Write-Host " - $_" }
        }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}


# Run the cleanup
Remove-SPORootItems -SourceSite "Technology" -SourceLib "Obsolete Clients"
