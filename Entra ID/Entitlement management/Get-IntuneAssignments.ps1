# param(
#     [Parameter(Mandatory=$true)]
#     [string]$GroupName
# )

$GroupName = "UEM-Win10-Autopilot-AEST-Users"

Connect-MgGraph -Scopes "Group.Read.All", "Policy.Read.All", "Application.Read.All" 
# 1. Get the Group ID
$group = Get-MgGroup -Filter "DisplayName eq '$GroupName'"
if (-not $group) {
    Write-Error "Group '$GroupName' not found in Entra ID."
    return
}
$groupId = $group.Id
Write-Host "Searching all Intune & Entra enrollment scopes for: $GroupName ($groupId)..." -ForegroundColor Cyan
$foundMatch = $false

# Helper function for standard policies
function Test-Assignments {
    param($policyName, $policies, $nameProperty)
    foreach ($policy in $policies) {
        try {
            $assignments = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/$policyName/$($policy.id)/assignments").value
            foreach ($assignment in $assignments) {
                if ($assignment.target.groupId -eq $groupId) {
                    Write-Host "[$policyName] Found in: $($policy.$nameProperty)" -ForegroundColor Yellow
                    $script:foundMatch = $true
                }
            }
        } catch { }
    }
}

# 2. Check Settings Catalog
try {
    $policies = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies").value
    Test-Assignments "configurationPolicies" $policies "name"
} catch {}

# 3. Check Compliance Policies
try {
    $policies = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceCompliancePolicies").value
    Test-Assignments "deviceCompliancePolicies" $policies "displayName"
} catch {}

# 4. Check Legacy Device Configurations
try {
    $policies = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations").value
    Test-Assignments "deviceConfigurations" $policies "displayName"
} catch {}

# 5. Check PowerShell Platform Scripts
try {
    $scripts = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts").value
    foreach ($scriptItem in $scripts) {
        $assignments = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts/$($scriptItem.id)/assignments").value
        foreach ($assignment in $assignments) {
            if ($assignment.target.groupId -eq $groupId) {
                Write-Host "[PowerShell Script] Found in Script: $($scriptItem.displayName)" -ForegroundColor Yellow
                $script:foundMatch = $true
            }
        }
    }
} catch {}

# 6. Check Entra ID Automatic Enrollment (MDM Mobility Policies)
try {
    $mdmPolicies = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/policies/mobileDeviceManagementPolicies").value
    foreach ($policy in $mdmPolicies) {
        $incGroups = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/policies/mobileDeviceManagementPolicies/$($policy.id)/includedGroups").value
        foreach ($incGroup in $incGroups) {
            if ($incGroup.id -eq $groupId) {
                Write-Host "[Automatic Enrollment] Found in MDM User Scope Policy: $($policy.displayName)" -ForegroundColor Yellow
                $script:foundMatch = $true
            }
        }
    }
} catch {}

# 7. Check Mobile Apps
try {
    $apps = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps").value
    foreach ($app in $apps) {
        $assignments = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/deviceAppManagement/mobileApps/$($app.id)/assignments").value
        foreach ($assignment in $assignments) {
            if ($assignment.target.groupId -eq $groupId) {
                Write-Host "[Mobile Apps] Found in App: $($app.displayName)" -ForegroundColor Yellow
                $script:foundMatch = $true
            }
        }
    }
} catch {}

if (-not $foundMatch) {
    Write-Host "No direct assignments found." -ForegroundColor Green
}

Write-Host "Search complete." -ForegroundColor Cyan