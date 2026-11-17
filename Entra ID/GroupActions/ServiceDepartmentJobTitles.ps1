Connect-MgGraph -Scopes "User.Read.All"

# Define department filter
$departments = @("Service","Leadership")

# Get Service department users with Health/Safety in Job Title
$users = Get-MgUser -All -Property DisplayName,UserPrincipalName,JobTitle,Department |
    Where-Object {
    ($_.Department -eq "Service" -or $_.Department -eq "Leadership") -and
    $_.JobTitle -match '(?i)health\s*(?:&|and)\s*safety'
}

if (-not $users) {
    Write-Host "No matching users found."
    return
}

# Show unique job titles and counts
$jobTitles = $users |
    Group-Object JobTitle |
    Sort-Object Name |
    Select-Object @{Name='Count';Expression={$_.Count}}, Name

Write-Host "`n=== Health & Safety Job Titles in Service Department ==="
$jobTitles | Format-Table -AutoSize

# Export unique job titles
$jobTitles | Export-Csv `
    -Path "C:\temp\Service-HealthSafety-JobTitles.csv" `
    -NoTypeInformation

Write-Host "`nExport completed: C:\temp\Service-HealthSafety-JobTitles.csv"