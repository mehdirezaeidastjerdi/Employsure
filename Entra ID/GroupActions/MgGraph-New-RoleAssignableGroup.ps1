# Requires Microsoft.Graph PowerShell module
# Install-Module Microsoft.Graph -Scope CurrentUser

Import-Module Microsoft.Graph

# Sign in with sufficient permissions to create role-assignable groups
Connect-MgGraph -Scopes `
    "Group.ReadWrite.All", `
    "RoleManagement.ReadWrite.Directory"

$OldGroupName = "SG-AVD-AU-FTS-Users"
$NewGroupName = "SG-AVD-AU-FTS-Admins"

# ------------------------------------------------------------
# 1. Find the existing group
# ------------------------------------------------------------

$OldGroup = Get-MgGroup `
    -Filter "displayName eq '$OldGroupName'" `
    -Property Id,DisplayName,Description,SecurityEnabled,GroupTypes

if (-not $OldGroup) {
    throw "Could not find group: $OldGroupName"
}

Write-Host "Found source group:"
Write-Host "  $($OldGroup.DisplayName)"
Write-Host "  $($OldGroup.Id)" -ForegroundColor Cyan


# ------------------------------------------------------------
# 2. Check that the new group does not already exist
# ------------------------------------------------------------

$ExistingNewGroup = Get-MgGroup `
    -Filter "displayName eq '$NewGroupName'" `
    -Property Id,DisplayName

if ($ExistingNewGroup) {
    throw "$NewGroupName already exists. No changes made."
}


# ------------------------------------------------------------
# 3. Create ROLE-ASSIGNABLE security group
# ------------------------------------------------------------

$MailNickname = "SG-AVD-AU-FTS-Admins"

$NewGroup = New-MgGroup `
    -DisplayName $NewGroupName `
    -Description "Security group for Follow-the-Sun AU support. Used for AVD access and PIM-managed Microsoft Entra Helpdesk Administrator and Authentication Administrator roles as of now." `
    -MailEnabled:$false `
    -MailNickname $MailNickname `
    -SecurityEnabled:$true `
    -IsAssignableToRole:$true

Write-Host ""
Write-Host "Created new role-assignable group:" -ForegroundColor Green
Write-Host "  $($NewGroup.DisplayName)"
Write-Host "  $($NewGroup.Id)" -ForegroundColor Cyan


# ------------------------------------------------------------
# 4. Get members of existing AVD group
# ------------------------------------------------------------

$Members = Get-MgGroupMember `
    -GroupId $OldGroup.Id `
    -All

Write-Host ""
Write-Host "Members found in source group: $($Members.Count)"


# ------------------------------------------------------------
# 5. Copy members
# ------------------------------------------------------------

foreach ($Member in $Members) {

    try {

        New-MgGroupMemberByRef `
            -GroupId $NewGroup.Id `
            -OdataId "https://graph.microsoft.com/v1.0/directoryObjects/$($Member.Id)"

        Write-Host "Added: $($Member.Id)" -ForegroundColor Green
    }
    catch {
        Write-Warning "Could not add $($Member.Id): $($_.Exception.Message)"
    }
}


# ------------------------------------------------------------
# 6. Verify resulting group
# ------------------------------------------------------------

$CreatedGroup = Get-MgGroup `
    -GroupId $NewGroup.Id `
    -Property Id,DisplayName,Description,IsAssignableToRole,SecurityEnabled

Write-Host ""
Write-Host "========== RESULT ==========" -ForegroundColor Cyan

$CreatedGroup |
    Select-Object DisplayName,
                  Id,
                  SecurityEnabled,
                  IsAssignableToRole,
                  Description |
    Format-List

$NewMembers = Get-MgGroupMember `
    -GroupId $NewGroup.Id `
    -All

Write-Host "Member count: $($NewMembers.Count)"