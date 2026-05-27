# Install-Module Microsoft.Graph -Scope CurrentUser

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All"

# Define department filter
$departmentName = "Sales"

# Get all users in Sales department
$users = Get-MgUser -All -Property DisplayName, UserPrincipalName, JobTitle, Department |
    Where-Object { $_.Department -eq $departmentName }

# Check if we got results
if (-not $users) {
    Write-Host "No users found in department: $departmentName"
    return
}

# Group users by Job Title
$grouped = $users | Group-Object -Property JobTitle

# Display results
foreach ($group in $grouped) {
    Write-Host "`n============================="
    Write-Host "Job Title: $($group.Name)"
    Write-Host "Count: $($group.Count)"
    Write-Host "============================="

    $group.Group | Select-Object DisplayName, UserPrincipalName | Format-Table -AutoSize
}

# Optional: Export to CSV
$report = $users | Select-Object DisplayName, UserPrincipalName, JobTitle, Department
$report | Export-Csv -Path "C:\temp\users\Sales-Users-By-JobTitle.csv" -NoTypeInformation

Write-Host "`nExport completed: Sales-Users-By-JobTitle.csv"