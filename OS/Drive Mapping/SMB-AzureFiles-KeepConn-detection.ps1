$Path = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters"
$Name = "KeepConn"
$ExpectedValue = 32400

try {
    $CurrentValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop).$Name

    if ($CurrentValue -eq $ExpectedValue) {
        Write-Output "Compliant: KeepConn is set to $CurrentValue"
        exit 0
    }
    else {
        Write-Output "Non-compliant: KeepConn is $CurrentValue, expected $ExpectedValue"
        exit 1
    }
}
catch {
    Write-Output "Non-compliant: KeepConn not found"
    exit 1
}