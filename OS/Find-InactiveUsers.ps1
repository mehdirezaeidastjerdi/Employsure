# **********************************************************************************************************************
# Script: Find-InactiveUsers.ps1
# Purpose: Find inactive Azure AD users using Microsoft Graph API and generate a report
# Author: Mehdi Rezaei
# Last Modified: 01/12/2023
# **********************************************************************************************************************
# This PowerShell script utilizes the Microsoft Graph API to identify inactive Azure AD users within a specified time frame. 
# The script prompts for the Azure AD tenant name and the desired duration of user inactivity. It then retrieves user data, 
# including display name, user principal name, creation date, and sign-in activity, using the Graph API.
# The script filters out users who have not signed in during the specified inactive period or have never signed in. 
# The results are stored in a CSV file named "LastLoginDateReport.CSV" at the specified file path. 
# Additionally, the script sends an email with the CSV report attached to a specified recipient using SMTP.
# **********************************************************************************************************************
# Application credentials
$clientId = ""
$clientSecret = ""
$scope = "https://graph.microsoft.com/.default"

# Tenant information
$tenantId = "employsure.com.au"
$DaysInactive = 30

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

# Filter users based on last sign-in date and export the report to CSV
$dateTime = (Get-Date).Adddays(-($DaysInactive))
$Result | Where-Object { $_.LastSignInDateTime -eq $Null -OR $_.LastSignInDateTime -le $dateTime } |  Export-CSV "C:\Temp\LastLoginDateReport.CSV" -NoTypeInformation -Encoding UTF8
Write-Host 'The report stored in C:\Temp\LastLoginDateReport.CSV file.'

# Configuring SMTP server to send the CSV file to the specified email
$smtpServer = "employsure-com-au.mail.protection.outlook.com"
$senderEmail = "servicedesk@employsure.com.au"
$receiverEmail = "itoperations@employsure.onmicrosoft.com"  # Replace with the actual recipient email address
$csvFilePath = "C:\Temp\LastLoginDateReport.CSV"  # Replace with the actual file path

# Create email message
$emailParams = @{
    From       = $senderEmail
    To         = $receiverEmail
    Subject    = "Last Login Date Report"
    Body       = "The report is attached."
    SmtpServer = $smtpServer
    Attachments = $csvFilePath
}

# Send the email
Send-MailMessage @emailParams
Write-Host "Email sent successfully!"