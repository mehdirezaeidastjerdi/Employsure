# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All"

# Get all users and required properties
$Users = Get-MgUser -All -Property `
    DisplayName,UserPrincipalName,Mail,JobTitle,Department,AccountEnabled

# Filter:
# - Active users
# - Department = Sales
# - Peninsula AU email address
# - Job Title contains Manager OR Director
$SalesManagersDirectors = $Users | Where-Object {
    $_.AccountEnabled -eq $true `
    -and $_.Department -eq "Sales" `
    -and $_.Mail -like "*@peninsula-au.com" `
    -and $_.JobTitle -notlike "*Business Development Manager*" `
    -and $_.JobTitle -notlike "*Account Manager*" `
    -and (
        $_.JobTitle -like "*Manager*" `
        -or $_.JobTitle -like "*Director*"
    )
    
}

# Display results
$SalesManagersDirectors |
    Select-Object DisplayName, JobTitle, Department, Mail, UserPrincipalName |
    Sort-Object JobTitle, DisplayName |
    Format-Table -AutoSize

# Export results to CSV
$SalesManagersDirectors |
    Select-Object DisplayName, JobTitle, Department, Mail, UserPrincipalName |
    Sort-Object JobTitle, DisplayName |
    Export-Csv -Path ".\Sales-Managers-Directors-Peninsula-AU.csv" -NoTypeInformation -Encoding UTF8

Write-Host "`nExport complete. Found $($SalesManagersDirectors.Count) users." -ForegroundColor Green