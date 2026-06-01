$ProfileName = "EMP-WIRE"
$NewProfile  = "Peninsula WiFi"

$Profiles = netsh wlan show profiles | Select-String "All User Profile"
$Found = $Profiles | Where-Object { $_ -match [regex]::Escape($ProfileName) }

if ($Found) {

    Write-Output "Removing Wi-Fi profile '$ProfileName'..."

    netsh wlan delete profile name="$ProfileName" | Out-Null

    Start-Sleep -Seconds 3

    Write-Output "Connecting to '$NewProfile'..."

    netsh wlan connect name="$NewProfile" | Out-Null

    Write-Output "Switched from '$ProfileName' to '$NewProfile'."

    exit 0
}
else {
    Write-Output "Wi-Fi profile '$ProfileName' not found."
    exit 0
}