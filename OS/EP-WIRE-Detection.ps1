$ProfileName = "EMP-WIRE"

$Profiles = netsh wlan show profiles |
    Select-String "All User Profile"

$Found = $Profiles | Where-Object { $_ -match [regex]::Escape($ProfileName) }

if ($Found) {
    Write-Output "Wi-Fi profile '$ProfileName' found."
    exit 1
}
else {
    Write-Output "Wi-Fi profile '$ProfileName' not found."
    exit 0
}