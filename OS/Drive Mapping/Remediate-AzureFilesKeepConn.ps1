# Remediate-AzureFilesKeepConn.ps1
$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
$Name    = "KeepConn"
$Desired = 65535
$Log     = "C:\ProgramData\AzureFiles\KeepConn-Remediation.log"

New-Item -Path (Split-Path $Log) -ItemType Directory -Force | Out-Null

function Log($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $Log -Value "$ts - $msg"
}

try {
    $existing = (Get-ItemProperty -Path $RegPath -Name $Name -ErrorAction SilentlyContinue).$Name

    if ($null -eq $existing) {
        Log "KeepConn not set. Creating KeepConn=$Desired"
        New-ItemProperty -Path $RegPath -Name $Name -PropertyType DWord -Value $Desired -Force | Out-Null
    }
    elseif ($existing -ne $Desired) {
        Log "KeepConn set to $existing. Updating to $Desired"
        Set-ItemProperty -Path $RegPath -Name $Name -Value $Desired -Force
    }
    else {
        Log "KeepConn already correct ($Desired). No change."
    }

    # Optional: restart Workstation service (can momentarily impact network shares)
    # Safer approach is "let it apply next reboot". If you want immediate effect, uncomment:
    # Log "Restarting Workstation service (LanmanWorkstation)..."
    # Restart-Service -Name LanmanWorkstation -Force -ErrorAction Stop
    # Log "Workstation service restarted."

    Log "Remediation completed successfully."
    exit 0
}
catch {
    Log "ERROR: $($_.Exception.Message)"
    exit 1
}
