# Detect-AzureFilesKeepConn.ps1
# Exit 0 = compliant, Exit 1 = non-compliant

$RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
$Name    = "KeepConn"
$Desired = 65535

try {
    $current = (Get-ItemProperty -Path $RegPath -Name $Name -ErrorAction Stop).$Name
    if ($current -eq $Desired) { exit 0 } else { exit 1 }
}
catch {
    # Value missing or can't read -> non-compliant
    exit 1
}
