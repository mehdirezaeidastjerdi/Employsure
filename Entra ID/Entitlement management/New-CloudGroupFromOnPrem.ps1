# Install the required modules if they aren't already present
# Install-Module Microsoft.Graph.Users -Scope CurrentUser -Force
# Install-Module Microsoft.Graph.Groups -Scope CurrentUser -Force
# Install-Module Microsoft.Graph.Authentication -Scope CurrentUser -Force

# Import them explicitly
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Users
Import-Module Microsoft.Graph.Groups


# Ensure you are connected with necessary permissions (Group.ReadWrite.All is required to create groups and add members)
Connect-MgGraph -Scopes "Group.ReadWrite.All", "GroupMember.Read.All", "User.Read.All"

# Define your source on-premises group display name
$SourceGroupName = "SSO-NoMFAUsers_New_starters" # Replace with your target on-premises group name

Write-Host "Searching for on-premises group: $SourceGroupName..." -ForegroundColor Cyan

# 1. Get the source group
$sourceGroup = Get-MgGroup -Filter "displayName eq '$SourceGroupName'" -Property Id,DisplayName,Description,MailNickname

if (-not $sourceGroup) {
    Write-Error "Source group '$SourceGroupName' not found in Entra ID."
    return
}

Write-Host "Found source group ID: $($sourceGroup.Id)" -ForegroundColor Green

# 2. Define the new cloud group details
$NewCloudGroupName = "$($sourceGroup.DisplayName)_Cloud"
$NewMailNickname = "$($sourceGroup.MailNickname)_cloud" -replace '[^a-zA-Z0-9]', '' # MailNicknames must be unique and alphanumeric

# Check if the cloud group already exists to prevent duplicate creation errors
$existingCloudGroup = Get-MgGroup -Filter "displayName eq '$NewCloudGroupName'"
if ($existingCloudGroup) {
    Write-Host "Cloud group '$NewCloudGroupName' already exists. Using existing group ID: $($existingCloudGroup.Id)" -ForegroundColor Yellow
    $cloudGroup = $existingCloudGroup
} else {
    Write-Host "Creating new cloud-native group: $NewCloudGroupName..." -ForegroundColor Cyan
    
    # Create cloud-only security group
    $params = @{
        DisplayName     = $NewCloudGroupName
        MailEnabled     = $false
        MailNickname    = $NewMailNickname
        SecurityEnabled = $true
        Description     = "Cloud-native counterpart for Entitlement Management migration of $($sourceGroup.DisplayName)"
    }
    
    $cloudGroup = New-MgGroup @params
    Write-Host "Successfully created cloud group with ID: $($cloudGroup.Id)" -ForegroundColor Green
}

# 3. Get members of the source on-premises group
Write-Host "Fetching members from the source group..." -ForegroundColor Cyan
$sourceMembers = Get-MgGroupMember -GroupId $sourceGroup.Id -All

if (-not $sourceMembers) {
    Write-Host "The source group has no members to copy." -ForegroundColor Yellow
    return
}

Write-Host "Found $($sourceMembers.Count) members. Beginning migration to cloud group..." -ForegroundColor Cyan

# 4. Add members to the new cloud group
foreach ($member in $sourceMembers) {
    try {
        # Check if user/member is already in the target group to avoid duplicate errors
        $isMember = Get-MgGroupMember -GroupId $cloudGroup.Id -Filter "id eq '$($member.Id)'" -ErrorAction SilentlyContinue
        
        if (-not $isMember) {
            New-MgGroupMember -GroupId $cloudGroup.Id -DirectoryObjectId $member.Id | Out-Null
            Write-Host "Successfully added member ID: $($member.Id)" -ForegroundColor Green
        } else {
            Write-Host "Member ID: $($member.Id) is already a member of the cloud group. Skipping." -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Warning "Failed to add member ID $($member.Id): $_"
    }
}

Write-Host "`nMigration complete! You can now select '$NewCloudGroupName' inside your Entra ID Access Package." -ForegroundColor Cyan