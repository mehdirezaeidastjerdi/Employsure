# 1. Connect to both Microsoft Graph and Teams modules
Connect-MgGraph -Scopes "Group.ReadWrite.All"
# Connect-MicrosoftTeams

# 2. Create the Dynamic Security Group for Account Managers based on Job Title
$GroupParams = @{
    DisplayName = "Sales Department - Account Managers - Active Dynamic - Peninsula AU"
    Description = "Dynamic security group for active Account Managers in the Sales Department at Peninsula AU. Membership is automatically assigned based on user attributes."
    MailEnabled = $false
    SecurityEnabled = $true
    MailNickname = "SalesDepartmentAccountManagersPeninsula"
    GroupTypes = @("DynamicMembership")
    MembershipRule = '(user.accountEnabled -eq true) and (user.extensionAttribute14 -ne null) and (user.jobTitle -contains "Account Manager") and (user.department -eq "Sales") and (user.mail -endsWith "@peninsula-au.com")'
    MembershipRuleProcessingState = "On"
}
$NewGroup = New-MgGroup @GroupParams

# 3. Wait for the group creation to sync, then assign the Teams Policy to that Group ID
# Note: It is best practice to assign a custom Ranking number to avoid policy overlaps
# New-CsGroupPolicyAssignment -GroupId $NewGroup.Id -PolicyType "TeamsMessagingPolicy" -PolicyName "Inside Sales - BSC Policy" -Rank 1
