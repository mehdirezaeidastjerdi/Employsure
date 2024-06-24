
# Variables
$siteUrl = "https://employsure.sharepoint.com/sites/SharepointTestJembson"
# Connect to the hub site
Connect-PnPOnline -Url $siteUrl -UseWebLogin
# Variables
$navigationItems = @(
    @{Title = "Client Engagement"; Url = "/sites/ClientEngagement"},
    @{Title = "Employment Relations"; Url = "/sites/EmploymentRelations"},
    @{Title = "Events"; Url = "/sites/Events"},
    # @{Title = "Facilities"; Url = "/sites/facilities"},
    @{Title = "Finance"; Url = "/sites/Finance"},
    @{Title = "Health & Safety"; Url = "/sites/HealthSafety"},
    @{Title = "HR"; Url = "/sites/HR"},
    # @{Title = "Legal Services"; Url = "/sites/legal-services"},
    @{Title = "Legal"; Url = "/sites/LegalServices"},
    @{Title = "Management"; Url = "/sites/Management"},
    @{Title = "Sales"; Url = "/sites/Sales"},
    @{Title = "Technology"; Url = "/sites/Technology"}
)

# Function to add navigation node
function Add-NavigationNode {
    param (
        [string]$parentNodeTitle,
        [string]$nodeTitle,
        [string]$nodeUrl
    )
   
    # Get the parent node if specified
    if ($parentNodeTitle) {
        $parentNode = Get-PnPNavigationNode -Location "TopNavigationBar" | Where-Object { $_.Title -eq $parentNodeTitle }
        if ($parentNode) {
            Add-PnPNavigationNode -Title $nodeTitle -Url $nodeUrl -Location "TopNavigationBar" -Parent $parentNode.Id
        } else {
            Write-Host "Parent node '$parentNodeTitle' not found."
        }
    } else {
        Add-PnPNavigationNode -Title $nodeTitle -Url $nodeUrl -Location "TopNavigationBar"
    }
}
# Connect to the specific site
Connect-PnPOnline -Url $siteUrl 

# Remove existing navigation nodes
$existingNodes = Get-PnPNavigationNode -Location "TopNavigationBar"
foreach ($node in $existingNodes) {
    Remove-PnPNavigationNode -Identity $node.Id -Location "TopNavigationBar" -Force
}

# Add new navigation nodes
foreach ($item in $navigationItems) {
    Add-NavigationNode -parentNodeTitle $null -nodeTitle $item.Title -nodeUrl $item.Url
}

Write-Host "Navigation updated successfully for site $siteUrl."

disconnect-PnPOnline

