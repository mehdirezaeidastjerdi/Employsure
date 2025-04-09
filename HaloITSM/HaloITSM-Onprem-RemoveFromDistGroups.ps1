param (
    [string]$Username  # UserPrincipalName (e.g., user@domain.com)
)

# Import Active Directory Module
Import-Module ActiveDirectory

# Enter credentials for AD access if required (for automation)
# $creds = Get-Credential

# Retrieve the user object using UPN
$user = Get-ADUser -Filter {UserPrincipalName -eq $Username} -Properties MemberOf -Credential $creds

if ($user) {
    $samAccountName = $user.SamAccountName
    $groups = $user.MemberOf

    if ($groups.Count -gt 0) {
        foreach ($group in $groups) {
            $groupObj = Get-ADGroup -Identity $group -Properties GroupCategory -Credential $creds
            
            # Check if the group is a distribution group
            if ($groupObj.GroupCategory -eq "Distribution") {
                try {
                    Remove-ADGroupMember -Identity $groupObj -Members $samAccountName -Confirm:$false -Credential $creds
                    Write-Host "Removed $Username from distribution group: $($groupObj.Name)" -ForegroundColor Green
                } catch {
                    Write-Host "Failed to remove $Username from $($groupObj.Name): $_" -ForegroundColor Red
                }
            }
        }
    } else {
        Write-Host "User is not a member of any groups." -ForegroundColor Yellow
    }
} else {
    Write-Host "User not found in AD." -ForegroundColor Red
}
