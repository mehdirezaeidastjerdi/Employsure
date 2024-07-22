# Install the PnP PowerShell module if not already installed
# Install-Module -Name "PnP.PowerShell" -Force -SkipPublisherCheck

# Connect to SharePoint Online
$siteUrl = "https://employsure.sharepoint.com/sites"
# $siteName = "SalesHubSite"
# $siteName = "EmploymentRelations"
# $siteName = "HealthSafety"
# $siteName = "ClientEngagement"
# $siteName = "KnowledgeHub"
# $siteName = "legal"
# $siteName = "events"
# $siteName = "Finance"
# $siteName = "Management"
# $siteName = "TalentAcquisitionANZ"
$siteName = "LegalServices"

# $hubSitesPath = ""
# $hubSites = Import-Csv -Path $hubSitesPath



# Connect-PnPOnline -Url "$siteUrl/$siteName" -Interactive
Connect-PnPOnline -Url $siteUrl/$siteName -Interactive

function Add-ParentNode {
    param (
        [string]$parentNodeTitle,
        [string]$parentNodeUrl
    )

    # Check if the parent node already exists and remove it if it does
    $existingParentNodes = Get-PnPNavigationNode -Location "TopNavigationBar" | Where-Object { $_.Title -eq $parentNodeTitle }
    foreach ($node in $existingParentNodes) {
        Write-Host "Removing existing parent node: $($node.Title)"
        Remove-PnPNavigationNode -Identity $node -Force
    }
    Start-Sleep 5
    # Add the parent node to the Top Navigation as a label
    Write-Host "Adding parent node (label): $parentNodeTitle"
    $parentNode = Add-PnPNavigationNode -Location "TopNavigationBar" -Title $parentNodeTitle -Url $parentNodeUrl
    if ($null -eq $parentNode) {
        Write-Host "Failed to create parent node: $parentNodeTitle" -ForegroundColor Red
        exit
    } else {
        Write-Host "Successfully created parent node: $parentNodeTitle" -ForegroundColor Green
    }
    return $parentNode.Id
}

# Define parent nodes with their respective URLs
$intranetNodeTitle = "Intranet"
$intranetNodeUrl = "https://employsure.sharepoint.com"

$InternalDepartmentsNodeTitle = "Internal Departments"
$InternalDepartmentsNodeUrl = "#"

$knowledgeHubTitle = "Knowledge Hub"
$knowledgeHubUrl = "$siteUrl/KnowledgeHub"

# Add the parent nodes
$intranetNode = Add-ParentNode -parentNodeTitle $intranetNodeTitle -parentNodeUrl $intranetNodeUrl

$InternalDepartmentsNode = Add-ParentNode -parentNodeTitle $InternalDepartmentsNodeTitle -parentNodeUrl $InternalDepartmentsNodeUrl

$knowledgeHubNode = Add-ParentNode -parentNodeTitle $knowledgeHubTitle -parentNodeUrl $knowledgeHubUrl

$childNodes = @(
    # @{Title = "Management"; Url = "$siteUrl/management"},
    @{Title = "Clients AU"; Url = "$siteUrl/hs_au"},
    @{Title = "Clients NZ"; Url = "$siteUrl/hs_nz"},
    @{Title = "Health & Safety AU"; Url = "$siteUrl/healthsafety_au"},
    @{Title = "Health & Safety NZ"; Url = "$siteUrl/healthsafety_nz"},
    @{Title = "Employment Relations AU"; Url = "$siteUrl/ER_AU"},
    @{Title = "Employment Relations NZ"; Url = "$siteUrl/ER_NZ"},
    @{Title = "Client Onboarding"; Url = "https://employsure.sharepoint.com/teams/ClientOnboardingANZ"},
    @{Title = "Law"; Url = "$siteUrl/Law-au"},
    # @{Title = "Marketing and Events"; Url = "$siteUrl/events"},
    # @{Title = "Finance"; Url = "$siteUrl/Finance"},
    # @{Title = "Facilities"; Url = "$siteUrl/TalentAcquisitionANZ"},
    @{Title = "Payroll"; Url = "$siteUrl/Payroll"},
    # @{Title = "HR"; Url = "$siteUrl/HR"},
    @{Title = "Sales"; Url = "$siteUrl/Sales"},
    # @{Title = "Technology"; Url = "$siteUrl/Technology"},   
    @{Title = "Face 2 Face"; Url = "https://employsure.sharepoint.com/teams/Face2Face"},
    @{Title = "Client Experience"; Url = "$siteUrl/CE_AU"},
    @{Title = "Mutual"; Url = "https://employsure.sharepoint.com/teams/mutual.team"}
)

# Add the child nodes under the parent node
foreach ($childNode in $childNodes) {
    Write-Host "Adding child node: $($childNode.Title)"
    try {
        $newChildNode = Add-PnPNavigationNode -Location "TopNavigationBar" -Title $childNode.Title -Url $childNode.Url -Parent $InternalDepartmentsNode
        if ($null -eq $newChildNode) {
            Write-Host "Failed to create child node: $($childNode.Title)" -ForegroundColor Red
        } else {
            Write-Host "Successfully created child node: $($childNode.Title)" -ForegroundColor Green
        }
    } catch {
        Write-Host "Error creating child node: $($childNode.Title). Error: $_" -ForegroundColor Red
    }
}

Write-Host "Top navigation nodes added successfully."




