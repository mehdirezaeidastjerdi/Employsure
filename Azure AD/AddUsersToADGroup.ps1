# Import the AzureAD.Standard.Preview module
Import-Module AzureAD

# Connect to Azure AD
Connect-AzureAD 

# Path to the CSV file
# the csv file must contain these columns :userPrincipalName and group
$csvPath = "C:\Users\Mehdi.Rezaei\OneDrive - Employsure\Usefull Scripts\Employsure\Azure AD\Users.csv"

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
