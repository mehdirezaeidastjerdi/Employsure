$Username = "test.test12345@employsure.com.au"


# Disable user in on-prem active directory
$domainController = "HSVMEMPDC4"
$ou = "OU=Standard Users,OU=Users,OU=Employsure,DC=employsure,DC=local"

# Import Active Directory Module
Import-Module ActiveDirectory

# Enter a user with sufficient access to modify group membership
#$creds = Get-AutomationPSCredential -Name "OnPremActiveDirectoryAdmin"

try{
# Get the user object using UPN
$user = Get-ADUser -Filter {UserPrincipalName -eq $Username} -Properties MemberOf, SamAccountName

if ($user) {
    $samAccountName = $user.SamAccountName
    # Get all groups the user is a member of
    $groups = $user.MemberOf
    
    if ($groups.Count -gt 0) {
        foreach ($group in $groups) {
            $groupName = (Get-ADGroup -Identity $group).Name
            Write-Host "Removing $samAccountName from $groupName"
            Remove-ADGroupMember -Identity $group -Members $samAccountName -Confirm:$false
        }
        Write-Host "User $samAccountName has been removed from all groups."
    } else {
        Write-Host "User $samAccountName is not a member of any groups."
    }
} else {
    Write-Host "User $Username not found."
}
} catch {
    Write-Host "Error retrieving user $Username"
}