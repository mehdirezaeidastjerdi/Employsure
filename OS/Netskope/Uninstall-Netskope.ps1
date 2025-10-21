<#
.SYNOPSIS
  Uninstall any installed Netskope Client using Win32_Product lookup and msiexec.
.DESCRIPTION
  Uses Get-WmiObject (Win32_Product) to find Netskope installations, uninstalls them silently
  with msiexec, logs to %PUBLIC%\nscuninstall.log, and verifies removal.
#>

# --- Config ---
$LogPath = Join-Path $env:PUBLIC "nscuninstall.log"
$ProductNameFilter = "%Netskope%"   # used in the WMI query (like '%Netskope%')
# ----------------

Write-Output "Starting Netskope uninstall routine. Log: $LogPath"

try {
    # Query Win32_Product for any product with Netskope in the name
    $query = "Select * from Win32_Product where Name like '$ProductNameFilter'"
    $installed = Get-WmiObject -Query $query -ErrorAction Stop

    if (-not $installed) {
        Write-Output "No Netskope Client instances found (Win32_Product). Nothing to do."
        exit 0
    }

    # Uninstall each found product
    foreach ($app in $installed) {
        $prodGuid = $app.IdentifyingNumber.Trim("{}")  # remove braces if present
        $display = $app.Name
        $version = $app.Version

        Write-Output "Found: $display (Version: $version) ProductCode: {$prodGuid}"
        $msiArgs = "/uninstall {$prodGuid} /qn /norestart /l*v `"$LogPath`""

        Write-Output "Executing: msiexec.exe $msiArgs"
        $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru -NoNewWindow

        if ($proc.ExitCode -ne 0) {
            Write-Warning "msiexec returned exit code $($proc.ExitCode) for product {$prodGuid}. Continuing to next (if any)."
        } else {
            Write-Output "msiexec completed successfully for product {$prodGuid}."
        }
    }

    # Verification: query Win32_Product again to ensure no Netskope remains
    Start-Sleep -Seconds 5
    $remaining = Get-WmiObject -Query $query -ErrorAction SilentlyContinue
    if ($remaining) {
        Write-Warning "Netskope Client still present after uninstall. Remaining count: $($remaining.Count)"
        foreach ($r in $remaining) {
            Write-Warning "Remaining: $($r.Name) - {$($r.IdentifyingNumber)}"
        }
        Write-Output "Check uninstall log at: $LogPath"
        exit 1   # non-zero indicates failure for Intune
    } else {
        Write-Output "Netskope Client successfully uninstalled on this machine."
        Write-Output "Uninstall log (if created): $LogPath"
        exit 0
    }
}
catch {
    Write-Error "Exception encountered: $($_.Exception.Message)"
    Write-Output "Check $LogPath for msiexec details (if any)."
    exit 1
}
