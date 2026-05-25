Install-Module Microsoft.Graph -Scope CurrentUser


Connect-MgGraph -Scopes "Group.ReadWrite.All","Device.Read.All"

# Retrieve the group information
$group = Get-MgGroup -Filter "displayName eq 'PeninsulaWifi-InclusionGroup'"
$groupId = $group.Id

# Import the list of device names
$devices = Import-Csv -Path "C:\Users\Mehdi.Rezaei\OneDrive - Employsure\Usefull Scripts\Employsure\Entra ID\GroupActions\GroupImportMembersTemplate.csv"

# Loop through each device from the CSV
foreach ($device in $devices) {

    $deviceName = $device.DeviceName

    # Get the Device Object ID
    $entraDevice = Get-MgDevice -Filter "displayName eq '$deviceName'"

    if ($entraDevice) {

        $deviceId = $entraDevice.Id

        # Add device to the group
        New-MgGroupMember -GroupId $groupId -DirectoryObjectId $deviceId

        Write-Host "Device $deviceName added to the group." -ForegroundColor Green
    }
    else {

        Write-Host "Device $deviceName not found in Entra ID." -ForegroundColor Yellow
    }
}