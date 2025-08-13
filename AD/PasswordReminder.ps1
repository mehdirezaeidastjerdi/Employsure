#Created by Richard dib
<#
Microsoft Link to change the password changed 
Last Modified : 23/05/2024
Modified by: Mehdi Rezaei
#>
$smtpServer="employsure-com-au.mail.protection.outlook.com"
$expireindays = 14
$from = "Employsure Service Desk <servicedesk@employsure.com.au>"

$logging = "Enabled" # Set to Disabled to Disable Logging
$logFile = "\\hsvmempmg1\c$\Scripts\Password Rem\mylog.csv"
$testing = "disabled" # Set to Disabled to Email Users
$testRecipient = "richard.dib@employsure.com.au","servicedesk@employsure.com.au"
#
###################################################################################################################

# Check Logging Settings
if (($logging) -eq "Enabled")
{
    # Test Log File Path
    $logfilePath = (Test-Path $logFile)
    if (($logFilePath) -ne "True")
    {
        # Create CSV File and Headers
        New-Item $logfile -ItemType File

        Add-Content $logfile "Date,Name,EmailAddress,DaystoExpire,ExpiresOn,Notified"
    }
} # End Logging Check

# System Settings
$textEncoding = [System.Text.Encoding]::UTF8
$date = Get-Date -format ddMMyyyy
# End System Settings
# Get Users From AD who are Enabled, Passwords Expire and are Not Currently Expired
Import-Module ActiveDirectory
$users = get-aduser -filter * -properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress |where {$_.Enabled -eq "True"} | where { $_.PasswordNeverExpires -eq $false } | where { $_.passwordexpired -eq $false }
$DefaultmaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

# Process Each User for Password Expiry
foreach ($user in $users)
{
    $Name = $user.Name
    $emailaddress = $user.emailaddress
    $passwordSetDate = $user.PasswordLastSet
    $PasswordPol = (Get-AduserResultantPasswordPolicy $user)
    $sent = "" # Reset Sent Flag
    # Check for Fine Grained Password
    if (($PasswordPol) -ne $null)
    {
        $maxPasswordAge = ($PasswordPol).MaxPasswordAge
    }
    else
    {
        # No FGP set to Domain Default
        $maxPasswordAge = $DefaultmaxPasswordAge
    }


    $expireson = $passwordsetdate + $maxPasswordAge
    $today = (get-date)
    $daystoexpire = (New-TimeSpan -Start $today -End $Expireson).Days

    # Set Greeting based on Number of Days to Expiry.

    # Check Number of Days to Expiry
    $messageDays = $daystoexpire

    if (($messageDays) -gt "1")
    {
        $messageDays = "in " + "$daystoexpire" + " days"
    }
    else
    {
        $messageDays = "today"
    }

    # Email Subject Set Here
    $subject="$name Your password will expire $messageDays"

    $body ="<font face='arial' size='2'>
    Hi $name.
    <p>Your Password will expire $messageDays<br>
    To change your password please click the <a href='https://mysignins.microsoft.com/security-info/password/change'>Password change</a> and follow the prompts to update your password. Please note you may need to sign in with your existing password to access the link. If you do not remember your existing password you can do a <a href='https://passwordreset.microsoftonline.com/'>Self Service Password Reset</a> (Field staff and other pre-registered users only).

    <br><br>
    <b>Special notes while working from home</b>

    <br><br>
    <u>Staff who DO NOT use the GlobalProtect VPN:</u> The password for your PC will remain unchanged. Please continue to use your old password to get into your PC, and the new password thereafter. The new password will synchronise onto your PC when you return to the Employsure office.

    <br><br>
    <u>Staff who DO use the GlobalProtect VPN:</u> Your new password will also update on your PC, but sometimes this is not immediate. If your new password does not work for the initial login to your computer, try your old password. Eventually the computer password will also match your new password if you are connected to the VPN.

    <br><br>
    Please note in 11 days you will not be able to log into your account or read emails. 
    If you requre any assistance the most efficient way to contact the Technology Service Desk is by raising a support ticket within the <a href='https://employsureprod.service-now.com/sp'>Technology Portal</a>.
    If you cannot access the portal or your issue is critical, please call the team on +61 2 9199 8444


    <br>
    <p><br> Kind Regards
    </P></font>"

   
    # If Testing Is Enabled - Email Administrator
    if (($testing) -eq "Enabled")
    {
        $emailaddress = $testRecipient
    } # End Testing

    # If a user has no email address listed
    if (($emailaddress) -eq $null)
    {
        $emailaddress = $testRecipient
    }# End No Valid Email

    # Send Email Message
    if (($daystoexpire -ge "0") -and ($daystoexpire -lt $expireindays))
    {
        $sent = "Yes"
        # If Logging is Enabled Log Details
        if (($logging) -eq "Enabled")
        {
            Add-Content $logfile "$date,$Name,$emailaddress,$daystoExpire,$expireson,$sent"
        }
        # Send Email Message
		Send-Mailmessage -smtpServer $smtpServer -from $from -to $emailaddress -subject $subject -body $body -bodyasHTML -priority High -Encoding $textEncoding

    } # End Send Message
    else # Log Non Expiring Password
    {
        $sent = "No"
        # If Logging is Enabled Log Details
        if (($logging) -eq "Enabled")
        {
            Add-Content $logfile "$date,$Name,$emailaddress,$daystoExpire,$expireson,$sent"
        }
    }

} # get-mailbox
