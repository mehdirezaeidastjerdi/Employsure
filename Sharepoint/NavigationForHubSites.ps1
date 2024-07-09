# Install the PnP PowerShell module if not already installed
# Install-Module -Name "PnP.PowerShell" -Force -SkipPublisherCheck

# Connect to SharePoint Online
$siteUrl = "https://employsure.sharepoint.com/sites"
# $siteName = "EmploymentRelations"
$siteName = "EmploymentRelations"
Connect-PnPOnline -Url "$siteUrl/$siteName" -Interactive

# Define the parent node (label)
$parentNodeTitle = "Internal Departments"
$knowledgeHubTitle = "Knowledge Hub"

# Check if the parent node already exists and remove it if it does
$existingParentNodes = Get-PnPNavigationNode -Location "TopNavigationBar" | Where-Object { $_.Title -eq $parentNodeTitle }
foreach ($node in $existingParentNodes) {
    Write-Host "Removing existing parent node: $($node.Title)"
    Remove-PnPNavigationNode -Identity $node -Force
}

# Add the parent node to the Top Navigation as a label
Write-Host "Adding parent node (label): $parentNodeTitle"
$parentNode = Add-PnPNavigationNode -Location "TopNavigationBar" -Title $parentNodeTitle -Url "#"
if ($null -eq $parentNode) {
    Write-Host "Failed to create parent node: $parentNodeTitle"
    exit
} else {
    Write-Host "Successfully created parent node: $parentNodeTitle"
}

$childNodes = @(
    @{Title = "Clients AU"; Url = "$siteUrl/hs_au"},
    @{Title = "Clients NZ"; Url = "$siteUrl/hs_nz"},
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
    @{Title = "Employment Relations AU"; Url = "$siteUrl/ER_AU"},
    @{Title = "Employment Relations NZ"; Url = "$siteUrl/ER_NZ"},
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

# Check if the parent node already exists and remove it if it does
$existingParentNodes = Get-PnPNavigationNode -Location "TopNavigationBar" | Where-Object { $_.Title -eq $knowledgeHubTitle }
foreach ($node in $existingParentNodes) {
    Write-Host "Removing existing parent node: $($node.Title)"
    Remove-PnPNavigationNode -Identity $node -Force
}
# Add the Knowledge Hub node to the Top Navigation as a label
Write-Host "Adding parent node (label): $knowledgeHubTitle"
$knowledgeHubNode = Add-PnPNavigationNode -Location "TopNavigationBar" -Title $knowledgeHubTitle -Url "$siteurl/KnowledgeHub"
if ($null -eq $knowledgeHubNode) {
    Write-Host "Failed to create parent node: $knowledgeHubTitle"
    exit
} else {
    Write-Host "Successfully created parent node: $knowledgeHubTitle"
}

Write-Host "Top navigation nodes added successfully."
