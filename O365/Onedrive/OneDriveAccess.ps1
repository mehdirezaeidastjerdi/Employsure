<#
KB0010137 KB number in SNOW
This method uses powershell
This method can be used when a user is offboarded. Because, in the method above. Giving a user access fails because the existing default user has access but can’t be found in the add users box because they don’t have a licence
Also note that SharePoint Online Powershell requires Modern authentication. If you get authorisation errors pls check you aren’t using legacy auth.
Open powershell as administrator
You’ll need to install the sharepoint module if you don’t have it 
#>

Install-Module Microsoft.Online.SharePoint.PowerShell

# Import the module

Import-module Microsoft.Online.SharePoint.PowerShell

<#Now connect to the sharepoint online service
This will pop up an authentication box outside of powershell#>

Connect-SPOService -Url https://employsure-admin.sharepoint.com/

<#You are now connected to SPO and can assign permissions
In the below script
Modify the -Site name to have the first and last name from the OneDrive of the offboarded user you want to access
Then enter the users email you want to assign access to#>
Set-SPOUser -Site "https://employsure-my.sharepoint.com/personal/blayney_lucas_employsure_com_au" -LoginName remash.palikhe@employsure.com.au -IsSiteCollectionAdmin $True
<#If everything went well you will see an output like this
You will also see the users name if the GUI
Now to remove access.
Reverse the permissions
#>
Set-SPOUser -Site "https://employsure-my.sharepoint.com/personal/blayney_lucas_employsure_com_au" -LoginName remash.palikhe@employsure.com.au -IsSiteCollectionAdmin $False