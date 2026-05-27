Connect-MgGraph -Scopes "User.Read.All","Group.Read.All"

$JobTitle = "Business Sales Consultant"

$users = Get-MgUser -All -Property Id,DisplayName,UserPrincipalName,JobTitle |
    Where-Object { $_.JobTitle -eq $JobTitle -and $_.Id }

Write-Host "Found $($users.Count) users"

# Store full dataset
$dataset = @()

foreach ($user in $users) {

    Write-Host "Processing $($user.DisplayName)..."

    $groups = Get-MgUserMemberOf -UserId $user.Id -All |
        Where-Object { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.group' }

    foreach ($group in $groups) {

        $dataset += [PSCustomObject]@{
            User           = $user.DisplayName
            UPN            = $user.UserPrincipalName
            GroupName      = $group.AdditionalProperties.displayName
        }
    }
}

# Show sample output
# $dataset | Select-Object -First 20 | Format-Table -AutoSize
# Total users in this role
$totalUsers = ($dataset | Select-Object User -Unique).Count

# Group analysis
$analysis = $dataset |
    Group-Object GroupName |
    ForEach-Object {

        $userCount = ($_.Group | Select-Object User -Unique).Count

        [PSCustomObject]@{
            GroupName   = $_.Name
            UserCount   = $userCount
            Percentage  = [math]::Round(($userCount / $totalUsers) * 100, 2)
        }
    }

# Sort by most common groups first
$analysis = $analysis | Sort-Object Percentage -Descending

$analysis |
    Export-Csv -Path "C:\temp\users\BusinessSalesConsultant_GroupOverlapAnalysis.csv" -NoTypeInformation -Encoding UTF8

# Show full result
$analysis | Format-Table -AutoSize
