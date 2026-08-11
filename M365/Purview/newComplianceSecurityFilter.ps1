# Uninstall the ExchangeOnlineManagement module if you have an older version installed. The latest version is required for the New-ComplianceSecurityFilter cmdlet to work. 
# Get-Module ExchangeOnlineManagement -ListAvailable | Sort-Object Version -Descending | Select-Object Name, Version, Path
# Uninstall-Module ExchangeOnlineManagement -RequiredVersion 3.5.1


# make sure the recent version is installed
Install-Module ExchangeOnlineManagement -Scope CurrentUser 

Import-Module ExchangeOnlineManagement

Connect-IPPSSession -EnableSearchOnlySession -DisableWAM
# Connect-Possession -EnableSearchOnlySession

New-ComplianceSecurityFilter `
  -FilterName "BrightHR_eDiscovery_Filter" `
  -Users "BrightHR Department - Limited access to MS Teams Only" `
  -Filters "Mailbox_MemberOfGroup -eq 'CN=Purview_Bright_BDMs20260811011753,OU=employsure.onmicrosoft.com,OU=Microsoft Exchange Hosted Organizations,DC=AUSPR01A008,DC=PROD,DC=OUTLOOK,DC=COM'" `
  -Action All `
  -Description "Restrict eDiscovery searches to BrightHR security group members"

# sanity check 
Get-ComplianceSecurityFilter -FilterName "BrightHR_eDiscovery_Filter" | Format-List *