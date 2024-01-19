# Import the Group Policy Management Module
Import-Module GroupPolicy

# Retrieve all GPOs
$gpos = Get-GPO -All

foreach ($gpo in $gpos) {
    # Display the name of the current GPO
    Write-Host "GPO: $($gpo.DisplayName)"

    # Display the current description (if any)
    Write-Host "Current Description: $($gpo.Description)"

    # Prompt for a new description
    $newDescription = Read-Host "Enter a new description (leave blank to skip)"

    # Check if a description was entered
    if ($newDescription -ne "") {
        try {
            # Set the new description
            $gpo.Description = $newDescription
            $gpo.Save()
            Write-Host "Description updated."
        } catch {
            Write-Host "Error updating the description: $_"
        }
    } else {
        Write-Host "No change made."
    }

    # Separator line for clarity
    Write-Host "--------------------------------"
}

Write-Host "All GPOs have been processed."
