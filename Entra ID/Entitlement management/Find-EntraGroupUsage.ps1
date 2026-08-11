# Install modules if they are missing (skip if already installed)
# Install-Module Microsoft.Graph.Identity.SignIns -Scope CurrentUser -Force
# Install-Module Microsoft.Graph.Applications -Scope CurrentUser -Force

# Import the modules explicitly into your current session
Import-Module Microsoft.Graph.Identity.SignIns
Import-Module Microsoft.Graph.Applications
# Ensure required Microsoft Graph modules are loaded
# 1. Connect to Microsoft Graph (Requires Group.Read.All, Policy.Read.All, Application.Read.All)
Connect-MgGraph -Scopes "Group.Read.All", "Policy.Read.All", "Application.Read.All"

$GroupName = "SSO-NoMFAUsers_New_starters_Cloud" # Replace with your target group name


Write-Host "Searching for group: $GroupName..." -ForegroundColor Cyan

# 2. Find the Group Object ID
$group = Get-MgGroup -Filter "displayName eq '$GroupName'" -Property Id, DisplayName

if ($null -eq $group) {
    Write-Host "Group '$GroupName' not found in Entra ID. Please check the spelling." -ForegroundColor Red
    return
}

Write-Host "Found Group ID: $($group.Id)" -ForegroundColor Green

# 3. Check Conditional Access Policies
Write-Host "`n--- Checking Conditional Access Policies ---" -ForegroundColor Yellow
$policies = Get-MgIdentityConditionalAccessPolicy -All
$matchedPolicies = @()

foreach ($policy in $policies) {
    $includeUsers = $policy.Conditions.Users.IncludeGroups
    $excludeUsers = $policy.Conditions.Users.ExcludeGroups
    
    if ($includeUsers -contains $group.Id -or $excludeUsers -contains $group.Id) {
        $matchedPolicies += $policy.DisplayName
        Write-Host " [Match Found] Policy: $($policy.DisplayName)" -ForegroundColor Magenta
    }
}
if ($matchedPolicies.Count -eq 0) { Write-Host "No Conditional Access policies found using this group." }

# 4. Check Enterprise Applications / Service Principals (Assigned Apps)
Write-Host "`n--- Checking Enterprise Application Assignments ---" -ForegroundColor Yellow
$servicePrincipals = Get-MgServicePrincipal -All -Property Id, DisplayName
$matchedApps = @()

foreach ($sp in $servicePrincipals) {
    # Check app role assignments for this group
    $assignments = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -All
    foreach ($assignment in $assignments) {
        if ($assignment.PrincipalId -eq $group.Id) {
            $matchedApps += $sp.DisplayName
            Write-Host " [Match Found] Assigned to Enterprise App: $($sp.DisplayName)" -ForegroundColor Magenta
        }
    }
}
if ($matchedApps.Count -eq 0) { Write-Host "No Enterprise Application assignments found using this group." }

# 5. Check Nested Group Memberships (Is this group a member of other groups?)
Write-Host "`n--- Checking Parent Groups (Nested Membership) ---" -ForegroundColor Yellow
$parentGroups = Get-MgGroupTransitiveMemberOf -GroupId $group.Id -All
if ($parentGroups) {
    foreach ($parent in $parentGroups) {
        Write-Host " [Match Found] Member of Group: $($parent.AdditionalProperties.displayName)" -ForegroundColor Magenta
    }
} else {
    Write-Host "This group is not nested inside any other groups."
}

Write-Host "`nSearch complete!" -ForegroundColor Cyan