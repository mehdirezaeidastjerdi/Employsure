# *****************************************************************************************
$AdminUser = Read-Host -Prompt 'Your admin Email pls'
Connect-ExchangeOnline -userprincipalname $AdminUser -ShowBanner:$false
$User = Read-Host -Prompt 'Users Email pls'
#AUCKLAND
Add-MailboxFolderPermission auk.31@employsure.co.nz:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission auk.32@employsure.co.nz:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission auk.33@employsure.co.nz:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission auk.34@employsure.co.nz:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission auk.35@employsure.co.nz:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission auk.36@employsure.co.nz:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission auk.37@employsure.co.nz:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission auk.38@employsure.co.nz:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission auk.39@employsure.co.nz:\calendar -user $User -accessright Owner
#BRISBANE
Add-MailboxFolderPermission bri1.1@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission bri1.2@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission bri1.3@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission bri1.4@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission bri1.5@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission bri1.6@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission bri1.7@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission bri1.8@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission bri1.9@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission bri1.10@employsure.com.au:\calendar -user $User -accessright Owner
#MELBOURNE
Add-MailboxFolderPermission melb5.1@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission melb5.3@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission melb5.2@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission melb5.4@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission melb5.5@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission melb5.6@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission melb5.7@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission melb5.8@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission melb5.9@employsure.com.au:\calendar -user $User -accessright Owner
#SYDNEY
Add-MailboxFolderPermission 5.1@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 5.2@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 5.3@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 5.4@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 5.5@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 5.6@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission salesacademy5.7@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 6.1@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 6.2@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 6.3@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 6.4@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 6.5@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 6.6@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 6.8@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 6.9@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 7.1@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 7.2@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 7.3@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 7.4@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 7.5@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 7.6@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission 7.7@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission SYD5.2MeetingRoom@peninsula-au.com:\calendar -user $User -accessright Owner
#PERTH
Add-MailboxFolderPermission Perth14.1@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission Perth14.2@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission Perth14.3@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission Perth14.4@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission Perth14.5@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission Perth14.6@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission Perth14.7@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission Perth14.8@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission Perth14.9@employsure.com.au:\calendar -user $User -accessright Owner
#Parking Bays
Add-MailboxFolderPermission spb.3@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission spb.2@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission spb.1@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission ppb.1@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission ppb.2@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission apb.1@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission apb.2@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission bpb.1@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission bpb.2@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission mpb.1@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission mpb.2@employsure.com.au:\calendar -user $User -accessright Owner


# Bright
Add-MailboxFolderPermission BRT12.1@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission BRT12.2@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission BRT12.3@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission BRT12.4@employsure.com.au:\calendar -user $User -accessright Ownerd
Add-MailboxFolderPermission BRT12.5@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission BRT12.6@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission BRT12.7@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission BRT12.8@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission BRT12.9@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission BRT12.10@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission BRT12.11@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission BRT12.12@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission BRT12.13@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission BRT12.14@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission BRT12.15@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission BRT12.16@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission BRT12.17@employsure.com.au:\calendar -user $User -accessright Owner


Add-MailboxFolderPermission training@employsure.com.au:\calendar -user $User -accessright Owner
Add-MailboxFolderPermission ServiceHealthCheck@employsure.com.au:\calendar -user $User -accessright Owner


