<#
**********************************************************************
This script:
1. Takes input for source, destination usernames. and manager.
2. Retrieves groups the source user belongs to in Active Directory.
3. Copies properties of the source user to destination user; Adds the destination user to those groups.
4. Connects to Azure AD and adds the destination user to corresponding Azure AD groups.
5. Displays the groups the destination user has joined.
Author : Mehdi Rezaei
Last modified : 01/03/2024
***********************************************************************
#>
# Clear the screen
cls
# Get the source username and destination username and manager name
$SourceName = Read-Host "Please Enter the username of the copy user (e.g. john.smith@employsure.com.au)"
$DestinationUserName = Read-Host "Please Enter the username of the new user (e.g. john.smith@employsure.com.au)"
$Manager = Read-Host "Please enter username of their manager(e.g. john Smith)"

# Get all the groups the source username is a member of
$memberOfGroups = Get-ADUser -Identity $SourceName -Properties memberof
# Get other properties 
$OtherProperties = Get-ADUser -Identity $SourceName  -Properties Title, Company, Department, Organization, Description, Office, Fax, HomePage, HomePhone

# Display a separator
Write-Output "*****************************************************************************"
Write-Output "User $DestinationUserName has joined the following Onprem-AD groups:"
Write-Output "*****************************************************************************"
# Iterate through each group
foreach ($group in $memberOfGroups.memberof) {
    # Add the destination user to the group
    Add-ADGroupMember -Identity $group -Members $DestinationUserName
    # Display the group name
    Write-Output "Group: $group"
}

# add the destination user the properties
Set-ADUser -Identity $DestinationUserName -Title $OtherProperties.Title -Manager $Manager `
-Company $OtherProperties.Company -Department $OtherProperties.Department -Organization $OtherProperties.Organization `
-Description $OtherProperties.Description -Office $OtherProperties.Office -Fax $OtherProperties.Fax -HomePage $OtherProperties.HomePage -HomePhone $OtherProperties.HomePhone

Write-Output "*****************************************************************************"
Write-Output "User $DestinationUserName has been allocated  $Manager as their manager "

# Install Azure AD module if required
if (-not (Get-Module AzureAD -ListAvailable)){
    #Install AzureAD module
    Install-Module -Name AzureAD -Verbose -Force -AllowClobber    
}

Import-Module -Name AzureAD
Write-Output "*****************************************************************************"
Write-Output "Please Provide a priviledged user to connect to Azure AD..."
Write-Output "*****************************************************************************"
# Connect to Azure AD
Connect-AzureAD
Write-Output "Connected to Azure AD..."
# Display a separator
Write-Output "*******************************************************************************************************"
Write-Output "User $DestinationUserName has joined the following Azure-AD groups:"
# Construct the FQDN for source and destination users
$SourceId = (Get-AzureADUser -ObjectId $SourceName).ObjectId

# Get all the members of groups from the source user
$allGroups = Get-AzureADUserMembership -ObjectId $SourceId

# Filter out cloud groups (excluding dynamic groups)
$cloudGroups = $allGroups | Where-Object {
    $_.OnPremisesSecurityIdentifier -eq $null -and
    $_.DisplayName -notlike "*dynamic*"
}
# Iterate through each cloud group and add them to $DestinationUserName
foreach ($usergroup in $cloudGroups) {
    Write-Output $usergroup.DisplayName
    Add-AzureADGroupMember -ObjectId $usergroup.ObjectId -RefObjectId (Get-AzureADUser -ObjectId $DestinationUserName).ObjectId
}
Disconnect-AzureAD


# Install Exchange online module if required
if (-not (Get-Module ExchangeOnlineManagement -ListAvailable)){
    #Install ExchangeOnlineManagement module
    Install-Module -Name ExchangeOnlineManagement -Verbose -AllowClobber -Force   
}

Import-Module ExchangeOnlineManagement
Write-Output "*****************************************************************************"
Write-Output "Please Provide a priviledged user to connect to ExchangeOnline..."
Write-Output "*****************************************************************************"
Connect-ExchangeOnline
Write-Output "Connected to exchange..."

$DistributionGroups = Get-DistributionGroup | Where-Object { (Get-DistributionGroupMember $_.Name | ForEach-Object { $_.PrimarySmtpAddress }) -contains $SourceName }

foreach ($group in $DistributionGroups) {
    Write-Output $group.DisplayName
    Add-DistributionGroupMember -Identity $group.Name -Member $DestinationUserName
}
Disconnect-AzureAD
Disconnect-ExchangeOnline