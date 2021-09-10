# Connecting to MS Online Services
Connect-MsolService

# Getting Users
$Users = Get-MsolUser -MaxResults 1000000 | 
    Select DisplayName, UserPrincipalName, StrongAuthenticationRequirements, ObjectId, FirstName, Surname, UserType

## Based on StrongAuthenticationRequirements Property, it is possible to establish current MFA state (Disabled or not disabled in O365 settings)
# $Users | Select DisplayName, UserPrincipalName, StrongAuthenticationRequirements, ObjectId | Format-Table -AutoSize

## Users without MFA configured (Export to CSV)
$Users | 
    Where-Object { $null -eq $_.StrongAuthenticationRequirements.Length } | 
    Select ObjectId,DisplayName, FirstName,Surname,UserPrincipalName |
    Export-Csv -Path .\Users-without-MFA.csv -NoTypeInformation

## Users with MFA (Export to CSV)
$Users | 
    Where-Object { $null -ne $_.StrongAuthenticationRequirements.Length } | 
    Select ObjectId,DisplayName, FirstName,Surname,UserPrincipalName | 
    Export-Csv -Path .\Users-with-MFA.csv -NoTypeInformation

## Internal Users without MFA (Export to CSV)
$Users | 
    Where-Object { $_.UserType -eq "Member" -and $null -eq $_.StrongAuthenticationRequirements.Length } | 
    Select ObjectId,DisplayName, FirstName,Surname,UserPrincipalName | 
    Export-Csv -Path .\Intrernal-Users-without-MFA.csv -NoTypeInformation
    
## Internal Users with MFA (Export to CSV)
$Users | 
    Where-Object { $_.UserType -eq "Member" -and $null -ne $_.StrongAuthenticationRequirements.Length } | 
    Select ObjectId,DisplayName, FirstName,Surname,UserPrincipalName | 
    Export-Csv -Path .\Intrernal-Users-with-MFA.csv -NoTypeInformation

## External Users (guest/external) without MFA (Export to CSV)
$Users | 
    Where-Object { $_.UserType -ne "Member" -and $null -eq $_.StrongAuthenticationRequirements.Length } | 
    Select ObjectId,DisplayName, FirstName,Surname,UserPrincipalName | 
    Export-Csv -Path .\External-Users-without-MFA.csv -NoTypeInformation

## External Users (guest/external) with MFA (Export to CSV)
$Users | 
    Where-Object { $_.UserType -ne "Member" -and $null -ne $_.StrongAuthenticationRequirements.Length } | 
    Select ObjectId,DisplayName, FirstName,Surname,UserPrincipalName | 
    Export-Csv -Path .\External-Users-with-MFA.csv -NoTypeInformation

## (Example) Checking MFA state for privileged accounts (excluding "service" accounts, PLEASE VERIFYADJUST EXCLUSIONS BELOW IN Where-Object STATEMENT!)
$PrivilegedUsers = @()
$Roles = Get-MsolRole
foreach ($Role in $Roles) {
    $Members = Get-MsolRoleMember -RoleObjectId $role.ObjectId | 
        Where-Object { $_.RoleMemberType -eq "User" -and `
        ($_.EmailAddress -notmatch '^Sync\w+' -and $_.EmailAddress -notmatch '^example\w+' -and `
        $_.EmailAddress -ne 'account@example.com' -and $_.EmailAddress -ne 'account2@example.com') }
    foreach ($Member in $Members) {
        if (-not $PrivilegedUsers.Contains($Member.EmailAddress)) {
            $PrivilegedUsers += $Member.EmailAddress
        }
    }
}

$PrivilegedUsersWithoutMFA = @()
foreach ($PrivilegedUser in $PrivilegedUsers) {
    $CheckedPrivilegedUser = Get-MsolUser -UserPrincipalName $PrivilegedUser | Where-Object { $null -eq $_.StrongAuthenticationRequirements.Length } | 
    Select ObjectId,DisplayName, FirstName,Surname,UserPrincipalName
    $PrivilegedUsersWithoutMFA += $CheckedPrivilegedUser
}

### Display results and save to CSV
Write-Host "PRIVILEGED USERS WITHOUT MFA:" -BackgroundColor Red
$PrivilegedUsersWithoutMFA | ft
$PrivilegedUsersWithoutMFA | Export-Csv -Path .\Privileged-Users-Without-MFA.csv -NoTypeInformation
