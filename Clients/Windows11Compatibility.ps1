# Request credentials
$cred = Get-Credential

# Define the IP range
$startIp = X
$endIp = X
$baseIp = "X.X.X."

# Script block for compatibility check
$scriptBlock = {
    param($ipAddress)
    try {
        # Collect system information
        $cpu = Get-WmiObject -Class Win32_Processor
        $ram = Get-WmiObject -Class Win32_ComputerSystem
        $disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID = 'C:'"
        $secureBootStatus = Confirm-SecureBootUEFI
        $tpm = Get-WmiObject -Namespace "Root/CIMv2/Security/MicrosoftTpm" -Class Win32_Tpm
        $hostname = $env:COMPUTERNAME

        # Compatibility check
        $compatible = $cpu.NumberOfCores -ge 2 -and $cpu.MaxClockSpeed -ge 1000 -and $ram.TotalPhysicalMemory / 1GB -ge 4 -and $disk.Size / 1GB -ge 64 -and $secureBootStatus -and $tpm.SpecVersion -match "2.0"

        # Return results
        return [PSCustomObject]@{
            IPAddress = $ipAddress
            Hostname = $hostname
            CPU = $cpu.Name
            Cores = $cpu.NumberOfCores
            SpeedGHz = $cpu.MaxClockSpeed / 1000
            RAMGB = [math]::Round($ram.TotalPhysicalMemory / 1GB)
            DiskGB = [math]::Round($disk.Size / 1GB)
            SecureBoot = $secureBootStatus
            TPMVersion = $tpm.SpecVersion
            Compatible = $compatible
        }
    } catch {
        Write-Warning "Error checking $ipAddress"
    }
}

# Initialize results list
$results = @()

# Loop through the IP range and execute the script block on each computer
for ($i = $startIp; $i -le $endIp; $i++) {
    $ipAddress = "$baseIp$i"
    try {
        $result = Invoke-Command -ComputerName $ipAddress -ScriptBlock $scriptBlock -ArgumentList $ipAddress -Credential $cred -ErrorAction SilentlyContinue
        if ($result) {
            $results += $result
        } else {
            Write-Warning "No response from $ipAddress"
        }
    } catch {
        Write-Warning "Unable to connect or execute script on $ipAddress: $_"
    }
}

# Export the results to a CSV file
$results | Export-Csv -Path "PATH2File\CompatibilityResults.csv" -NoTypeInformation -Delimiter ";"
Write-Host "The results have been saved to 'PATH2File\CompatibilityResults.csv'."
