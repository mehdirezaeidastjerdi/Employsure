# Import the AzureAD module
Import-Module AzureAD
# Connect to Azure Entra ID (Azure AD)
Connect-AzureAD
$csvFilePath = "C:\Users\Mehdi.Rezaei\Downloads\Book1-windows10-devices.csv"
$newCsvFilePath = "C:\Users\Mehdi.Rezaei\Downloads\Book1-windows10-devices-status.csv"
# Import users from CSV file
$usersFromCsv = Import-Csv $csvFilePath
# ***********************************************************************************************
# Application credentials
$clientId = ""
$clientSecret = ""
$scope = "https://graph.microsoft.com/.default"
# Tenant information
$tenantId = "employsure.com.au"
# Microsoft Graph token request URL
$Url = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
# Add System.Web for urlencode
Add-Type -AssemblyName System.Web

# Create body for token request
$Body = @{
    client_id = $clientId
    client_secret = $clientSecret
    scope = $scope
    grant_type = 'client_credentials'
}

# Splat the parameters for Invoke-Restmethod for cleaner code
$PostSplat = @{
    ContentType = 'application/x-www-form-urlencoded'
    Method = 'POST'
    Body = $Body
    Uri = $Url
}

# Request the token
$Request = Invoke-RestMethod @PostSplat
$AccessToken = $Request.access_token

# Form request headers with the acquired $AccessToken
$headers = @{"Content-Type"="application/json";"Authorization"="Bearer $AccessToken"}

# Microsoft Graph API URL to get users list with signInActivity
$ApiUrl = "https://graph.microsoft.com/beta/users?`$select=displayName,userPrincipalName,signInActivity,userType,assignedLicenses,accountEnabled,createdDateTime"

# Array to store results
$Result = @()

# Loop through pages if next page link (odata.nextlink) is returned
While ($ApiUrl -ne $Null)
{
    # Invoke Graph API to get user data
    $Response = Invoke-RestMethod -Method GET -Uri $ApiUrl -ContentType "application/json" -Headers $headers

    if ($Response.value)
    {
        $Users = $Response.value

        # Loop through each user and gather relevant information
        ForEach ($User in $Users)
        {
            $Result += New-Object PSObject -property $([ordered]@{ 
                DisplayName = $User.displayName
                UserPrincipalName = $User.userPrincipalName
                CreatedDate = [DateTime]$User.createdDateTime
                LastSignInDateTime = if($User.signInActivity.lastSignInDateTime) { [DateTime]$User.signInActivity.lastSignInDateTime } Else {$null}
                LastNonInteractiveSignInDateTime = if($User.signInActivity.lastNonInteractiveSignInDateTime) { [DateTime]$User.signInActivity.lastNonInteractiveSignInDateTime } Else { $null }
                IsEnabled = [bool]$user.accountEnabled
                IsLicensed  = if ($User.assignedLicenses.Count -ne 0) { $true } else { $false }
                IsGuestUser  = if ($User.userType -eq 'Guest') { $true } else { $false }
            })
        }
    }
    $ApiUrl=$Response.'@odata.nextlink'
}
# ***********************************************************************************************
# Initialize an array to hold user status details
$usersStatus = @()

# Check if each user is enabled
foreach ($user in $usersFromCsv) {
    try {
            $userPrincipalName = $user.PrimaryUserUPN
            $userDetails = Get-AzureADUser -ObjectId $userPrincipalName
            
            # Find the user's LastSignInDateTime in the Result array
            $matchingResult = $Result | Where-Object { $_.UserPrincipalName -eq $userPrincipalName }
            $lastSignInDateTime = $matchingResult.LastSignInDateTime


            $usersStatus += [PSCustomObject]@{
            DeviceID = $user.DeviceID
            DeviceName = $user.DeviceName
            Compliance = $user.Compliance
            OSVersion = $user.OSVersion
            DeviceOwner = $userDetails.UserPrincipalName
            OwnerAccountEnabled = $userDetails.AccountEnabled
            OfficeLocation = $userDetails.PhysicalDeliveryOfficeName
            OwnerUserLastSignInDate = $lastSignInDateTime
        }
    } catch {
        Write-Warning "Failed to get details for user: $userPrincipalName"
        $usersStatus += [PSCustomObject]@{
            PrimaryUserUPN = $user.PrimaryUserUPN
            AccountEnabled = $null
            OfficeLocation = $null
        }
    }
}
$usersStatus | Export-Csv -Path $newCsvFilePath -NoTypeInformation