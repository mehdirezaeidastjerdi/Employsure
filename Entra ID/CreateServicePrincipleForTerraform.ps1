
# Import the Azure Resource module
Import-Module Az.Resources

# Connect to your Azure account
Connect-AzAccount 

# Get the current Azure context (subscription and tenant information)
Get-AzContext

# List all Azure subscriptions associated with the account
Get-AzSubscription

# Create a new Azure AD Service Principal with the specified display name and role
$sp = New-AzADServicePrincipal -DisplayName "Terraform-to-Azure" -Role "Contributor"

# Output the Application ID of the Service Principal
$sp.AppId

# Output the secret text (password) of the Service Principal
$sp.PasswordCredentials.SecretText

# Get the Azure tenant information
$tenant = Get-AzTenant

# Extract the Tenant ID
$tenantId = $tenant.Id

# Output the Tenant ID
Write-Output $tenantId

# Get the Azure subscription information
$subscription = Get-AzSubscription

# Extract the Subscription ID
$subscriptionId = $subscription.Id

# Output the Subscription ID
Write-Output $subscriptionId

# Set environment variables for Terraform to use the Service Principal credentials
$env:ARM_CLIENT_ID = $sp.AppId
$env:ARM_SUBSCRIPTION_ID = $subscriptionId
$env:ARM_TENANT_ID = $tenantId
$env:ARM_CLIENT_SECRET = $sp.PasswordCredentials.SecretText

# Get and display all environment variables starting with 'ARM_'
gci env:ARM_*
