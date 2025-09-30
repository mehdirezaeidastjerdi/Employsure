<#
Give cloud shared mailbox a signature
KB0010183  in Snow-  Latest Version
---------------------------------------------------------------------------------------------
Occasionally a request will come in for a shared mailbox to have a signature. By default, they don't.

This is possible, but a little bit harder for cloud-only shared mailboxes.

The easiest way to do this is to use an existing exclaimer signature and modify the user properties to get the result you want.

You could create a new signature, but we won't go over that method here. Read more in KB article (https://employsureprod.service-now.com/now/nav/ui/classic/params/target/kb_view.do%3Fsys_kb_id%3Dc7967ee297dcb910ca1cff46f053af4e)
-------------------------------------------------------------------------------------------------
Editing Extension attributes for Azure AD only users
KB0010182
Extension attributes are used in employsure to populate certain fields and assign functions based on those fields.

If you have a cloud only user, for a shared mailbox for example. You may need to edit these attributes to add data in for a signature, as an example

To do this, you need to use PowerShell.
#>

# Connect to Azure AD
# Install-Module AzureAD
Import-Module AzureAD

Connect-AzureAD
# Check the extension attributes already there.

Get-AzureADUser -ObjectId experience1408@employsure.com.au | Select -ExpandProperty ExtensionProperty
# Now edit the property you want to modify.

Set-AzureADUserExtension -ObjectId experience1408@employsure.com.au -ExtensionName extension_dddbbf80d6fa40d29308f21c6e051156_wWWHomePage -ExtensionValue "www.brighthr.com.au"

<#Any of the attributes can be modified. You just need to modify the above command for the extension.

To view all the extensions, just check an existing user.
#>