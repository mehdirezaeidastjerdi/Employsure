Import-Module Microsoft.Graph

function Get-SharePointSiteFolders {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SiteSearchTerm,

        [Parameter(Mandatory = $true)]
        [string]$LibraryName
    )

    # Connect to Microsoft Graph with proper scope
    Connect-MgGraph -Scopes "Sites.Read.All, Sites.ReadWrite.All"

    # Search for all modern sites under the domain
    $sites = Get-MgSite -Search "/sites/$SiteSearchTerm"

    # Get the first matching site by URL or name
    $targetSite = ($sites | Where-Object {
        $_.WebUrl -like "*$SiteSearchTerm*" -or $_.DisplayName -like "*$SiteSearchTerm*"
    }) | Select-Object -First 1

    # Show the site result
    if ($null -ne $targetSite) {
        Write-Host "Site found:" -ForegroundColor Green
        Write-Host "Name: $($targetSite.DisplayName)" 
        Write-Host "URL : $($targetSite.WebUrl)"
        Write-Host "ID  : $($targetSite.Id)"
    } else {
        Write-Warning "Site '$SiteSearchTerm' not found."
        return
    }

    # Get the Drive (library)
    $drive = Get-MgSiteDrive -SiteId $targetSite.Id | Where-Object { $_.Name -eq $LibraryName }

    if ($null -eq $drive) {
        Write-Error "Drive for '$LibraryName' library not found."
        return
    }

    # Get items in the root of the library
    $items = Get-MgDriveItemChild -DriveId $drive.Id -DriveItemId "root"

    # Filter only folders
    $folders = $items | Where-Object { $_.Folder -ne $null }

    return $folders
}

# Example usage
$folders = Get-SharePointSiteFolders -SiteSearchTerm "Technology" -LibraryName "Clients_EMP_Modified_Test"

Write-Host "Folders in the specified library of the site:"
foreach ($folder in $folders) {
    Write-Host "- $($folder.Name)" -ForegroundColor Green
}

# Disconnect-MgGraph # optional
