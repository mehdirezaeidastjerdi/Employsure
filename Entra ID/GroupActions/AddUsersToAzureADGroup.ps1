# This script imports a list of users(userPrincipalName) from a CSV file and adds them to a specified Azure AD group.
# The CSV file should contain columns 'userPrincipalName' and 'group'.
# Ensure that the AzureAD module is installed and that you have the necessary permissions to manage group memberships.
# Import the AzureAD

Import-Module AzureAD

# Connect to Azure AD
Connect-AzureAD 

# Path to the CSV file
# the csv file must contain these columns :userPrincipalName and group
$csvPath = "C:\Users\Mehdi.Rezaei\OneDrive - Employsure\Usefull Scripts\Employsure\Entra ID\Users.csv"

# Group ID of the Azure AD group
$groupId = "83958f71-d617-4b10-87ed-b3fe80509454"

# Import CSV
$users = Import-Csv -Path $csvPath

# Iterate over each user and add them to the group
foreach ($user in $users) {
    $userPrincipalName = $user.UserPrincipalName
    try {
        # Get user object
        $azureAdUser = Get-AzureADUser -Filter "UserPrincipalName eq '$userPrincipalName'"
        if ($azureAdUser) {
            # Add user to group
            Add-AzureADGroupMember -ObjectId $groupId -RefObjectId $azureAdUser.ObjectId
            Write-Output "Successfully added $userPrincipalName to the group."
        } else {
            Write-Output "User $userPrincipalName not found."
        }
    } catch {
        Write-Output "Failed to add $userPrincipalName to the group. Error: $_"
    }
}
