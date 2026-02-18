# Get all FileSystem PSDrives that are network drives
$drives = net use | ForEach-Object {
    if ($_ -match '^(OK|Disconnected)\s+([A-Z]):\s+(\\\\\S+)') {
        [PSCustomObject]@{
            Letter = $matches[2]
            Path   = $matches[3]
        }
    }
} | Where-Object { $_ -ne $null }



foreach ($drive in $drives) {
    $driveLetter = $drive.Letter
    $drivePath = $drive.Path

    try {
        # Test real access
        Get-ChildItem "${driveLetter}:\\" -ErrorAction Stop | Out-Null
        Write-Output "$(Get-Date -Format u): Drive $driveLetter is accessible"
    } catch {
        Write-Warning "$(Get-Date -Format u): Drive $driveLetter is NOT accessible, running remap script"
        # Run your existing remap script
        # & "C:\ProgramData\intune-drive-mapping-generator\DriveMapping-WithAzFiles.ps1"
        & "C:\ProgramData\intune-drive-mapping-generator\DriveMapping-WithAzFiles 2.9.ps1"
    }
}