

<#
        .SYNOPSIS
            Intune Drive Mapping PowerShell Script to connect on-Premise Network Drives.
 
        .DESCRIPTION
 
        .NOTES
            Original Author: Philippe Tschumi - https://techblog.ptschumi.ch
			Modified by: Michael Rizk - Tecala Group
            Last Edit: 2020-10-03
            Version 1.0 - initial Release
			Version 1.1 - Added section to check if script already running - Michael Rizk
            Version 1.2 - Added both Z drives - Blayney Lucas - Sep 2022
            Version 1.3 - Updated the Q drive group - Blayney Lucas - Nov 2022
#>
 
 
####################################################################################################################
# CUSTOM PARAMETERS                                                                                                #
# Modify as you needed                                                                                             #
####################################################################################################################
 
 
# Enable or disable logging
$EnableLog = $true
 
# URLs to the other modules.
$LogModule = "https://employsureintune.blob.core.windows.net/intune-public/DriveMapping/WriteLog.psm1"
$DriveMapLogic = "https://employsureintune.blob.core.windows.net/intune-public/DriveMapping/DriveMapLogic.psm1"
 
# If drive should be replaced (delete and recreate) if it is existing.
$ReplaceMode = $false
 
# if not connected to domain, after which Timeout script should terminate?
$Timeout = 8
 
# Add the drives and UNC Paths here. If you don't have groups and it should map for everyone, keep the arrays empty. Deny overrules Allow.
$DriveMappings = @(
#    @{
#        "AllowedGroups" = @("GS-HumanResources")
#        "DeniedGroups" = @()
#        "DriveLetter" = "H"
#        "Label" = "Marketing"
#        "UNCPath" = "\\hsvmempdc1.employsure.local\Marketing Data"
#     },
#   @{
#        "AllowedGroups" = @("GS-Finance","GS-Executive")
#        "DeniedGroups" = @("GS-FinanceBasic")
#        "DriveLetter" = "X"
#        "Label" = "Finance"
#       "UNCPath" = "\\fileserver.domain.local\finance$"
#     }
#     @{
#        "AllowedGroups" = @()
#        "DeniedGroups" = @()
#        "DriveLetter" = "P"
#        "Label" = "$($env:USERNAME)"
#        "UNCPath" = "\\fileserver.domain.local\$($env:USERNAME)"
#     }
    @{
        "AllowedGroups" = @("Australia LnD")
        "DeniedGroups" = @()
        "DriveLetter" = "F"
        "Label" = "Australia LnD"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Australia L&D"
     }
    @{
        "AllowedGroups" = @("New Zealand LnD")
        "DeniedGroups" = @()
        "DriveLetter" = "G"
        "Label" = "NZ L&D"
        "UNCPath" = "\\hsvmempdc1.employsure.local\New Zealand L&D"
     }
    @{
        "AllowedGroups" = @("SG_Sales")
        "DeniedGroups" = @()
        "DriveLetter" = "I"
        "Label" = "Sales"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Sales"
     }
    @{
        "AllowedGroups" = @("SG_ITDEPT_Share")
        "DeniedGroups" = @()
        "DriveLetter" = "J"
        "Label" = "IT Department"
        "UNCPath" = "\\hsvmempdc1.employsure.local\IT DEPT"
     }
    @{
        "AllowedGroups" = @("SG_Board")
        "DeniedGroups" = @()
        "DriveLetter" = "K"
        "Label" = "Board"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Board"
     }
    @{
        "AllowedGroups" = @("SG_Management")
        "DeniedGroups" = @()
        "DriveLetter" = "L"
        "Label" = "Management"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Management"
     }
    @{
        "AllowedGroups" = @()
        "DeniedGroups" = @()
        "DriveLetter" = "M"
        "Label" = "Employsure"
        "UNCPath" = "\\hsvmempdc1.employsure.local\data"
     }
    @{
        "AllowedGroups" = @("SG_HR")
        "DeniedGroups" = @()
        "DriveLetter" = "N"
        "Label" = "Talent"
        "UNCPath" = "\\hsvmempdc1.employsure.local\HR DATA"
     }		 
    @{
        "AllowedGroups" = @("SG_Service")
        "DeniedGroups" = @()
        "DriveLetter" = "O"
        "Label" = "Service"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Service Data"
     }	
    @{
        "AllowedGroups" = @("Marketing Drive Map")
        "DeniedGroups" = @()
        "DriveLetter" = "P"
        "Label" = "Marketing"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Marketing Data"
     }	
#    @{
#        "AllowedGroups" = @()
#        "DeniedGroups" = @()
#        "DriveLetter" = ""
#        "Label" = ""
#        "UNCPath" = ""
#     }		 
    @{
        "AllowedGroups" = @("Facility Drive Mapping Group")
        "DeniedGroups" = @()
        "DriveLetter" = "Q"
        "Label" = "Facilities"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Facility Data"
     }	
    @{
        "AllowedGroups" = @("SG_Payroll")
        "DeniedGroups" = @("SG_Recruitment_NZ_DriveMap")
        "DriveLetter" = "S"
        "Label" = "Payroll"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Payroll"
     }
    @{
        "AllowedGroups" = @("SG_Recruitment_NZ_DriveMap")
        "DeniedGroups" = @("SG_Payroll")
        "DriveLetter" = "S"
        "Label" = "NZ Recruitment"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Employsure NZ\Recruitment NZ"
     }
    @{
        "AllowedGroups" = @("SG_Finance_NZ_DriveMap")
        "DeniedGroups" = @("SG_Seminars_DriveMap")
        "DriveLetter" = "T"
        "Label" = "NZ Finance"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Employsure NZ\Finance NZ"
     }
    @{
        "AllowedGroups" = @("SG_Seminars_DriveMap")
        "DeniedGroups" = @("SG_Finance_NZ_DriveMap")
        "DriveLetter" = "T"
        "Label" = "Seminars"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Seminars"
     }		 	 
    @{
        "AllowedGroups" = @("Active Docs users")
        "DeniedGroups" = @()
        "DriveLetter" = "U"
        "Label" = "ActiveDocs"
        "UNCPath" = "\\hsvmempdc1.employsure.local\AciveDocs"
     }	
    @{
        "AllowedGroups" = @("SG_Sales_NZ_DriveMap")
        "DeniedGroups" = @()
        "DriveLetter" = "V"
        "Label" = "NZ Sales"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Employsure NZ\Sales NZ"
     }		  
    @{
        "AllowedGroups" = @("SG_Awards-Portal")
        "DeniedGroups" = @("SG_EmpLaw")
        "DriveLetter" = "X"
        "Label" = "Awards - Portal"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Portal Sync\Awards"
     }	
    @{
        "AllowedGroups" = @("SG_EmpLaw")
        "DeniedGroups" = @("SG_Awards-Portal")
        "DriveLetter" = "X"
        "Label" = "Employsure Law"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Employsure Law"
     }	
    @{
        "AllowedGroups" = @("SG_Common-Portal")
        "DeniedGroups" = @("SG_Service_NZ_DriveMap")
        "DriveLetter" = "Y"
        "Label" = "Common - Portal"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Portal Sync\Common"
     }
    @{
        "AllowedGroups" = @("SG_Service_NZ_DriveMap")
        "DeniedGroups" = @("SG_Common-Portal")
        "DriveLetter" = "Y"
        "Label" = "NZ Service"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Employsure NZ\Service NZ"
     } 
    @{
        "AllowedGroups" = @("SG_Consultancy-Portal")
        "DeniedGroups" = @("SG_Finance_ Drive_Map","SG_MDrive_FinanceDrive")
        "DriveLetter" = "Z"
        "Label" = "Consultancy - Portal"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Consultancy"
     }
    @{
        "AllowedGroups" = @("SG_Finance_ Drive_Map","SG_MDrive_FinanceDrive")
        "DeniedGroups" = @("SG_Consultancy-Portal")
        "DriveLetter" = "Z"
        "Label" = "FINANCE"
        "UNCPath" = "\\hsvmempdc1.employsure.local\Finance"
     }

	 
)
# END OF CUSTOM SECTION #############################################################################################
 
 
if($EnableLog)  { 
    Invoke-RestMethod $LogModule | Invoke-Expression
    Write-Log -Source DriveMapping -Message "********** Drive mapping started: Time: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss") **********" -EntryType Information
}
 
Invoke-RestMethod $DriveMapLogic | Invoke-Expression
 
# Query AD Groups of User
$ADGroupsOfUser = Get-ADGroupMembership
 
foreach($Drive in $DriveMappings) {
    MapDrive -Drive $Drive -ADGroupsOfUser $ADGroupsOfUser -ReplaceMode $ReplaceMode
}
 
if($EnableLog)  { Write-Log -Source DriveMapping -Message "********** Drive mapping finished. Time: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss") **********" -EntryType Information }















