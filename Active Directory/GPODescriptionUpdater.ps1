# Path to your domain's SYSVOL directory
$sysvolPath = "\\YourDomainController\SYSVOL\domain.com\Policies"

# Retrieve all GPOs in the domain
$gpos = Get-GPO -All

# Heading for script execution
Write-Host "Beginning of GPO comment update" -ForegroundColor Cyan

foreach ($gpo in $gpos) {
    # Formatting the GPO ID with curly braces
    $gpoIDFormatted = "{" + $gpo.Id + "}"

    # The path to the GPO, including the formatted GUID
    $gpoPath = Join-Path -Path $sysvolPath -ChildPath $gpoIDFormatted

    # The path to the GPO.cmt file
    $cmtFilePath = Join-Path -Path $gpoPath -ChildPath "GPO.cmt"

    # Blank line for better readability
    Write-Host "`nUpdating GPO: $($gpo.DisplayName)"
    Write-Host "GPO ID: $gpoIDFormatted"

    # Prompt for a new description
    $newComment = Read-Host "Please enter a new comment (Enter for no change)"

    # Check if a comment was entered
    if ($newComment -ne "") {
        # Check if the GPO.cmt file exists
        if (Test-Path -Path $cmtFilePath) {
            try {
                # Update the comment in the GPO.cmt file with the correct encoding
                $newComment | Out-File -FilePath $cmtFilePath -Encoding Unicode
                Write-Host "Comment updated." -ForegroundColor Green
            } catch {
                Write-Host "Error: $_" -ForegroundColor Red
            }
        } else {
            Write-Host "The GPO.cmt file will be created and the comment added." -ForegroundColor Yellow
            New-Item -Path $cmtFilePath -ItemType File -Force | Out-Null
            $newComment | Out-File -FilePath $cmtFilePath -Encoding Unicode
        }
    } else {
        Write-Host "No change made." -ForegroundColor Yellow
    }

    # Separator line for clarity
    Write-Host "--------------------------------" -ForegroundColor DarkGray
}

Write-Host "GPO comment update completed." -ForegroundColor Cyan
