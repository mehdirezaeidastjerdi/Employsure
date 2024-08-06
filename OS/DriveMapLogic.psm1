function ConnectionCheck {
    <#
        .SYNOPSIS
            This functions checks if a connection to the corporate network is available.
 
        .DESCRIPTION
 
        .PARAMETER Timeout
            Timeout value in seconds.
 
        .EXAMPLE
            ConnectonCheck
            This checks the connection every 5 seconds until the default timeout of 30 seconds is over.
 
        .EXAMPLE
            ConnectonCheck -Timeout 45
            Connection check with custom timeout.
    #>
    param(
         [Parameter()]
         [ValidateNotNullOrEmpty()]
         [int]$Timeout=30
     )
 
    $Connected = $false
    do {
        if (Resolve-DnsName $env:USERDNSDOMAIN -ErrorAction SilentlyContinue) {
            $connected=$true
            if($EnableLog)  { Write-Log -Source DriveMapping -Message "DNS Domain $($env:USERDNSDOMAIN) successfully reached." -EntryType Information }
        }
        else {
            if($EnableLog)  { Write-Log -Source DriveMapping -Message "Cannot resolve DNS Domain Name $($env:USERDNSDOMAIN). It seems there is currently no connection to that network." -EntryType Warning }
            Start-Sleep -Seconds 5
            $Timeout -= 5
            if ($Timeout -le 0){
                if($EnableLog)  { Write-Log -Source DriveMapping -Message "Timeout exceeded to resolve DNS Domain Name ($($env:USERDNSDOMAIN)). Script exited." -EntryType Error }
                exit
            }
        }
    } 
    while( -not $Connected)
}
ConnectionCheck -Timeout $Timeout

function Get-ADGroupMembership {
    <#
        .SYNOPSIS
            This functions makes a Query to fetch all groups the current user is a member of.
 
        .DESCRIPTION
 
        .EXAMPLE
            Get-ADGroupMembership
            Return Value: Array of Groups
 
        .OUTPUTS
            System.Array. Array of Group names in String format.
    #>
 
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $pc = [System.DirectoryServices.AccountManagement.PrincipalContext]::new([System.DirectoryServices.AccountManagement.ContextType]::Domain,$env:USERDNSDOMAIN)
    $up = [System.DirectoryServices.AccountManagement.AuthenticablePrincipal]::FindByIdentity($pc,$env:USERNAME)
 
    $ActiveDirectoryGroupsOfUser = @()
    foreach($group in $up.GetGroups($pc)) {
        $ActiveDirectoryGroupsOfUser += $group.SamAccountName
    }
    if($EnableLog)  { Write-Log -Source DriveMapping -Message "Group Information queried: $($ActiveDirectoryGroupsOfUser -join ", ")" -EntryType Information }
    return $ActiveDirectoryGroupsOfUser
}

function CheckDriveMapEligibility {
    <#
        .SYNOPSIS
            This functions checks if the user is allowed to map a specific drive.
 
        .DESCRIPTION
 
        .PARAMETER Drive
            Array of drive mapping information.
         
         .PARAMETER ADGroupsOfUser
            Array Groups the User is member of.
 
        .EXAMPLE
            CheckDriveMapEligibility -Drive $drive -ADGroupsOfUser $ADGroupsOfUser
             
        .OUTPUTS
            System.Array. Array of Eligibility information.
    #>
 
    param(
         [Parameter(Mandatory=$True)]
         [ValidateNotNullOrEmpty()]
         [array]$Drive,
 
         [Parameter(Mandatory=$True)]
         [ValidateNotNullOrEmpty()]
         [array]$ADGroupsOfUser
    )
 
    $allowMatch = ""
    $denyMatch = ""
    $denied = $false
    $allowed = $false
 
    foreach($deny in $Drive.DeniedGroups) {
        if($ADGroupsOfUser.contains($deny)) { 
            $denied = $true
            $denyMatch = $deny
            break
        }
    }
    if(-not $denied) {
        if(($Drive.AllowedGroups | Measure-Object).Count -eq 0) {
            $allowed = $true
        }
        else {
            foreach($allow in $Drive.AllowedGroups) {
                if($ADGroupsOfUser.contains($allow)) { 
                    $allowed = $true
                    $allowMatch = $allow
                    break
                }
            }
        }
    }
    return @{
        "denied" = $denied
        "allowed" = $allowed 
        "denyMatch" = $deny
        "allowMatch" = $allow
    }
}

function CheckForDriveExistence {
    <#
        .SYNOPSIS
            This function checks if a drive or path is already mapped differently.
 
        .DESCRIPTION
 
        .PARAMETER Drive
            Array of drive mapping information.
 
        .EXAMPLE
            CheckForDriveExistence -Drive $drive
             
        .OUTPUTS
            bool. Drive exists yes or no.
    #>
 
    param(
         [Parameter(Mandatory=$True)]
         [ValidateNotNullOrEmpty()]
         [array]$Drive
    )
 
    # Clean up conflicting mappings
     if(Get-PSDrive | Where-Object {($_.DisplayRoot -eq $Drive.UNCPath -and $_.Name -ne $Drive.DriveLetter) -or ($_.Name -eq $Drive.DriveLetter -and $_.DisplayRoot -ne $Drive.UNCPath) }) {
        #$ExitCode = (Start-Process -FilePath "net" -ArgumentList "use $($Drive.DriveLetter): /delete" -Wait -PassThru -WindowStyle Hidden).ExitCode
        #Write-Log -Source DriveMapping -Message "Removed conflicting Drive $($Drive.DriveLetter). UNC Path $($Drive.UNCPath). Exit Code: $($ExitCode)" -EntryType Warning
    }
    
    if(Get-PSDrive | Where-Object {($_.DisplayRoot -eq $Drive.UNCPath -and $_.Name -eq $Drive.DriveLetter)}) { return $true } 
    else { return $false }
}

function MapDrive {
    <#
        .SYNOPSIS
            This function maps a network drive.
  
        .DESCRIPTION
  
        .PARAMETER Drive
            Array of drive mapping information.
  
         .PARAMETER ADGroupsOfUser
            Array Groups the User is member of.
  
        .PARAMETER ReplaceMode
            Whether existing drives should be replaced (delete and newly created) or not. This Parameter is optional and false by default.
  
        .EXAMPLE
            MapDrive -Drive $Drive -ADGroupsOfUser $ADGroupsOfUser -ReplaceMode $ReplaceMode
  
    #>
  
    param(
         [Parameter(Mandatory=$True)]
         [ValidateNotNullOrEmpty()]
         [array]$Drive,
  
         [Parameter(Mandatory=$True)]
         [ValidateNotNullOrEmpty()]
         [array]$ADGroupsOfUser,
  
         [Parameter()]
         [ValidateNotNullOrEmpty()]
         [bool]$ReplaceMode=$false
    )
  
    $Eligibility = CheckDriveMapEligibility $Drive $ADGroupsOfUser
    $DriveLetterExisting = CheckForDriveExistence $Drive
  
    if(-not $Eligibility.allowed) {
        if($DriveLetterExisting) {
            $ExitCode = (Start-Process -FilePath "net" -ArgumentList "use $($Drive.DriveLetter): /delete" -Wait -PassThru -WindowStyle Hidden).ExitCode
            if($EnableLog)  { Write-Log -Source DriveMapping -Message "Drive $($Drive.DriveLetter) removed. User is not permitted to access UNC Path $($Drive.UNCPath). Exit Code: $($ExitCode)" -EntryType Warning }
        }
        if($EnableLog)  { Write-Log -Source DriveMapping -Message "User was not allowed to map Drive $($Drive.DriveLetter) on UNC Path $($Drive.UNCPath). Explicit deny: $($Eligibility.denied). Deny match: $($Eligibility.denyMatch). Allow status: $($Eligibility.allowed))" -EntryType Information }
    }
    else {
        if(($DriveLetterExisting -and ($ReplaceMode -or (Get-SmbMapping -LocalPath "$($Drive.DriveLetter):").Status -eq "Disconnected"))) {
            $ExitCode = (Start-Process -FilePath "net" -ArgumentList "use $($Drive.DriveLetter): /delete" -Wait -PassThru -WindowStyle Hidden).ExitCode
            if($ReplaceMode) {
                $ReasonString = "Script is running in Replace Mode"
            }
            else {
                $ReasonString = "Drive was disconnected"
            }
            Write-Log -Source DriveMapping -Message "Drive $($Drive.DriveLetter) removed because $($ReasonString). UNC Path: $($Drive.UNCPath). Exit Code: $($ExitCode)" -EntryType Information
            $DriveLetterExisting = $false
        }
        if(-not $DriveLetterExisting) {
            try {
                New-PSDrive -PSProvider FileSystem -Name $Drive.DriveLetter -Root $Drive.UNCPath -Persist -Scope Global -ErrorAction Stop | Out-Null
                Set-ItemProperty -Path "HKCU:\Network\$($Drive.DriveLetter)" -Name ConnectionType -Value 1 -Force -ErrorAction SilentlyContinue
                (New-Object -ComObject Shell.Application).NameSpace("$($Drive.DriveLetter):").Self.Name=$Drive.Label            
                if($EnableLog)  { Write-Log -Source DriveMapping -Message "Drive $($Drive.DriveLetter) mapped successfully on UNC Path $($Drive.UNCPath). Allow match: $($Eligibility.allowMatch)" -EntryType Information }
            }
            catch {
                if($EnableLog)  { Write-Log -Source DriveMapping -Message "Error in mapping Drive $($Drive.DriveLetter) on UNC Path $($Drive.UNCPath). Error: $($_.Exception.Message)" -EntryType Error }
  
            }
        }
        else{
            (New-Object -ComObject Shell.Application).NameSpace("$($Drive.DriveLetter):").Self.Name=$Drive.Label
            if($EnableLog)  { Write-Log -Source DriveMapping -Message "Drive $($Drive.DriveLetter) already exists. Updated." -EntryType Information }
        }
    }
  
}
