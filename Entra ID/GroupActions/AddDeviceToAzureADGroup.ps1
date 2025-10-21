Connect-AzureAD
# Retrieve the group information
$group = Get-AzureADGroup -Filter "DisplayName eq 'TST-UninstallNetskope-DeviceGroup'"
$groupId = $group.ObjectId

# Import the list of device names
$devices = Import-Csv -Path "C:\Users\Mehdi.Rezaei\OneDrive - Employsure\Usefull Scripts\Employsure\Entra ID\GroupActions\GroupImportMembersTemplate.csv"
$devices
# Loop through each device from the CSV
foreach ($device in $devices) {
    $deviceName = $device.DeviceName

    # Get the Device Object ID
    $azureADDevice = Get-AzureADDevice -Filter "DisplayName eq '$deviceName'"

    if ($azureADDevice) {
        $deviceId = $azureADDevice.ObjectId

        # Add the device to the group
        Add-AzureADGroupMember -ObjectId $groupId -RefObjectId $deviceId
        Write-Host "Device $deviceName added to the group." -ForegroundColor Green
    } else {
        Write-Host "Device $deviceName not found in Azure AD." -ForegroundColor Yellow
    }
}
