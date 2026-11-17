$ActiveAdapters = Get-NetAdapter -Physical -ErrorAction SilentlyContinue |
    Where-Object { $_.Status -eq "Up" }

$WiFiAdapters = $ActiveAdapters |
    Where-Object { $_.NdisPhysicalMedium -eq 9 }

$LanAdapters = $ActiveAdapters |
    Where-Object { $_.NdisPhysicalMedium -eq 14 }

$WiFiConnected = $null -ne $WiFiAdapters
$LanConnected  = $null -ne $LanAdapters

$User = (Get-CimInstance Win32_ComputerSystem).UserName

if ($LanConnected) {

    if ($WiFiConnected) {
        Write-Output "SAFE - LAN and Wi-Fi connected | User: $User"
    }
    else {
        Write-Output "SAFE - LAN only connected | User: $User"
    }

    exit 1
}
else {
    Write-Output "NOT SAFE - Wi-Fi only or offline | User: $User"
    exit 0
}