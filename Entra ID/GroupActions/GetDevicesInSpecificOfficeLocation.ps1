Install-Module Microsoft.Graph -Scope CurrentUser

Connect-MgGraph -Scopes "DeviceManagementManagedDevices.Read.All","User.Read.All"

# Get all managed devices
$devices = Get-MgDeviceManagementManagedDevice -All

$result = foreach ($device in $devices) {

    # Skip devices without users
    if (-not $device.UserPrincipalName) { continue }

    try {
        $user = Get-MgUser -UserId $device.UserPrincipalName -Property OfficeLocation

        if ($user.OfficeLocation -like "*Perth*") {

            [PSCustomObject]@{
                DeviceName       = $device.DeviceName
                PrimaryUser      = $device.UserPrincipalName
                OfficeLocation   = $user.OfficeLocation
                AzureADDeviceId  = $device.AzureADDeviceId
                IntuneDeviceId   = $device.Id
                OS               = $device.OperatingSystem
                Compliance       = $device.ComplianceState
            }
        }
    }
    catch {
        Write-Host "Failed for $($device.DeviceName)"
    }
}

$result | Export-Csv "C:\temp\Perth-Devices.csv" -NoTypeInformation