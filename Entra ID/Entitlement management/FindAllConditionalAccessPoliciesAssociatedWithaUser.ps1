# ============================================================
# Find all Conditional Access policies associated with a user
# Checks:
#   - Direct user inclusion
#   - Direct user exclusion
#   - Group inclusion
#   - Group exclusion
#   - Nested/transitive group membership
#   - "All Users" policies
# ============================================================

# Import required modules
Import-Module Microsoft.Graph.Identity.SignIns
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Groups

# Connect to Microsoft Graph
Connect-MgGraph -Scopes `
    "User.Read.All", `
    "Group.Read.All", `
    "Policy.Read.All"

# ------------------------------------------------------------
# Target user
# ------------------------------------------------------------

$UserPrincipalName = "Alexander.Odonnell@employsure.com.au"   # Change this

Write-Host "`nSearching for user: $UserPrincipalName..." -ForegroundColor Cyan

# Get user
try {
    $user = Get-MgUser -UserId $UserPrincipalName -Property Id,DisplayName,UserPrincipalName
}
catch {
    Write-Host "User '$UserPrincipalName' could not be found." -ForegroundColor Red
    return
}

Write-Host "Found User:" -ForegroundColor Green
Write-Host " Name: $($user.DisplayName)"
Write-Host " UPN : $($user.UserPrincipalName)"
Write-Host " ID  : $($user.Id)"

# ------------------------------------------------------------
# Get all groups the user belongs to
# Includes nested/transitive memberships
# ------------------------------------------------------------

Write-Host "`n--- Getting User Group Memberships ---" -ForegroundColor Yellow

$userGroups = Get-MgUserTransitiveMemberOfAsGroup `
    -UserId $user.Id `
    -All `
    -Property Id,DisplayName

$userGroupIds = @($userGroups.Id)

Write-Host "User belongs to $($userGroupIds.Count) groups (including nested groups)." -ForegroundColor Green

# Create lookup table so we can resolve Group ID -> Group Name
$groupLookup = @{}

foreach ($g in $userGroups) {
    $groupLookup[$g.Id] = $g.DisplayName
}

# ------------------------------------------------------------
# Get Conditional Access Policies
# ------------------------------------------------------------

Write-Host "`n--- Checking Conditional Access Policies ---" -ForegroundColor Yellow

$policies = Get-MgIdentityConditionalAccessPolicy -All

$results = @()

foreach ($policy in $policies) {

    $includeReasons = @()
    $excludeReasons = @()

    $userCondition = $policy.Conditions.Users

    # ========================================================
    # INCLUDE checks
    # ========================================================

    # All Users
    if ($userCondition.IncludeUsers -contains "All") {
        $includeReasons += "All Users"
    }

    # Direct user assignment
    if ($userCondition.IncludeUsers -contains $user.Id) {
        $includeReasons += "Direct User"
    }

    # Group inclusion
    foreach ($groupId in $userCondition.IncludeGroups) {

        if ($userGroupIds -contains $groupId) {

            $groupName = $groupLookup[$groupId]

            if ([string]::IsNullOrWhiteSpace($groupName)) {
                $groupName = $groupId
            }

            $includeReasons += "Group: $groupName"
        }
    }

    # ========================================================
    # EXCLUDE checks
    # ========================================================

    # Direct user exclusion
    if ($userCondition.ExcludeUsers -contains $user.Id) {
        $excludeReasons += "Direct User"
    }

    # Group exclusion
    foreach ($groupId in $userCondition.ExcludeGroups) {

        if ($userGroupIds -contains $groupId) {

            $groupName = $groupLookup[$groupId]

            if ([string]::IsNullOrWhiteSpace($groupName)) {
                $groupName = $groupId
            }

            $excludeReasons += "Group: $groupName"
        }
    }

    # ========================================================
    # Determine effective relationship
    # ========================================================

    if ($includeReasons.Count -gt 0 -or $excludeReasons.Count -gt 0) {

        if ($excludeReasons.Count -gt 0) {
            $status = "EXCLUDED"
        }
        elseif ($includeReasons.Count -gt 0) {
            $status = "INCLUDED"
        }
        else {
            $status = "Not Targeted"
        }

        $result = [PSCustomObject]@{
            PolicyName = $policy.DisplayName
            PolicyState = $policy.State
            Status = $status
            IncludedVia = ($includeReasons -join "; ")
            ExcludedVia = ($excludeReasons -join "; ")
            PolicyId = $policy.Id
        }

        $results += $result

        # Console output
        if ($status -eq "EXCLUDED") {

            Write-Host "`n[EXCLUDED] $($policy.DisplayName)" -ForegroundColor Yellow

            if ($includeReasons.Count -gt 0) {
                Write-Host "  Included via : $($includeReasons -join '; ')" -ForegroundColor Gray
            }

            Write-Host "  Excluded via : $($excludeReasons -join '; ')" -ForegroundColor Red
        }
        else {

            Write-Host "`n[INCLUDED] $($policy.DisplayName)" -ForegroundColor Green
            Write-Host "  Included via : $($includeReasons -join '; ')" -ForegroundColor Cyan
        }
    }
}

# ------------------------------------------------------------
# Final report
# ------------------------------------------------------------

Write-Host "`n======================================================" -ForegroundColor Cyan
Write-Host " Conditional Access Policy Summary" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

if ($results.Count -eq 0) {

    Write-Host "No Conditional Access policies found for this user." -ForegroundColor Yellow

}
else {

    $results |
        Sort-Object Status, PolicyName |
        Format-Table PolicyName, PolicyState, Status, IncludedVia, ExcludedVia -AutoSize
}

Write-Host "`nTotal associated policies: $($results.Count)" -ForegroundColor Cyan
Write-Host "Search complete!" -ForegroundColor Cyan