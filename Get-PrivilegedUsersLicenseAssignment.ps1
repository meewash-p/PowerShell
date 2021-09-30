#Install-Module MSOnline

# Connecting to MS Online Services
Connect-MsolService

# Check privileged users license assignment

# Get privileged users
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

foreach ($PrivilegedUser in $PrivilegedUsers) {
    Write-Host $PrivilegedUser -BackgroundColor Red
    $PrivUser = Get-MsolUser -UserPrincipalName $PrivilegedUser
    $PrivUser.Licenses.ServiceStatus | ft -AutoSize
}
