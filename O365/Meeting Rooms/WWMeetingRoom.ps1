Connect-ExchangeOnline

New-DistributionGroup -Name "WisdomWellbeing Meeting Rooms" -DisplayName "WisdomWellbeing Meeting Rooms" -RoomList

# just list all room lists:
Get-DistributionGroup -RecipientTypeDetails RoomList



# add a room to newly created  RoomList
# List of meeting room mailboxes
$Rooms = @(
    "WW13.1InterviewRoom@wisdomwellbeing.au",
    "WW13.2InterviewRoom@wisdomwellbeing.au",
    "WW13.3MeetingRoom@wisdomwellbeing.au",
    "WW13.4MeetingRoom@wisdomwellbeing.au",
    "WW13.5ChatRoom@wisdomwellbeing.au",
    "WW13.6ChatRoom@wisdomwellbeing.au",
    "WW13.7ChatRoom@wisdomwellbeing.au",
    "WW13.8ChatRoom@wisdomwellbeing.au",
    "WW13.9ChatRoom@wisdomwellbeing.au",
    "WW13.10ChatRoom@wisdomwellbeing.au",
    "WW13.11WellnessRoom@wisdomwellbeing.au",
    "WW13.12TrainingRoom@wisdomwellbeing.au"
)

# Add each room to the RoomList distribution group
foreach ($Room in $Rooms) {
    try {
        Add-DistributionGroupMember -Identity "WisdomWellbeing Meeting Rooms" -Member $Room -ErrorAction Stop
        Write-Output "Added $Room successfully."
    }
    catch {
        Write-Output "Failed to add $Room. Error: $($_.Exception.Message)"
    }
}


# To check if this calendar is in the room list dist group, use this cmd
Get-DistributionGroupMember -Identity "WisdomWellbeing Meeting Rooms" | Select Name, PrimarySmtpAddress


# add the room to the list of AllMeetingRooms dist group
# Add each room to the RoomList distribution group
foreach ($Room in $Rooms) {
    try {
        Add-DistributionGroupMember -Identity "AllMeetingRooms" -Member $Room -ErrorAction Stop
        Write-Output "Added $Room successfully."
    }
    catch {
        Write-Output "Failed to add $Room. Error: $($_.Exception.Message)"
    }
}


Get-DistributionGroupMember -Identity "AllMeetingRooms" | Select Name, PrimarySmtpAddress


# Update the script below and run it for users who have owner access in the rooms.

# Give Wpex users permissions to the meeting room
# Alex.Chan@employsure.com.au 
# Mae.Harrison@employsure.com.au
# Laura.Farias@employsure.com.au
# Nathan.Coakley@employsure.com.au
# Alyssa.Mayo@employsure.com.au


# List of users
$Users = @(
    "Alex.Chan@employsure.com.au",
    "Mae.Harrison@employsure.com.au",
    "Laura.Farias@employsure.com.au",
    "Nathan.Coakley@employsure.com.au",
    "Alyssa.Mayo@employsure.com.au"
)

# Loop through rooms and users
foreach ($Room in $Rooms) {
    foreach ($User in $Users) {
        $CalendarFolder = "${Room}:\Calendar"
        try {
            Add-MailboxFolderPermission -Identity $CalendarFolder -User $User -AccessRights Owner -ErrorAction Stop
            Write-Output "Success: Added Owner permission for $User on $Room calendar."
        }
        catch {
            if ($_.Exception.Message -like "*already has*" -or $_.Exception.Message -like "*exists*") {
                # If the user already has permission, update it
                Set-MailboxFolderPermission -Identity $CalendarFolder -User $User -AccessRights Owner
                Write-Output "Updated: Changed $User permission to Owner on $Room calendar."
            }
            else {
                Write-Output "Failed: Could not set permission for $User on $Room. Error: $($_.Exception.Message)"
            }
        }
    }
}
