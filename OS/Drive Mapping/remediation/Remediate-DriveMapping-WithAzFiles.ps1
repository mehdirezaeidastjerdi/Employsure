<#
.SYNOPSIS
  Remediation wrapper for DriveMapping-WithAzFiles (Intune)
.DESCRIPTION
  Checks if the scheduled task for Azure Files drive mapping exists.
  If missing, automatically locates and runs the main script from ProgramData.
  Logs all actions to C:\ProgramData\intune-drive-mapping-generator\Logs\DriveMappingRemediation.log
#>

$TaskName = "IntuneDriveMapping-WithAzFiles"
$DefaultFolder = "C:\ProgramData\intune-drive-mapping-generator"
$LogFolder = Join-Path $DefaultFolder "Logs"
$LogFile = Join-Path $LogFolder "DriveMappingRemediation.log"

# Ensure log directory exists
if (!(Test-Path $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
}

# Start transcript
try {
    Start-Transcript -Path $LogFile -Append -ErrorAction SilentlyContinue
} catch {
    Write-Warning "Unable to start transcript logging: $($_.Exception.Message)"
}

Write-Output "===== Remediation started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ====="

# Try to locate the main script dynamically
try {
    $MainScriptPath = Get-ChildItem -Path $DefaultFolder -Filter "DriveMapping-WithAzFiles*.ps1" -ErrorAction SilentlyContinue |
                      Sort-Object LastWriteTime -Descending |
                      Select-Object -First 1 -ExpandProperty FullName
}
catch {
    Write-Warning "Error locating script automatically: $($_.Exception.Message)"
    $MainScriptPath = $null
}

# Fallback in case dynamic search fails
if (-not $MainScriptPath) {
    $MainScriptPath = Join-Path $DefaultFolder "DriveMapping-WithAzFiles.ps1"
}

Write-Output "Using script path: $MainScriptPath"

# Check if the scheduled task exists
try {
    $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
} catch {
    $task = $null
}

if (-not $task) {
    Write-Warning "Scheduled task '$TaskName' not found. Attempting remediation..."

    if (Test-Path $MainScriptPath) {
        try {
            powershell.exe -ExecutionPolicy Bypass -File $MainScriptPath -Verbose
            Write-Output "Drive mapping setup executed successfully."
        } catch {
            Write-Error "Failed to execute main script: $($_.Exception.Message)"
        }
    } else {
        Write-Error "Main script not found at $MainScriptPath. Please verify the file exists."
    }
}
else {
    Write-Output "Scheduled task '$TaskName' already exists. No remediation required."
}

Write-Output "===== Remediation finished at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ====="

try {
    Stop-Transcript | Out-Null
} catch { }

exit 0
