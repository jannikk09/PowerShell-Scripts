# Prompt for source and target user names
$sourceUser = Read-Host -Prompt "Enter the username of the source user"
$targetUser = Read-Host -Prompt "Enter the username of the target user"

# Retrieve group memberships of the source user
$groups = Get-ADUser -Identity $sourceUser -Properties MemberOf | Select-Object -ExpandProperty MemberOf

# Check if groups were found
if ($groups -eq $null) {
    Write-Host "No group memberships found for the user $sourceUser."
} else {
    # Iterate through each group and add the target user
    foreach ($group in $groups) {
        Add-ADGroupMember -Identity $group -Members $targetUser
    }

    Write-Host "Group memberships copied from $sourceUser to $targetUser."
}
