Import-Module ActiveDirectory
$DefaultmaxPasswordAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge

$users = Get-ADUser -Filter { SamAccountName -eq "Ashlea.Maley" } `
    -Properties Name, PasswordNeverExpires, PasswordExpired, PasswordLastSet, EmailAddress, mail, Enabled |
    Where { $_.Enabled -eq $true } |
    Where { $_.PasswordNeverExpires -eq $false } |
    Where { $_.PasswordExpired -eq $false }

foreach ($user in $users) {
    $Name = $user.Name
    $emailaddress = $user.EmailAddress
    $passwordSetDate = $user.PasswordLastSet
    $PasswordPol = Get-ADUserResultantPasswordPolicy -Identity $user.SamAccountName

    Write-Host "Name: $Name"
    Write-Host "EmailAddress: $emailaddress"
    Write-Host "Mail: $($user.mail)"
    Write-Host "PasswordSetDate: $passwordSetDate"
    if ($PasswordPol) {
        Write-Host "PasswordPolicy: MaxPasswordAge = $($PasswordPol.MaxPasswordAge)"
    } else {
        Write-Host "PasswordPolicy: Using Default Domain Policy ($DefaultmaxPasswordAge)"
    }
}
