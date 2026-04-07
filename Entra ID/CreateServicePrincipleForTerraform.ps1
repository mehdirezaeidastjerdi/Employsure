
# Import the Azure Resource module
Import-Module Az.Resources

# Connect to your Azure account
Connect-AzAccount 

# Get the current Azure context (subscription and tenant information)
Get-AzContext

# Pick a single subscription to use
$subscriptions = Get-AzSubscription | Sort-Object Name
if (-not $subscriptions) {
  throw "No Azure subscriptions found for the signed-in account."
}

Write-Host ""
Write-Host "Available subscriptions:"
$subscriptions | Select-Object @{n="#";e={$subscriptions.IndexOf($_)}}, Name, Id, TenantId | Format-Table -AutoSize

$choice = Read-Host "Enter the subscription # to use"
if ($choice -notmatch '^\d+$' -or [int]$choice -lt 0 -or [int]$choice -ge $subscriptions.Count) {
  throw "Invalid selection: $choice"
}

$subscription = $subscriptions[[int]$choice]
$subscriptionId = $subscription.Id
Set-AzContext -SubscriptionId $subscriptionId | Out-Null

# Create a new Azure AD Service Principal with the specified display name and role
$sp = New-AzADServicePrincipal -DisplayName "Terraform-to-Azure" -Role "Contributor" -Scope "/subscriptions/$subscriptionId"

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

# Output the Subscription ID
Write-Output $subscriptionId

# Set environment variables for Terraform to use the Service Principal credentials
$env:ARM_CLIENT_ID = $sp.AppId
$env:ARM_SUBSCRIPTION_ID = $subscriptionId
$env:ARM_TENANT_ID = $tenantId
$env:ARM_CLIENT_SECRET = $sp.PasswordCredentials.SecretText

# Get and display all environment variables starting with 'ARM_'
Get-ChildItem env:ARM_*
