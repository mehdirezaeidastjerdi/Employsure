# **********************************************************************************************************************
# Script: Test-AADUserInactive30Days
# Purpose: Check if a specific Microsoft Entra ID user has been inactive for 30 days using the Microsoft Graph API
# Author: Mehdi Rezaei + AI
# Last Modified: 18/09/2025
# **********************************************************************************************************************
# This PowerShell script defines a function named Test-AADUserInactive30Days which determines whether a given 
# Microsoft Entra ID user (identified by their User Principal Name) has been inactive for at least 30 days.
#
# The function:
#   - Authenticates to Microsoft Graph API using application credentials (client ID and secret)
#   - Retrieves the sign-in activity of the specified user from Microsoft Entra ID
#   - Compares the user's last sign-in date with the 30-day inactivity threshold
#
# Return values:
#   1     -> User has been inactive for 30+ days or has never signed in
#   0     -> User has been active within the last 30 days
#   $null -> User not found or an error occurred
#
# At the end of the script, the function is called with a sample user (Zang.Do@employsure.com.au),
# and the result is printed to the console with a descriptive message.
#
# This script is useful for quickly verifying the activity status of a single Microsoft Entra ID user.
# **********************************************************************************************************************

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



$result = Test-AADUserInactive30Days -UserPrincipalName "Zang.Do@employsure.com.au"
if ($result -eq 1) {
    Write-Host "User is inactive (30+ days)" -ForegroundColor red
} elseif ($result -eq 0) {
    Write-Host "User is active (within last 30 days)" -ForegroundColor Green
} else {
    Write-Host "User not found or error"
}