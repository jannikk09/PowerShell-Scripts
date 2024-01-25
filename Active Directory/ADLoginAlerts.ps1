# Check current time
$currentTime = Get-Date
$startTimeParam = "18:00" # Start of outside working hours
$endTimeParam = "06:00"   # End of outside working hours

$start = [DateTime]::ParseExact($startTimeParam, "HH:mm", $null)
$end = [DateTime]::ParseExact($endTimeParam, "HH:mm", $null)

if ($currentTime.TimeOfDay -lt $end.TimeOfDay -or $currentTime.TimeOfDay -gt $start.TimeOfDay) {
    # Parameters for Email Sending
    $smtpServer = "smtp.example.com"
    $smtpFrom = "alert@example.com"
    $smtpTo = "admin@example.com"
    $smtpSubject = "Unusual Login Activity Detected"
    $smtpBody = "Unusual login activity detected in Active Directory. Details: `r`n"

    function IsOutsideWorkingHours($logonTime) {
        $logon = [DateTime]::ParseExact($logonTime, "HH:mm:ss", $null)

        if ($start -lt $end) {
            return ($logon -lt $start) -or ($logon -gt $end)
        } else {
            return ($logon -gt $end) -and ($logon -lt $start)
        }
    }

    # Retrieving Security Logs
    $events = Get-EventLog -LogName Security -InstanceId 4624 -Newest 50

    # Checking the Events
    foreach ($event in $events) {
        $username = $event.ReplacementStrings[5]
        $logonTime = $event.TimeGenerated.ToString("HH:mm:ss")
        
        if (IsOutsideWorkingHours $logonTime) {
            $smtpBody += "Date/Time: " + $event.TimeGenerated + ", User: " + $username + "`r`n"
        }
    }

    # Sending the Email
    if ($smtpBody -ne "Unusual login activity detected in Active Directory. Details: `r`n") {
        # Creating a MailMessage object
        $mailMessage = New-Object System.Net.Mail.MailMessage
        $mailMessage.From = [System.Net.Mail.MailAddress]::new($smtpFrom)
        $mailMessage.To.Add($smtpTo)
        $mailMessage.Subject = $smtpSubject
        $mailMessage.Body = $smtpBody
        $mailMessage.IsBodyHtml = $false # Set to $true for HTML
        $mailMessage.BodyEncoding = [System.Text.Encoding]::UTF8

        # Creating and configuring the SmtpClient object
        $smtpClient = New-Object System.Net.Mail.SmtpClient($smtpServer)
        $smtpClient.Send($mailMessage)
    }
} else {
    Write-Host "Current time is outside the set time window. Script is not being executed."
}
