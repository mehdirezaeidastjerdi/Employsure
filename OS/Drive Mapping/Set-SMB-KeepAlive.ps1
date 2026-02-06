$Path = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"

if (!(Test-Path $Path)) {
    New-Item -Path $Path -Force | Out-Null
}

New-ItemProperty `
    -Path $Path `
    -Name "KeepConn" `
    -PropertyType DWord `
    -Value 14400 `
    -Force