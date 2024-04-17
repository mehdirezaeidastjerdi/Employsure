# Courtesy of SeeSmitty - https://github.com/SeeSmitty/Powershell/blob/main/Add-UsersToAzureADGroup.ps1

#connect to azure ad
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Import-Module AzureAD
Import-Module AzureAD
Connect-AzureAD -AccountID "mehdi.rezaei.adm@employsure.com.au"

#import a CSv with the list of users to be added to the group
$list = Import-Csv "C:\Users\Mehdi.Rezaei\OneDrive - Employsure\Usefull Scripts\Employsure\Sharepoint\NZ List.csv"

#roll through the list to look up each user and add to the group. 
foreach ($y in $list){
    $group = $y.group
    $GroupObjectID = Get-AzureADGroup -SearchString $group | Select -Property ObjectID
    
    $y2 = Get-AzureADUser -ObjectId $y.userPrincipalName | Select -Property ObjectID
    $members = Get-AzureADGroupMember -ObjectId $GroupObjectID.ObjectID -All $true
   
    if ($y2.ObjectID -in $members.ObjectID) {
        Write-Host $y.userPrincipalName'is already in the Group' -ForegroundColor Yellow
    }else{
        Add-AzureADGroupMember -ObjectId $GroupObjectID.ObjectID -RefObjectId $y2.ObjectId -InformationAction SilentlyContinue
        Write-Host $y.userPrincipalName'has been added to the Group' -ForegroundColor Green
    }
   
}

#Disconnect Azure AD
Disconnect-AzureAD