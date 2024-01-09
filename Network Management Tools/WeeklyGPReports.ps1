# Base directory for storing the reports
$baseDirectory = "StorageLocation"

# Calculate current calendar week and year
$currentWeek = Get-Date -UFormat "%V"
$year = Get-Date -Format "yyyy"
$weekDirectory = Join-Path $baseDirectory "$year-KW$currentWeek"

# Create directory for the current week if it doesn't exist
if (-not (Test-Path -Path $weekDirectory)) {
    New-Item -ItemType Directory -Path $weekDirectory
}

# Retrieve all GPOs
$gpos = Get-GPO -All

foreach ($gpo in $gpos) {
    try {
        # Path for saving the report for each GPO
        $path = Join-Path $weekDirectory "$($gpo.DisplayName).html"

        # Generate Group Policy report
        Get-GPOReport -Guid $gpo.Id -ReportType Html | Out-File $path

        Write-Host "Report generated: $path"
    } catch {
        Write-Warning "Error generating report for GPO: $($gpo.DisplayName)"
        Write-Warning $_.Exception.Message
    }
}

# Delete old reports (older than 3 calendar weeks)
$currentWeekNumber = [int]$currentWeek
$obsoleteDirectories = Get-ChildItem -Path $baseDirectory -Directory |
                          Where-Object { 
                              $_.Name -match "$year-KW(\d+)" -and 
                              [int]$Matches[1] -le ($currentWeekNumber - 4) 
                          }

foreach ($directory in $obsoleteDirectories) {
    Remove-Item -Path $directory.FullName -Recurse -Force
    Write-Host "Old directory deleted: $($directory.FullName)"
}

Write-Host "Script completed."
