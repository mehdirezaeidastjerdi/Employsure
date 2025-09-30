Import-Module AzureAD

# Connect to Azure AD
Connect-AzureAD

# Define the source and target groups
$sourceGroupId1 = "89c6e597-4a17-4c7b-9ee2-248e189fd407"  # Replace with your first source group ID
$targetGroupId1 = "1a8f036c-84fc-446b-823a-44fd34b5594b"  # Replace with the first target group ID


# Function to clone group members
function Clone-GroupMembers {
    param (
        [string]$sourceGroupId,
        [string]$targetGroupId
    )

    # Get members of the source group
    $members = Get-AzureADGroupMember -ObjectId $sourceGroupId -All $true

    foreach ($member in $members) {
        try {
            # Add each member to the target group
            Add-AzureADGroupMember -ObjectId $targetGroupId -RefObjectId $member.ObjectId
            Write-Output "Added $($member.UserPrincipalName) to target group."
        } catch {
            Write-Output "Failed to add $($member.UserPrincipalName): $_"
        }
    }
}

# Clone both groups
Clone-GroupMembers -sourceGroupId $sourceGroupId1 -targetGroupId $targetGroupId1

