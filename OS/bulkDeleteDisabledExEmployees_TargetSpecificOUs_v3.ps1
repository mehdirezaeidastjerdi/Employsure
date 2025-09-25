# Start transcript
Start-Transcript -Path C:\Scripts_Halo\DeletedUsers_v2.log -Append

# Ensure the required modules are loaded
Import-Module ActiveDirectory

# Install/Import Microsoft Graph modules (if not already present)
# Install-Module Microsoft.Graph -Scope CurrentUser
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Users
#Import-Module Microsoft.Graph.AuditLogs

# Connect to Microsoft Graph with the minimum scopes needed
# You must consent to AuditLog.Read.All and User.Read.All
Connect-MgGraph -Scopes "AuditLog.Read.All","User.Read.All"

# Define your exclusion group distinguished name
$groupDN = (Get-ADGroup -Server HSVMEMPDC5 -Identity "SG_ExcludeFromDeletion").DistinguishedName

# Build the base LDAP filter
$ldapFilter = "(&" +
              "(objectCategory=person)" +
              "(objectClass=user)" +
              "(userAccountControl:1.2.840.113556.1.4.803:=2)" +
              "(!(userPrincipalName=*.local))" +
              "(!(memberOf=$groupDN))" +
              ")"

# A helper function to determine if a UPN has a stale sign-in
function Test-AADUserInactive30Days {
    param (
        [Parameter(Mandatory=$true)]
        [string]$UserPrincipalName
    )

    # Config
    $clientId = ""
    $clientSecret = ""
    $scope = "https://graph.microsoft.com/.default"
    $tenantId = "employsure.com.au"
    $DaysInactive = 30

    # Get token
    $tokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    $body = @{
        client_id     = $clientId
        client_secret = $clientSecret
        scope         = $scope
        grant_type    = 'client_credentials'
    }
    $tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method POST -ContentType 'application/x-www-form-urlencoded' -Body $body
    $accessToken = $tokenResponse.access_token

    # Prepare headers
    $headers = @{
        "Authorization" = "Bearer $accessToken"
        "Content-Type"  = "application/json"
    }

    # Graph URL to get all users with signInActivity
    $apiUrl = "https://graph.microsoft.com/beta/users?`$select=displayName,userPrincipalName,signInActivity"

    $targetUser = $null
    while ($apiUrl) {
        $response = Invoke-RestMethod -Method GET -Uri $apiUrl -Headers $headers
        foreach ($user in $response.value) {
            if ($user.userPrincipalName -eq $UserPrincipalName) {
                $targetUser = $user
                break
            }
        }
        if ($targetUser) { break }
        $apiUrl = $response.'@odata.nextlink'
    }

    if (-not $targetUser) {
        Write-Warning "User '$UserPrincipalName' not found."
        return $null
    }

    # Determine inactivity
    $lastSignIn = if ($targetUser.signInActivity.lastSignInDateTime) { [datetime]$targetUser.signInActivity.lastSignInDateTime } else { $null }

    if (-not $lastSignIn) {
        return 1 # never signed in at all
    }

    $threshold = (Get-Date).AddDays(-$DaysInactive)
    if ($lastSignIn -le $threshold) {
        return 1 # inactive for 30+ days
    } else {
        return 0 # active within last 30 days
    }
}

# --- Step 1: Disabled Accounts in AU OU ---
$searchScope = "OU=Disabled Accounts,OU=Users,OU=Employsure,DC=employsure,DC=local"
$usersToDelete = Get-ADUser `
    -Server HSVMEMPDC5 `
    -LDAPFilter $ldalast sigsign in date for each.
    pFilter `
    -SearchBase $searchScope `
    -Properties DisplayName, EmailAddress, UserPrincipalName, Enabled, LastLogonDate, Title, Department

foreach ($user in $usersToDelete) {
    $upn = $user.UserPrincipalName
    $result = Test-AADUserInactive30Days -UserPrincipalName "$upn"

    if ($result -eq 1) {
        Write-Host "User is inactive for 30+ days - this user will be deleted" -ForegroundColor red
        Write-Host "Removing on-prem AD user: $($user.SamAccountName) - $($user.DisplayName)" -ForegroundColor red
        Remove-ADUser `
            -Server HSVMEMPDC5 `
            -Identity $user.DistinguishedName `
            -Confirm:$false `
            -WhatIf
    } elseif ($result -eq 0) {
        Write-Host "User is active (within last 30 days) - skipping - this user will NOT be deleted" -ForegroundColor Green
    } else {
    Write-Host "User not found or error"
    }
}

# --- Step 2: Disabled Accounts in NZ OU ---
$searchScope = "OU=Disabled NZ Users,OU=Employsure NZ,DC=employsure,DC=local"
$usersToDelete = Get-ADUser `
    -Server HSVMEMPDC5 `
    -LDAPFilter $ldapFilter `
    -SearchBase $searchScope `
    -Properties DisplayName, EmailAddress, UserPrincipalName, Enabled, LastLogonDate, Title, Department

foreach ($user in $usersToDelete) {
    $upn = $user.UserPrincipalName
    $result = Test-AADUserInactive30Days -UserPrincipalName "$upn"

    if ($result -eq 1) {
        Write-Host "User is inactive for 30+ days - this user will be deleted" -ForegroundColor red
        Write-Host "Removing on-prem AD user: $($user.SamAccountName) - $($user.DisplayName)" -ForegroundColor red
        Remove-ADUser `
            -Server HSVMEMPDC5 `
            -Identity $user.DistinguishedName `
            -Confirm:$false `
            -WhatIf
    } elseif ($result -eq 0) {
        Write-Host "User is active (within last 30 days) - skipping - this user will NOT be deleted" -ForegroundColor Green
    } else {
    Write-Host "User not found or error"
    }
}

Stop-Transcript