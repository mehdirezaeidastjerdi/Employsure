# Connect-MgGraph -Scopes "Group.ReadWrite.All"


# $GroupParams = @{
#     DisplayName = "H&S Forms - Respondents - Dynamic - Peninsula ANZ"
#     Description = "Dynamic Microsoft 365 group for Health & Safety staff who can respond to Health & Safety forms."
#     MailEnabled = $true
#     SecurityEnabled = $true
#     MailNickname = "HSFormsRespondentsPeninsulaANZ"
#     GroupTypes = @("Unified","DynamicMembership")
#     MembershipRule = '(user.accountEnabled -eq true) and (user.extensionAttribute14 -ne null) and ((user.department -eq "Service") or (user.department -eq "Leadership")) and ((user.mail -endsWith "@peninsula-au.com") or (user.mail -endsWith "@peninsula-nz.com")) and ((user.jobTitle -eq "Associate Director – Health & Safety") or (user.jobTitle -eq "Head of Health & Safety Consultancy") or (user.jobTitle -eq "Senior Regional Health and Safety Consultancy Manager") or (user.jobTitle -eq "Regional Health and Safety Consultancy Manager") or (user.jobTitle -eq "Lead Health and Safety Consultant") or (user.jobTitle -eq "Health & Safety Specialist Consultant") or (user.jobTitle -eq "Health and Safety Consultant") or (user.jobTitle -eq "Specialist Health & Safety Consultant") or (user.jobTitle -eq "Specialist Health and Safety Consultant") or (user.jobTitle -eq "Health and Safety Specialist Consultant"))'
#     MembershipRuleProcessingState = "On"
# }

# New-MgGroup @GroupParams


# $GroupParams = @{
#     DisplayName = "H&S Forms - Editors - Dynamic - Peninsula ANZ"
#     Description = "Dynamic Microsoft 365 group for Health & Safety Regional Managers who can edit and manage Health & Safety forms."
#     MailEnabled = $true
#     SecurityEnabled = $true
#     MailNickname = "HSFormsEditorsPeninsulaANZ"
#     GroupTypes = @("Unified","DynamicMembership")
#     MembershipRule = '(user.accountEnabled -eq true) and (user.extensionAttribute14 -ne null) and ((user.department -eq "Service") or (user.department -eq "Leadership")) and ((user.mail -endsWith "@peninsula-au.com") or (user.mail -endsWith "@peninsula-nz.com")) and ((user.jobTitle -eq "Senior Regional Health and Safety Consultancy Manager") or (user.jobTitle -eq "Regional Health and Safety Consultancy Manager"))'
#     MembershipRuleProcessingState = "On"
# }



# New-MgGroup @GroupParams

Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Groups


Connect-MgGraph -Scopes "Group.ReadWrite.All"

$GroupParams = @{
    DisplayName = "Service Department - Active Dynamic - Advisers"

    Description = "Dynamic Microsoft 365 group for active Employment Relations advisers and related consultancy roles within the Service department across Peninsula Australia and New Zealand."

    MailEnabled = $true
    SecurityEnabled = $true
    MailNickname = "ServiceActiveDynamicAdvisers"
    GroupTypes = @("Unified","DynamicMembership")

    MembershipRule = '(user.accountEnabled -eq true) and (user.extensionAttribute14 -ne null) and (user.department -eq "Service") and ((user.mail -endsWith "@peninsula-au.com") or (user.mail -endsWith "@peninsula-nz.com")) and ((user.jobTitle -eq "Employment Relations Adviser") or (user.jobTitle -eq "Employment Relations Coordinator") or (user.jobTitle -eq "Employment Relations Specialist") or (user.jobTitle -eq "Employment Relations Adviser - Priority") or (user.jobTitle -eq "Employment Relations Adviser - Team High Risk") or (user.jobTitle -eq "Employment Relations Adviser, Out of Hours") or (user.jobTitle -eq "Employment Relations Documentation Consultant") or (user.jobTitle -eq "Employment Relations Document Consultant") or (user.jobTitle -eq "Employment Relations Digital Consultant") or (user.jobTitle -eq "Face2Face Case Adviser") or (user.jobTitle -eq "Face2Face Field Consultant") or (user.jobTitle -eq "Employment Relations Consultancy Specialist"))'

    MembershipRuleProcessingState = "On"
}

New-MgGroup @GroupParams