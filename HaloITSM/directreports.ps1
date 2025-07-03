param (
    [string]$Username
)

# Connect to Microsoft Graph using Managed Identity or Automation Account credentials
try {
    Connect-MgGraph -Identity -ErrorAction Stop
    Write-Output "Success - Connected to Microsoft Graph."
} catch {
    Write-Error "Failed to connect to Microsoft Graph: $_"
    exit 1
}

# Validate input
if (-not $Username) {
    Write-Error "Username is required. Please provide a valid UPN (e.g., user@domain.com)."
    exit 1
}

# Try to get direct reports
try {
    $directReports = Get-MgUserDirectReport -UserId $Username -ErrorAction Stop
} catch {
    Write-Error "Failed to retrieve direct reports for $Username $_"
    exit 1
}

# Check if the user has direct reports
if ($null -ne $directReports -and $directReports.Count -gt 0) {
    Write-Host ""
    Write-Host "$Username is a manager. They have $($directReports.Count) direct report(s):"
    Write-Host ""

    foreach ($report in $directReports) {
        try {
            $userDetails = Get-MgUser -UserId $report.Id -ErrorAction Stop
            Write-Host "- $($userDetails.DisplayName) <$($userDetails.UserPrincipalName)>"
        } catch {
            Write-Warning "Failed to get details for report ID $($report.Id): $_"
        }
    }
} else {
    Write-Host "$Username is NOT a manager. No direct reports found."
}
