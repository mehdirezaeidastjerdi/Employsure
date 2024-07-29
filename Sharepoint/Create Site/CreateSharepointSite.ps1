<# 
Uninstall-Module SharePointPnPPowerShellOnline -Force –AllVersions
Uninstall-Module PnP.PowerShell -Force –AllVersions
Install-Module PnP.PowerShell -RequiredVersion 1.12.0 -Force -AllowClobber
#>
#
CLS
# Connection parameters
$TenantName = "employsure"
$AdminUserName = "mehdi.rezaei.adm@employsure.com.au"

#Set Config Parameters
$TenantUrl = "https://$($TenantName)-admin.sharepoint.com"
#$CSVPath = "C:\Data\Powershell\sites.csv"
$CSVPath = "C:\Users\Mehdi.Rezaei\OneDrive - Employsure\Usefull Scripts\Employsure\Sharepoint\sites.csv"

$AccessRequestEmail = [string]::Empty
$Template = "STS#3" # Modern Team Site
$Timezone = 76 # GMT+10 Canberra, Melbourne, Sydney
$LCID = 3081 #English - Australia | en-au  | 3081

# Connect to Tenant
Connect-PnPOnline -url $TenantUrl -Interactive

Try {
    # Get Site Collections to create from a CSV file
    $SiteCollections = Import-Csv -Path $CSVPath

    # Loop through csv and create site collections from each row
    ForEach ($Site in $SiteCollections)
    {
        # Get Parameters from CSV
        $SiteURL = "https://employsure.sharepoint.com/sites/$($Site.Url)"
        $Title = $Site.Title
        $Owner = $Site.Owner
        $Template = $Site.Template
        $TimeZone = $Site.TimeZone
        $HubSiteURL = $Site.HubSiteUrl
        $WaitTime = 60
        # Check if site exists already
        $SiteExists = Get-PnPTenantSite | Where-Object { $_.Url -eq $SiteURL }
        If ($SiteExists -eq $null)
        {
            # Create site collection
            Write-host "Creating Site Collection: $SiteURL" -f Cyan
            New-PnPTenantSite -Url $SiteURL -Title $Title -Owner $Owner -Template $Template -TimeZone $TimeZone -RemoveDeletedSite -ErrorAction Continue
            Write-host "`t Done!" -f Green

            
            # Associate the new site with a hub site
            If ($HubSiteURL -ne $null -and $HubSiteURL -ne "") {
                # Connect to the new site
                Connect-PnPOnline -Url $SiteURL -Interactive
                Write-Host "Wait for $WaitTime seconds before associating the hub site..."
                Start-Sleep $WaitTime
                Write-Host "Associating $SiteURL with hub site $HubSiteURL" -f Cyan

                Try {
                    Add-PnPHubSiteAssociation -Site $SiteURL -HubSite $HubSiteURL
                    Write-Host "`t Done!" -f Green
                }
                Catch {
                    Write-Host "`tError associating site with hub site: $($_.Exception.Message)" -f Red
                }
            }
        }
        Else
        {
            Write-host "Site $($SiteURL) exists already!" -foregroundcolor Yellow
        }
    }
}
Catch {
    Write-host -f Red "`tError:" $_.Exception.Message
}


