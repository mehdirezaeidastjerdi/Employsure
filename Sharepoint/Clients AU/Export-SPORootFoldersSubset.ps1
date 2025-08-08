function Export-RootFoldersForTop10 {
    param (
        [string]$SiteName,
        [string]$DocumentLibrary,
        [string]$ExportCsvPath,
        [int]$BatchSize = 5000
    )
    try {
        Connect-WithCertificate -SiteUrl "https://employsure.sharepoint.com/sites/$SiteName"

        Write-Host "Getting first 10 items from '$DocumentLibrary'..."

        $fieldsToLoad = @("ID", "FileLeafRef", "FileDirRef", "FSObjType")

        $timer = Measure-Command {
            $ListItems = Get-PnPListItem -List $DocumentLibrary -PageSize $BatchSize -Fields $fieldsToLoad | Select-Object -First 10000
        }

        Write-Host "Elapsed time: $timer"

        $rootPath = "/sites/$SiteName/$DocumentLibrary"

        $FilteredItems = $ListItems | Where-Object {
            $_["FSObjType"] -eq 1 -and $_["FileDirRef"] -eq $rootPath
        }

        $ExportData = $FilteredItems | Select-Object `
            @{Name="ID"; Expression={$_["ID"]}},
            @{Name="Name"; Expression={$_["FileLeafRef"]}},
            @{Name="Path"; Expression={$_["FileDirRef"]}},
            @{Name="ObjectType"; Expression={"Folder"}}

        Write-Host "Exporting root-level folder details to: $ExportCsvPath"
        $ExportData | Export-Csv -Path $ExportCsvPath -NoTypeInformation
        $ExportData | Format-Table

        Write-Host "Export completed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    finally {
        Disconnect-PnPOnline
    }
}

Export-RootFoldersForTop10 -SiteName "technology" -DocumentLibrary "Obsolete Clients" -ExportCsvPath "C:\temp\rootfolders.csv"

