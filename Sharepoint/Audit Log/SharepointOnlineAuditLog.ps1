#Read more: https://learn.microsoft.com/en-us/purview/audit-log-search-script?view=o365-worldwide
#Read more: https://learn.microsoft.com/en-us/office/office-365-management-api/office-365-management-activity-api-schema#auditlogrecordtype
# https://www.sharepointdiary.com/2019/09/sharepoint-online-search-audit-logs-in-security-compliance-center.html


# Install Exchange online module if required
if (-not (Get-Module ExchangeOnlineManagement -ListAvailable)){
    #Install ExchangeOnlineManagement module
    Install-Module -Name ExchangeOnlineManagement -Verbose -AllowClobber -Force   
}

Import-Module ExchangeOnlineManagement
Write-Output "*****************************************************************************"
Write-Output "Please Provide a priviledged user to connect to ExchangeOnline..."
Write-Output "*****************************************************************************"
Connect-ExchangeOnline
#Enable Audit Log
If( (Get-AdminAuditLogConfig).UnifiedAuditLogIngestionEnabled)
{
    Write-host "Auditing is already Enabled!" -f Yellow
}
Else
{
    #configure audit settings
    Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $True
    Write-host "Enabled the Auditing Successfully!" -f Green
}
 
#Disconnect Exchange Online
#Disconnect-ExchangeOnline
#Modify the values for the following variables to configure the audit log search.
$logFile = "c:\temp\AuditLogSearchLog.txt"
$outputFile = "c:\temp\AuditLogRecords.csv"
$outputFile2 = "c:\temp\AuditLogRecords2.csv"

$start = (Get-Date).AddDays(-20)
$end = Get-Date
#[DateTime]$start = [DateTime]::UtcNow.AddDays(-5)
#[DateTime]$end = [DateTime]::UtcNow
$record = "SharePointFileOperation" #https://learn.microsoft.com/en-us/office/office-365-management-api/office-365-management-activity-api-schema#auditlogrecordtype
$resultSize = 5000
$intervalMinutes = 60

#Start script
[DateTime]$currentStart = $start
[DateTime]$currentEnd = $end

Function Write-LogFile ([String]$Message)
{
    $final = [DateTime]::Now.ToUniversalTime().ToString("s") + ":" + $Message
    $final | Out-File $logFile -Append
}

Write-LogFile "BEGIN: Retrieving audit records between $($start) and $($end), RecordType=$record, PageSize=$resultSize."
Write-Host "Retrieving audit records for the date range between $($start) and $($end), RecordType=$record, ResultsSize=$resultSize"

$totalCount = 0
while ($true)
{
    $currentEnd = $currentStart.AddMinutes($intervalMinutes)
    if ($currentEnd -gt $end)
    {
        $currentEnd = $end
    }

if ($currentStart -eq $currentEnd)
    {
        break
    }

$sessionID = [Guid]::NewGuid().ToString() + "_" +  "ExtractLogs" + (Get-Date).ToString("yyyyMMddHHmmssfff")
    Write-LogFile "INFO: Retrieving audit records for activities performed between $($currentStart) and $($currentEnd)"
    Write-Host "Retrieving audit records for activities performed between $($currentStart) and $($currentEnd)"
    $currentCount = 0

$sw = [Diagnostics.StopWatch]::StartNew()
    do
    {
        $results = Search-UnifiedAuditLog -StartDate $currentStart -EndDate $currentEnd -RecordType $record -SessionId $sessionID -SessionCommand ReturnLargeSet -ResultSize $resultSize

if (($results | Measure-Object).Count -ne 0)
        {
            
            $results | export-csv -Path $outputFile -Append -NoTypeInformation
            $AuditLogResults2 = $results.AuditData | ConvertFrom-Json | Select CreationTime,UserId,Operation, ObjectID,SiteUrl,SourceFileName,ClientIP
            $AuditLogResults2 | export-csv -Path $outputFile2 -Append -NoTypeInformation

$currentTotal = $results[0].ResultCount
            $totalCount += $results.Count
            $currentCount += $results.Count
            Write-LogFile "INFO: Retrieved $($currentCount) audit records out of the total $($currentTotal)"

if ($currentTotal -eq $results[$results.Count - 1].ResultIndex)
            {
                $message = "INFO: Successfully retrieved $($currentTotal) audit records for the current time range. Moving on!"
                Write-LogFile $message
                Write-Host "Successfully retrieved $($currentTotal) audit records for the current time range. Moving on to the next interval." -foregroundColor Yellow
                ""
                break
            }
        }
    }
    while (($results | Measure-Object).Count -ne 0)

$currentStart = $currentEnd
}

Write-LogFile "END: Retrieving audit records between $($start) and $($end), RecordType=$record, PageSize=$resultSize, total count: $totalCount."
Write-Host "Script complete! Finished retrieving audit records for the date range between $($start) and $($end). Total count: $totalCount" -foregroundColor Green



