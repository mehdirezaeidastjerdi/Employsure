# Parameters for certificate authentication
$ClientId = "e533e644-7841-414c-b988-3f5f668d388f"
$TenantId = "ef7f5213-d6d1-4d58-920b-f442749ee37d"
$CertificatePath = "C:\Certs\PnPCertificate.pfx"
$CertificatePassword = ConvertTo-SecureString "****" -AsPlainText -Force

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
        Write-Host "Successfully connected to: $SiteUrl" -ForegroundColor Green
    }
    catch {
        throw "Failed to connect to $SiteUrl : $($_.Exception.Message)"
    }
}
function Export-SPOLibraryItems {
    param (
        [string]$SiteName,
        [string]$DocumentLibrary,
        [string]$ExportCsvPath,
        [int]$BatchSize = 2000
    )
    try {
        # Connect to SharePoint Online site using pnp powershell app o azure entra id applications
        # Connect-PnPOnline -Url "https://employsure.sharepoint.com/sites/$SiteName" -Interactive -ClientId "3d6cec9b-ea30-48ff-a63d-5f7b6dec482d"
        Connect-WithCertificate -SiteUrl "https://employsure.sharepoint.com/sites/$SiteName"
        Write-Host "Retrieving all items (including folders) from the '$DocumentLibrary' library in site '$SiteName'..."

        $timer = Measure-Command {
            # Retrieve all items from the root of the document library (both files and folders)
            $ListItems = Get-PnPListItem -List $DocumentLibrary -PageSize $BatchSize -Fields "FileLeafRef", "FileRef", "FileDirRef", "FSObjType" | Where-Object {
                $_["FileDirRef"] -eq "/sites/$SiteName/$DocumentLibrary"
            }
        }

        Write-Host "Elapsed time: $timer"
        Write-Host "Exporting $(($ListItems).Count) items (files and folders) to: $ExportCsvPath"

        # Convert to exportable objects
        $ExportData = $ListItems | ForEach-Object {
            [PSCustomObject]@{
                Name       = $_["FileLeafRef"]
                Path       = $_["FileRef"]
                Folder     = $_["FSObjType"] -eq 1  # True if it's a folder
                FileDirRef = $_["FileDirRef"]
            }
        }

        # Export to CSV
        $ExportData | Export-Csv -Path $ExportCsvPath -NoTypeInformation

        # Optional: display
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

Export-SPOLibraryItems -SiteName "Technology" -DocumentLibrary "Clients_EMP_Test" -ExportCsvPath "C:\temp\Technology_Clients_EMP_Test.csv" 