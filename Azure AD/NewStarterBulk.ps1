<#
**********************************************************************
This script:
1. Takes input for a CSV file containing source, destination usernames, and manager.
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

# Path to the CSV file
$csvFilePath =  "C:\temp\newstarters.csv"

# Import the CSV file
$users = Import-Csv -Path $csvFilePath

# Function to process each user
function Process-User($SourceName, $DestinationUserName, $Manager) {
    
    Write-Host "Get all the groups the $SourceName is a member of"

    # Remove domain extension from the username
    $SourceNameWithoutDomain = ($SourceName -split '@')[0]

    $DestinationUserNameWithoutDomain = ($DestinationUserName -split '@')[0]

    $ManagerWithoutDomain = ($Manager -split '@')[0]

    # Get all the groups the source username is a member of
    $memberOfGroups = Get-ADUser -Identity $SourceNameWithoutDomain -Properties memberof
    # Get other properties
    $OtherProperties = Get-ADUser -Identity $SourceNameWithoutDomain -Properties Title, Company, Department, Organization, Description, Office, Fax, HomePage, HomePhone

    $memberOfGroups | Format-Table
   
    # Display a separator
    Write-Output "*****************************************************************************"
    Write-Output "User $DestinationUserName has joined the following Onprem-AD groups:"
    Write-Output "*****************************************************************************"
    # Iterate through each group
    foreach ($group in $memberOfGroups.memberof) {
        # Add the destination user to the group
        Add-ADGroupMember -Identity $group -Members $DestinationUserNameWithoutDomain
        # Display the group name
        Write-Output "Group: $group"
    }

    # Add the destination user the properties
    Set-ADUser -Identity $DestinationUserNameWithoutDomain -Title $OtherProperties.Title -Manager $ManagerWithoutDomain `
    -Company $OtherProperties.Company -Department $OtherProperties.Department -Organization $OtherProperties.Organization `
    -Description $OtherProperties.Description -Office $OtherProperties.Office -Fax $OtherProperties.Fax -HomePage $OtherProperties.HomePage -HomePhone $OtherProperties.HomePhone

    Write-Output "*****************************************************************************"
    Write-Output "User $DestinationUserName has been allocated $Manager as their manager "

    # Construct the FQDN for source and destination users
    $SourceId = (Get-AzureADUser -ObjectId $SourceName).ObjectId
    $DestinationId = (Get-AzureADUser -ObjectId $DestinationUserName).ObjectId
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
        $groupMembers = Get-AzureADGroupMember -ObjectId $usergroup.ObjectId
        if (-not ($groupMembers | Where-Object { $_.ObjectId -eq $DestinationId })) {
            Add-AzureADGroupMember -ObjectId $usergroup.ObjectId -RefObjectId $DestinationId
        }
    }

    $DistributionGroups = Get-DistributionGroup | Where-Object { (Get-DistributionGroupMember $_.Name | ForEach-Object { $_.PrimarySmtpAddress }) -contains $SourceName }

    foreach ($group in $DistributionGroups) {
        Write-Output $group.DisplayName
        Add-DistributionGroupMember -Identity $group.Name -Member $DestinationUserName
    }
}
# End of function
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
Write-Output "Connected to ExchangeOnline..."

# Iterate through each row in the CSV file and process the user
foreach ($user in $users) {
    Process-User -SourceName $user.SourceName -DestinationUserName $user.DestinationUserName -Manager $user.Manager
}

Disconnect-AzureAD
Disconnect-ExchangeOnline
