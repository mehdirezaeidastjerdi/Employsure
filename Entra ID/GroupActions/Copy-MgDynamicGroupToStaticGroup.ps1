Connect-MgGraph -Scopes "Group.ReadWrite.All"

# Existing dynamic group
$SourceGroupName = "Sales Department - BSCs - Active Dynamic - Peninsula ANZ"

# New static group
$NewGroupName = "Sales Department - BSCs - Active Static - Peninsula ANZ"

# Find source group
$SourceGroup = Get-MgGroup `
    -Filter "displayName eq '$SourceGroupName'" `
    -Property Id,DisplayName

if (-not $SourceGroup) {
    throw "Source group not found: $SourceGroupName"
}

# Create new static / Assigned security group
$NewGroup = New-MgGroup `
    -DisplayName $NewGroupName `
    -Description "Static copy of $SourceGroupName" `
    -MailEnabled:$false `
    -MailNickname "SalesDepartmentBSCsActiveStaticPeninsulaANZ" `
    -SecurityEnabled:$true

Write-Host "Created group: $($NewGroup.DisplayName)"
Write-Host "Group ID: $($NewGroup.Id)"

# Get all current members
$Members = Get-MgGroupMember -GroupId $SourceGroup.Id -All

Write-Host "Members found: $($Members.Count)"

# Copy members into new static group
foreach ($Member in $Members) {
    try {
        New-MgGroupMember `
            -GroupId $NewGroup.Id `
            -DirectoryObjectId $Member.Id

        Write-Host "Added: $($Member.Id)" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to add $($Member.Id): $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "Completed successfully."
Write-Host "Source: $SourceGroupName"
Write-Host "New static group: $NewGroupName"
Write-Host "Members copied: $($Members.Count)"