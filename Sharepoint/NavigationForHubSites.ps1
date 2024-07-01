# Install the PnP PowerShell module if not already installed
# Install-Module -Name "PnP.PowerShell" -Force -SkipPublisherCheck

# Connect to SharePoint Online
$siteUrl = "https://employsure.sharepoint.com/sites"
$siteName = "SalesHubSite"
Connect-PnPOnline -Url "$siteUrl/$siteName" -Interactive

# Define the parent node (label)
$parentNodeTitle = "Internal Department"

# Add the parent node to the Top Navigation as a label
Write-Host "Adding parent node (label): $parentNodeTitle"
$parentNode = Add-PnPNavigationNode -Location "TopNavigationBar" -Title $parentNodeTitle -Url "#"
if ($null -eq $parentNode) {
    Write-Host "Failed to create parent node: $parentNodeTitle"
    exit
} else {
    Write-Host "Successfully created parent node: $parentNodeTitle"
}

# Define the child nodes to be added under the parent node
$childNodes = @(
    @{Title = "Clients AU"; Url = "$siteUrl/hs_au"},
    @{Title = "Clients NZ"; Url = "$siteUrl/hs_nz"}
    @{Title = "Management"; Url = "$siteUrl/management"},
    @{Title = "Legal"; Url = "$siteUrl/legal"},
    @{Title = "Marketing and Events"; Url = "$siteUrl/events"},
    @{Title = "Finance"; Url = "$siteUrl/Finance"},
    @{Title = "Facilities"; Url = "$siteUrl/TalentAcquisitionANZ"},
    @{Title = "Payroll"; Url = "$siteUrl/Payroll"},
    @{Title = "HR"; Url = "$siteUrl/HR"},
    @{Title = "Sales"; Url = "$siteUrl/Sales"},
    @{Title = "Technology"; Url = "$siteUrl/Technology"},
    @{Title = "Clients Engagement"; Url = "https://employsure.sharepoint.com/teams/ClientOnboardingANZ"},
    @{Title = "Employment Ralations AU"; Url = "$siteUrl/ER_AU"},
    @{Title = "Employment Ralations NZ"; Url = "$siteUrl/ER_NZ"},
    @{Title = "Health & Safety AU"; Url = "$siteUrl/healthsafety_au"},
    @{Title = "Health & Safety NZ"; Url = "$siteUrl/healthsafety_nz"}
)

# Add the child nodes under the parent node
foreach ($childNode in $childNodes) {
    Write-Host "Adding child node: $($childNode.Title)"
    try {
        $newChildNode = Add-PnPNavigationNode -Location "TopNavigationBar" -Title $childNode.Title -Url $childNode.Url -Parent $parentNode
        if ($null -eq $newChildNode) {
            Write-Host "Failed to create child node: $($childNode.Title)"
        } else {
            Write-Host "Successfully created child node: $($childNode.Title)"
        }
    } catch {
        Write-Host "Error creating child node: $($childNode.Title). Error: $_"
    }
}

Write-Host "Top navigation nodes added successfully."