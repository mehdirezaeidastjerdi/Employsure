$Path = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
$Name = "KeepConn"
$Value = 32400

if (!(Test-Path $Path)) {
    New-Item -Path $Path -Force | Out-Null
}

New-ItemProperty `
    -Path $Path `
    -Name $Name `
    -PropertyType DWord `
    -Value $Value `
    -Force

Write-Output "Remediated: KeepConn set to $Value"