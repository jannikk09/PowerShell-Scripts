# Enabling Windows Remote Management (WinRM)
# WinRM is required for the 'Invoke-Command' cmdlet to work remotely.
# To enable WinRM, run the following command in an elevated PowerShell prompt:
# Set-WSManQuickConfig -force

# Script to scan IP range, shutdown active hosts, and send an email with active hosts list

# Variables
$startIP = ""
$endIP = ""
$activeHosts = @()

# Function to Generate IP Range
function Get-IPRange {
    param($startIP, $endIP)

    $start = [System.Net.IPAddress]::Parse($startIP).GetAddressBytes()
    [Array]::Reverse($start)
    $start = [System.BitConverter]::ToUInt32($start, 0)

    $end = [System.Net.IPAddress]::Parse($endIP).GetAddressBytes()
    [Array]::Reverse($end)
    $end = [System.BitConverter]::ToUInt32($end, 0)

    $ipRange = @()
    for ($i = $start; $i -le $end; $i++) {
        $ipBytes = [System.BitConverter]::GetBytes($i)
        [Array]::Reverse($ipBytes)
        $ip = [System.Net.IPAddress]::Parse($([System.Net.IPAddress]::new($ipBytes)).ToString())
        $ipRange += $ip
    }
    return $ipRange
}

# Create IP Range
$ipRange = Get-IPRange -startIP $startIP -endIP $endIP

# Find Active Hosts
foreach ($ip in $ipRange) {
    $result = Test-Connection -ComputerName $ip.ToString() -Count 1 -Quiet
    if ($result) {
        try {
            $hostEntry = [System.Net.Dns]::GetHostEntry($ip.ToString())
            if ($hostEntry.HostName -ne $null -and $hostEntry.HostName -ne "") {
                $activeHosts += $hostEntry.HostName

                # Shutdown Computer
                Invoke-Command -ComputerName $hostEntry.HostName -ScriptBlock {
                    shutdown.exe /s /t 0
                }
            }
        } catch {
            # Ignore Unknown Hosts
        }
    }
}

# Send Email if Active Hosts Found
if ($activeHosts.Count -gt 0) {
    $smtpServer = ""
    $smtpPort = 587
    $smtpUser = ""
    $smtpPassword = ""

    $from = ""
    $to = ""
    $subject = "List of Active Computers"
    $body = "The following computers are active:`r`n`r`n" + ($activeHosts -join "`r`n")

    $smtpClient = New-Object System.Net.Mail.SmtpClient($smtpServer, $smtpPort)
    $smtpClient.EnableSsl = $true
    $smtpClient.Credentials = New-Object System.Net.NetworkCredential($smtpUser, $smtpPassword)
    $smtpClient.Send($from, $to, $subject, $body)
}
