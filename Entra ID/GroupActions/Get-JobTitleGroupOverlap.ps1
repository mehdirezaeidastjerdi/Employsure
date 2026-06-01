Connect-MgGraph -Scopes "User.Read.All","Group.Read.All"

# $JobTitle = "Business Sales Consultant"

$JobTitle = "Business Development Manager"

# Ensure output folder exists
$OutputPath = "C:\temp\users"
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

Write-Host "Fetching users with Job Title: $JobTitle"

# Get users
$users = Get-MgUser -All -Property Id,DisplayName,UserPrincipalName,JobTitle |
    Where-Object { $_.JobTitle -eq $JobTitle -and $_.Id }

Write-Host "Found $($users.Count) users"

# Store dataset
$dataset = @()

foreach ($user in $users) {

    Write-Host "Processing $($user.DisplayName)..."

    $groups = Get-MgUserMemberOf -UserId $user.Id -All |
        Where-Object { $_.AdditionalProperties.'@odata.type' -eq '#microsoft.graph.group' }

    foreach ($group in $groups) {

        # Get full group details
        $g = Get-MgGroup -GroupId $group.Id -Property DisplayName,SecurityEnabled,MailEnabled,GroupTypes

        # Determine group type
        $groupType =
            if ($g.GroupTypes -contains "DynamicMembership" -and $g.SecurityEnabled) { "Dynamic Security Group" }
            elseif ($g.GroupTypes -contains "DynamicMembership" -and $g.MailEnabled) { "Dynamic M365 Group" }
            elseif ($g.SecurityEnabled) { "Security Group" }
            elseif ($g.MailEnabled) { "Microsoft 365 Group" }
            else { "Unknown" }

        # Add to dataset
        $dataset += [PSCustomObject]@{
            User      = $user.DisplayName
            UPN       = $user.UserPrincipalName
            GroupName = $g.DisplayName
            GroupType = $groupType
        }
    }
}

Write-Host "Building overlap analysis..."

# Total users
$totalUsers = ($dataset | Select-Object User -Unique).Count

# 🔥 Only analyze Security Groups (role-relevant)
$analysis = $dataset |
    Where-Object { $_.GroupType -eq "Security Group" } |
    Group-Object GroupName |
    ForEach-Object {

        $userCount = ($_.Group | Select-Object User -Unique).Count

        [PSCustomObject]@{
            GroupName  = $_.Name
            UserCount  = $userCount
            Percentage = [math]::Round(($userCount / $totalUsers) * 100, 2)
        }
    } |
    Sort-Object Percentage -Descending

# Export results
$dataset | Export-Csv "$OutputPath\${JobTitle}_UserGroupMatrix.csv" -NoTypeInformation -Encoding UTF8

$analysis | Export-Csv "$OutputPath\${JobTitle}_GroupOverlapAnalysis.csv" -NoTypeInformation -Encoding UTF8

Write-Host "`nDONE"
Write-Host "Raw dataset saved to: $OutputPath\${JobTitle}_UserGroupMatrix.csv"
Write-Host "Analysis saved to: $OutputPath\${JobTitle}_GroupOverlapAnalysis.csv"

# Display summary
Write-Host "`n=== TOP ROLE-CANDIDATE GROUPS ==="
$analysis | Select-Object -First 15 | Format-Table -AutoSize