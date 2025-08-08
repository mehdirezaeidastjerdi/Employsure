$ClientId = "e533e644-7841-414c-b988-3f5f668d388f"
$TenantId = "ef7f5213-d6d1-4d58-920b-f442749ee37d"
$CertificatePath = "C:\Certs\PnPCertificate.pfx"
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

function Export-RootFoldersBatches {
    param (
        [string]$SiteName,
        [string]$DocumentLibrary,
        [string]$ExportCsvPath,
        [int]$BatchSize = 5000
    )
    try {
        Connect-WithCertificate -SiteUrl "https://employsure.sharepoint.com/sites/$SiteName"

        Write-Host "Getting first 10,000 items from '$DocumentLibrary'..."

        $fieldsToLoad = @("ID", "FileLeafRef", "FileDirRef", "FSObjType")

        $ListItems = Get-PnPListItem -List $DocumentLibrary -PageSize $BatchSize -Fields $fieldsToLoad | Select-Object -First 10000

        $rootPath = "/sites/$SiteName/$DocumentLibrary"

        $FilteredItems = $ListItems | Where-Object {
            $_["FSObjType"] -eq 1 -and $_["FileDirRef"] -eq $rootPath
        }

        if ($FilteredItems.Count -eq 0) {
            Write-Host "No root-level folders found to export." -ForegroundColor Yellow
            return $false
        }

        $ExportData = $FilteredItems | Select-Object `
            @{Name="ID"; Expression={$_["ID"]}},
            @{Name="Name"; Expression={$_["FileLeafRef"]}},
            @{Name="Path"; Expression={$_["FileRef"]}},
            @{Name="Folder"; Expression={$true}}  # mark as folder for copy/delete logic

        Write-Host "Exporting root-level folder details to: $ExportCsvPath"
        $ExportData | Export-Csv -Path $ExportCsvPath -NoTypeInformation

        Write-Host "Export completed successfully!" -ForegroundColor Green

        return $true
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    finally {
        Disconnect-PnPOnline
    }
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

    Write-Host "Retrieving items from csv file..."

    $AllItems = Import-Csv $CsvPath

    foreach ($item in $AllItems) {
        $name = $item.Name
        $sourceRelativeUrl = "$SourceLib/$name"
        $targetRelativeUrl = "/sites/$DestSite/$DestLib"
        $type = [bool]::Parse($item.Folder)
        $ref = $item.Path

        Write-Host "Copying item '$name' from '$sourceRelativeUrl' to '$targetRelativeUrl'..."

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
            if (-not $type) {
                Remove-PnPFile -Url $ref -Force -Recycle
            }
            else {
                $parentPath = ($ref -replace "/$name$", "")
                Remove-PnPFolder -Name $name -Folder $parentPath -Force -Recycle
            }
            Write-Host "Deleted: $name"
        }
        catch {
            Write-Host "Failed to delete '$name': $($_.Exception.Message)" -ForegroundColor Red
            $FailedDeleteItems += [PSCustomObject]@{ Name = $name; Error = $_.Exception.Message }
        }
    }

    Disconnect-PnPOnline

    $outputFolder = ".\Logs"
    if (!(Test-Path $outputFolder)) { New-Item -ItemType Directory -Path $outputFolder | Out-Null }
    $CopiedItems | Export-Csv "$outputFolder\CopiedItems_$timestamp.csv" -NoTypeInformation
    $FailedCopyItems | Export-Csv "$outputFolder\FailedToCopyItems_$timestamp.csv" -NoTypeInformation
    $FailedDeleteItems | Export-Csv "$outputFolder\FailedToDeleteItems_$timestamp.csv" -NoTypeInformation

    Write-Host "Logs saved in '$outputFolder'"
}

# Main script execution

$SiteName = "technology"
$DocumentLibrary = "Obsolete Clients"
$ExportCsvPath = "C:\temp\rootfolders_to_copy.csv"
$DestinationSite = "technology_arch"
$DestinationLib = "Obsolete Clients"


while ($true) {
    $result = Export-RootFoldersBatches -SiteName $SiteName -DocumentLibrary $DocumentLibrary -ExportCsvPath $ExportCsvPath

    if ($result -eq $false) {
        Write-Host "No more folders to copy. Script finished." -ForegroundColor Yellow
        break
    }

    Copy-SPORootItems -CsvPath $ExportCsvPath -SourceSite $SiteName -SourceLib $DocumentLibrary -DestSite $DestinationSite -DestLib $DestinationLib
}
