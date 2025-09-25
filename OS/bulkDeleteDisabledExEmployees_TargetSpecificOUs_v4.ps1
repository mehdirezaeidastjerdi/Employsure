# Start transcript
# Start-Transcript -Path C:\Scripts_Halo\DeletedUsers_v2.log -Append


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
function Get-InactiveAADUsersFromList {
    param (
        [Parameter(Mandatory = $true)]
        [array]$UsersToCheck
    )

    # Config
    $clientId = ""
    $clientSecret = ""
    $tenantId = "employsure.com.au"
    $scope = "https://graph.microsoft.com/.default"
    $DaysInactive = 30

    # --- Get Graph Token ---
    $tokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    $body = @{
        client_id     = $clientId
        client_secret = $clientSecret
        scope         = $scope
        grant_type    = 'client_credentials'
    }
    $tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method POST -ContentType 'application/x-www-form-urlencoded' -Body $body
    $accessToken = $tokenResponse.access_token

    # --- Call Graph to get all users with signInActivity ---
    $headers = @{
        "Authorization" = "Bearer $accessToken"
        "Content-Type"  = "application/json"
    }

    $apiUrl = "https://graph.microsoft.com/beta/users?`$select=userPrincipalName,signInActivity&`$top=999"
    $graphUsers = @()

    while ($apiUrl) {
        $response = Invoke-RestMethod -Method GET -Uri $apiUrl -Headers $headers
        $graphUsers += $response.value
        $apiUrl = $response.'@odata.nextLink'
    }

    # --- Build a hashtable for fast lookups ---
    $signInMap = @{}
    foreach ($gUser in $graphUsers) {
        $signInMap[$gUser.userPrincipalName.ToLower()] = $gUser.signInActivity.lastSignInDateTime
    }

    $threshold = (Get-Date).AddDays(-$DaysInactive)

    # --- Filter out active users ---
    $inactiveUsers = @()

    foreach ($user in $UsersToCheck) {
        $upnLower = $user.UserPrincipalName.ToLower()
        $lastSignIn = $signInMap[$upnLower]

        if (-not $lastSignIn) {
            # never signed in or not found in cloud — treat as inactive
            $inactiveUsers += $user
        }
        elseif ([datetime]$lastSignIn -le $threshold) {
            # inactive for 30+ days
            $inactiveUsers += $user
        }
        # else skip (active user)
    }

    return $inactiveUsers
}


# --- Step 1: Disabled Accounts in AU OU ---
$searchScope = "OU=Disabled Accounts,OU=Users,OU=Employsure,DC=employsure,DC=local"
$usersToDelete = Get-ADUser `
    -Server HSVMEMPDC5 `
    -LDAPFilter $ldalast sigsign in date for each.
    pFilter `
    -SearchBase $searchScope `
    -Properties DisplayName, EmailAddress, UserPrincipalName, Enabled, LastLogonDate, Title, Department

$inactiveUsers = Get-InactiveAADUsersFromList -UsersToCheck $usersToDelete

foreach ($user in $inactiveUsers) {
    Write-Host "User is inactive for 30+ days - this user will be deleted" -ForegroundColor Red
    Remove-ADUser -Server HSVMEMPDC5 -Identity $user.DistinguishedName -Confirm:$false -WhatIf
}


# --- Step 2: Disabled Accounts in NZ OU ---
$searchScope = "OU=Disabled NZ Users,OU=Employsure NZ,DC=employsure,DC=local"
$usersToDelete = Get-ADUser `
    -Server HSVMEMPDC5 `
    -LDAPFilter $ldapFilter `
    -SearchBase $searchScope `
    -Properties DisplayName, EmailAddress, UserPrincipalName, Enabled, LastLogonDate, Title, Department

$inactiveUsers = Get-InactiveAADUsersFromList -UsersToCheck $usersToDelete

foreach ($user in $inactiveUsers) {
    Write-Host "User is inactive for 30+ days - this user will be deleted" -ForegroundColor Red
    Remove-ADUser -Server HSVMEMPDC5 -Identity $user.DistinguishedName -Confirm:$false -WhatIf
}


# Stop-Transcript