<#
.SYNOPSIS
  Detection script for DriveMapping-WithAzFiles (Intune)
.DESCRIPTION
  Checks if the scheduled task exists and logs the result.
#>

$TaskName = "IntuneDriveMapping-WithAzFiles"
$DefaultFolder = "C:\ProgramData\intune-drive-mapping-generator"
$LogFolder = Join-Path $DefaultFolder "Logs"
$LogFile = Join-Path $LogFolder "DriveMappingRemediation.log"

# Ensure log directory exists
if (!(Test-Path $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
}

# Start logging
try {
    Start-Transcript -Path $LogFile -Append -ErrorAction SilentlyContinue
} catch {
    Write-Warning "Unable to start transcript: $($_.Exception.Message)"
}

Write-Output "===== Detection started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ====="

try {
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Write-Output "Scheduled task '$TaskName' exists."
        Write-Output "===== Detection finished (Healthy) ====="
        Stop-Transcript | Out-Null
        exit 0
    } else {
        Write-Warning "Scheduled task '$TaskName' missing."
        Write-Output "===== Detection finished (Remediation required) ====="
        Stop-Transcript | Out-Null
        exit 1
    }
}
catch {
    Write-Error "Error checking scheduled task: $($_.Exception.Message)"
    Stop-Transcript | Out-Null
    exit 1
}
