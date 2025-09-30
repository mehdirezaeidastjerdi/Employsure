$driveMappings = @(
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Australia L&D"; DriveLetter="F"; Label="Australia LnD"; GroupFilter="Australia L&D" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\New Zealand L&D"; DriveLetter="G"; Label="NZ L&D"; GroupFilter="New Zealand L&D" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Sales"; DriveLetter="I"; Label="Sales"; GroupFilter="SG_Sales" }
    [PSCustomObject]@{ Path="\\peninsulaanzfiles01.file.core.windows.net\it-dept"; DriveLetter="J"; Label="it-dept"; GroupFilter="SG_ITDEPT_Share" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Board"; DriveLetter="K"; Label="Board"; GroupFilter="SG_Board" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Management"; DriveLetter="L"; Label="Management"; GroupFilter="SG_Management" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\data"; DriveLetter="M"; Label="Employsure"; GroupFilter="" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\HR DATA"; DriveLetter="N"; Label="Talent"; GroupFilter="SG_HR" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Marketing Data"; DriveLetter="P"; Label="Marketing"; GroupFilter="Marketing Drive Map" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Facility Data"; DriveLetter="Q"; Label="Facilities"; GroupFilter="Facility Drive Mapping Group" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Payroll"; DriveLetter="S"; Label="Payroll"; GroupFilter="SG_Payroll" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Employsure NZ\Finance NZ"; DriveLetter="T"; Label="NZ Finance"; GroupFilter="SG_Finance_NZ_DriveMap" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Seminars"; DriveLetter="T"; Label="Seminars"; GroupFilter="SG_Seminars_DriveMap" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Employsure NZ\Recruitment NZ"; DriveLetter="S"; Label="NZ Recruitment"; GroupFilter="SG_Recruitment_NZ_DriveMap" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\ActiveDocs"; DriveLetter="U"; Label="ActiveDocs"; GroupFilter="Active Docs users" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Employsure NZ\Sales NZ"; DriveLetter="V"; Label="NZ Sales"; GroupFilter="SG_Sales_NZ_DriveMap" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Portal Sync\Awards"; DriveLetter="X"; Label="Awards - Portal"; GroupFilter="SG_Awards-Portal" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Employsure Law"; DriveLetter="X"; Label="Employsure Law"; GroupFilter="SG_EmpLaw" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Portal Sync\Common"; DriveLetter="Y"; Label="Common - Portal"; GroupFilter="SG_Common-Portal" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Employsure NZ\Service NZ"; DriveLetter="Y"; Label="NZ Service"; GroupFilter="SG_Service_NZ_DriveMap" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Consultancy"; DriveLetter="Z"; Label="Consultancy - Portal"; GroupFilter="SG_Consultancy-Portal" }
    [PSCustomObject]@{ Path="\\hsvmempdc1.employsure.local\Finance"; DriveLetter="Z"; Label="FINANCE"; GroupFilter="SG_Finance_ Drive_Map,SG_MDrive_FinanceDrive" }
)
$csvPath = "C:\temp\DriveMappingTest.csv"
# Show table in console
$driveMappings | Format-Table Path, DriveLetter, Label, GroupFilter -AutoSize
$driveMappings | Export-Csv -Path $csvPath -NoTypeInformation -Force

Write-Host "CSV exported to: $csvPath"
