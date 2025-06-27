function Copy-SPORootItems {
    param (
        [string]$SourceSite,
        [string]$SourceLib,
        [string]$DestSite,
        [string]$DestLib,
        [int]$PageSize = 2000  # PageSize used for retrieving list items
    )

    $SourceSiteUrl = "https://employsure.sharepoint.com/sites/$SourceSite"
    $DestSiteUrl = "https://employsure.sharepoint.com/sites/$DestSite"
    $RootPath = "/sites/$SourceSite/$SourceLib"

    try {
        # Connect to both source and destination sites
        Connect-PnPOnline -Url $SourceSiteUrl -Interactive -ClientId "3d6cec9b-ea30-48ff-a63d-5f7b6dec482d"
        Connect-PnPOnline -Url $DestSiteUrl -Interactive -ClientId "3d6cec9b-ea30-48ff-a63d-5f7b6dec482d"

        Write-Host "Retrieving root-level items from '$SourceLib'..." -ForegroundColor Cyan

        $AllItems = Get-PnPListItem -List $SourceLib -PageSize $PageSize -Fields "FileLeafRef", "FileRef", "FileDirRef", "FSObjType" | Where-Object {
            $_["FileDirRef"] -eq $RootPath
        }

        Write-Host "Total root-level items to copy: $($AllItems.Count)" -ForegroundColor Cyan

        $CopiedItems = @()
        $SkippedItems = @()
        $FailedItems = @()

        foreach ($item in $AllItems) {
            $name = $item["FileLeafRef"]
            $ref = $item["FileRef"]
            $sourceRelativeUrl = $ref
            $targetRelativeUrl = "/sites/$DestSite/$DestLib/$name"

            try {
                # First check if folder exists in the destination
                $exists = Get-PnPFolder -Url $targetRelativeUrl -ErrorAction SilentlyContinue

                if (-not $exists) {
                    # If not a folder, check if a file exists
                    $exists = Get-PnPFile -Url $targetRelativeUrl -ErrorAction SilentlyContinue
                }

                if ($exists) {
                    Write-Host "⚠ Skipping '$name' – already exists in destination." -ForegroundColor DarkYellow
                    $SkippedItems += $name
                    continue
                }

                # Proceed with copy if it doesn't exist
                Copy-PnPFile -SourceUrl $sourceRelativeUrl -TargetUrl $targetRelativeUrl -Force
                Write-Host "Copied '$name'" -ForegroundColor Green
                $CopiedItems += $name
            }
            catch {
                Write-Host "Failed to copy '$name': $($_.Exception.Message)" -ForegroundColor Red
                $FailedItems += $name
            }
        }

        Disconnect-PnPOnline

        # Summary
        Write-Host "`nCopying completed." -ForegroundColor Green
        Write-Host "$($CopiedItems.Count) items copied." -ForegroundColor Green
        Write-Host "$($SkippedItems.Count) items skipped (already existed)." -ForegroundColor DarkYellow
        if ($FailedItems.Count -gt 0) {
            Write-Host "$($FailedItems.Count) items failed to copy:" -ForegroundColor Red
            $FailedItems | ForEach-Object { Write-Host " - $_" }
        }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Copy-SPORootItems `
    -SourceSite "technology" `
    -SourceLib "Clients_EMP_OLD_Test" `
    -DestSite "technology" `
    -DestLib "Clients_EMP_OLD_Test_Migrated" `
    -PageSize 2000
