# Import the Active Directory module for PowerShell
Import-Module ActiveDirectory

# Specify the path to the specific Organizational Unit (OU)
$ouPath = "OU=,OU=,DC=,DC="

# Retrieve all user accounts in the specified OU
$users = Get-ADUser -Filter * -SearchBase $ouPath

# Loop through each user in the list
foreach ($user in $users) {
    # Get all group memberships of the user, excluding the "Domain Users" group
    $groups = Get-ADPrincipalGroupMembership $user | Where-Object { $_.Name -ne "Domain Users" }

    # Remove the user from all groups except "Domain Users"
    foreach ($group in $groups) {
        Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false
    }

    # Disable the user account
    Disable-ADAccount -Identity $user.DistinguishedName
    # Display a message indicating that the user account has been disabled and removed from groups
    Write-Host "User account disabled and removed from groups: $($user.SamAccountName)"
}
