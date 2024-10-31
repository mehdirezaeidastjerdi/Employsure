# Install the PnP PowerShell module if not already installed
# Install-Module -Name "PnP.PowerShell" -Force -SkipPublisherCheck
$hubSitesPath = "C:\temp\HubSites.csv"
$hubSites = Import-Csv -Path $hubSitesPath

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

foreach($hubSite in $hubSites){

    $siteUrl = $hubSite.siteUrl
    # Connect-PnPOnline -Url "$siteUrl/$siteName" -Interactive
    Connect-PnPOnline -Url $siteUrl -UseWebLogin
    Write-Host "Connected and adding Navigation to $siteUrl" -f Cyan
    # Define parent nodes with their respective URLs
    $intranetNodeTitle = "Intranet"
    $intranetNodeUrl = "https://employsure.sharepoint.com"

    $InternalDepartmentsNodeTitle = "Internal Departments"
    $InternalDepartmentsNodeUrl = "#"

    $knowledgeHubTitle = "Knowledge Hub"
    $knowledgeHubUrl = "https://employsure.sharepoint.com/sites/KnowledgeHub"

    # Add the parent nodes
    $intranetNode = Add-ParentNode -parentNodeTitle $intranetNodeTitle -parentNodeUrl $intranetNodeUrl

    $InternalDepartmentsNode = Add-ParentNode -parentNodeTitle $InternalDepartmentsNodeTitle -parentNodeUrl $InternalDepartmentsNodeUrl

    $knowledgeHubNode = Add-ParentNode -parentNodeTitle $knowledgeHubTitle -parentNodeUrl $knowledgeHubUrl

    $childNodes = @(
        # @{Title = "Management"; Url = "$siteUrl/management"},
        @{Title = "Advice"; Url = "https://employsure.sharepoint.com/sites/Advice"},
        @{Title = "Clients AU"; Url = "https://employsure.sharepoint.com/sites/hs_au"},
        @{Title = "BDS"; Url = "https://employsure.sharepoint.com/sites/business_development_support"},
        @{Title = "Clients NZ"; Url = "https://employsure.sharepoint.com/sites/hs_nz"},
        @{Title = "Client Onboarding"; Url = "https://employsure.sharepoint.com/teams/ClientOnboardingANZ"},
        @{Title = "Client Experience"; Url = "https://employsure.sharepoint.com/sites/CE_AU"},
        @{Title = "CX & Retention"; Url = "https://employsure.sharepoint.com/sites/CX-Retention-Shared"},
        @{Title = "Employment Relations AU"; Url = "https://employsure.sharepoint.com/sites/ER_AU"},
        @{Title = "Employment Relations NZ"; Url = "https://employsure.sharepoint.com/sites/ER_NZ"},
        @{Title = "Face 2 Face"; Url = "https://employsure.sharepoint.com/teams/Face2Face"},
        @{Title = "Health & Safety AU"; Url = "https://employsure.sharepoint.com/sites/healthsafety_au"},
        @{Title = "Health & Safety NZ"; Url = "https://employsure.sharepoint.com/sites/healthsafety_nz"},
        @{Title = "Mutual"; Url = "https://employsure.sharepoint.com/teams/mutual.team"}
        @{Title = "Payroll"; Url = "https://employsure.sharepoint.com/sites/Payroll"},
        @{Title = "Sales"; Url = "https://employsure.sharepoint.com/sites/Sales"},
        @{Title = "Technology"; Url = "https://employsure.sharepoint.com/sites/Technology"}
        # @{Title = "Law"; Url = "https://employsure.sharepoint.com/sites/Law-au"},
        # @{Title = "Marketing and Events"; Url = "https://employsure.sharepoint.com/sites/events"},
        # @{Title = "Finance"; Url = "https://employsure.sharepoint.com/sites/Finance"},
        # @{Title = "Facilities"; Url = "https://employsure.sharepoint.com/sites/TalentAcquisitionANZ"},
       
        # @{Title = "HR"; Url = "https://employsure.sharepoint.com/sites/HR"},
       
        # @{Title = "Technology"; Url = "https://employsure.sharepoint.com/sites/Technology"},          
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
}
Write-Host "Top navigation nodes added successfully to all sites."