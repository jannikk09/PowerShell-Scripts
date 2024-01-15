# Create a configuration for Disk Cleanup using sageset
# This needs to be executed manually on each server to set the desired options.
# Example: cleanmgr.exe /sageset:1

# List of servers where the script should be executed
$servers = @("Server1", "Server2", "Server3")

# The number of the sageset to be used
$sagesetNumber = 1

# Main script
foreach ($server in $servers) {
    Write-Host "Starting Disk Cleanup on $server with sagerun:$sagesetNumber"
    Invoke-Command -ComputerName $server -ScriptBlock {
        # Run Disk Cleanup with the pre-configured settings
        Start-Process "C:\Windows\System32\cleanmgr.exe" -ArgumentList "/sagerun:$using:sagesetNumber" -Wait
    }
}
