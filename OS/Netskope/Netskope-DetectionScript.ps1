<#
.SYNOPSIS
  Detection script for Netskope Client.
.DESCRIPTION
  Checks if Netskope Client is installed on the device.
  Returns exit code 0 if NOT installed (compliant),
  Returns exit code 1 if installed (non-compliant, remediation required).
#>

try {
    # Check installed apps by registry (faster and more reliable than Win32_Product)
    $netskopeApps = @()

    $uninstallKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($key in $uninstallKeys) {
        $netskopeApps += Get-ChildItem $key -ErrorAction SilentlyContinue |
            ForEach-Object {
                Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -like "*Netskope*" }
            }
    }

    if ($netskopeApps) {
        Write-Output "Netskope Client detected:"
        $netskopeApps | ForEach-Object {
            Write-Output " - $($_.DisplayName) ($($_.DisplayVersion))"
        }
        #exit 1   # Non-compliant → trigger remediation
    }
    else {
        Write-Output "Netskope Client not detected."
        #exit 0   # Compliant
    }
}
catch {
    Write-Error "Error during detection: $($_.Exception.Message)"
    #exit 0   # Default to compliant to avoid accidental loops
}
