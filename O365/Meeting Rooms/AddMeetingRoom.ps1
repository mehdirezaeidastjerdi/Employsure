Connect-ExchangeOnline

# New-DistributionGroup -Name "Sydney Meeting Rooms" -DisplayName "Bright Sydney Meeting Rooms" -RoomList

# add a room to newly created  RoomList
Add-DistributionGroupMember –Identity "Sydney Meeting Rooms" -Member "SYD5.5MeetingRoom@peninsula-au.com"

# To check if this calendar is in the room list dist group, use this cmd

Get-DistributionGroupMember -Identity "Sydney Meeting Rooms" | Select Name, PrimarySmtpAddress


# add the room to the list of AllMeetingRooms dist group

Add-DistributionGroupMember –Identity AllMeetingRooms -Member "SYD5.5MeetingRoom@peninsula-au.com"


Get-DistributionGroupMember -Identity "AllMeetingRooms" | Select Name, PrimarySmtpAddress
# Update the script below and run it for users who have owner access in the rooms.

# Give Wpex users permissions to the meeting room
# Jade.Yee@employsure.com.au
# Nathan.Coakley@employsure.com.au
# Caitlyn.Fehily@employsure.com.au

Add-MailboxFolderPermission SYD5.5MeetingRoom@peninsula-au.com:\calendar -user Jade.Yee@employsure.com.au -accessright Owner
Add-MailboxFolderPermission SYD5.5MeetingRoom@peninsula-au.com:\calendar -user Nathan.Coakley@employsure.com.au -accessright Owner
Add-MailboxFolderPermission SYD5.5MeetingRoom@peninsula-au.com:\calendar -user Caitlyn.Fehily@employsure.com.au -accessright Owner


Get-DistributionGroup | Select Name, PrimarySmtpAddress
