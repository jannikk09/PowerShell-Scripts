# Parameters for Email Sending
$smtpServer = "smtp.example.com"
$smtpFrom = "alert@example.com"
$smtpTo = "admin@example.com"
$smtpSubject = "Unusual Login Activity Detected"
$smtpBody = "Unusual login activity detected in Active Directory. Details: `r`n"

# Parameters for Login Time Verification
$startTime = "18:00" # Start of Outside Working Hours
$endTime = "06:00"   # End of Outside Working Hours

function IsOutsideWorkingHours($logonTime) {
    $start = [DateTime]::ParseExact($startTime, "HH:mm", $null)
    $end = [DateTime]::ParseExact($endTime, "HH:mm", $null)
    $logon = [DateTime]::ParseExact($logonTime, "HH:mm:ss", $null)

    if ($start -lt $end) {
        return ($logon -lt $start) -or ($logon -gt $end)
    } else {
        return ($logon -gt $end) -and ($logon -lt $start)
    }
}

# Retrieving Security Logs
$query = @{
    LogName = 'Security'
    ID = 4624
    MaxEvents = 50
}
$events = Get-WinEvent -FilterHashtable $query

# Checking the Events
foreach ($event in $events) {
    $logonTime = $event.TimeGenerated.ToString("HH:mm:ss")
    
    if (IsOutsideWorkingHours $logonTime) {
        $smtpBody += "Date/Time: " + $event.TimeGenerated + ", User: " + $event.ReplacementStrings[5] + "`r`n"
    }
}

# Sending an Email if Unusual Activities are Found
if ($smtpBody -ne "Unusual login activity detected in Active Directory. Details: `r`n") {
    # Erstellen eines MailMessage-Objekts
    $mailMessage = New-Object System.Net.Mail.MailMessage
    $mailMessage.From = [System.Net.Mail.MailAddress]::new($smtpFrom)
    $mailMessage.To.Add($smtpTo)
    $mailMessage.Subject = $smtpSubject
    $mailMessage.Body = $smtpBody
    $mailMessage.IsBodyHtml = $false # Set this to $true if you are using HTML
    $mailMessage.BodyEncoding = [System.Text.Encoding]::UTF8

    # Erstellen und Konfigurieren des SmtpClient-Objekts
    $smtpClient = New-Object System.Net.Mail.SmtpClient($smtpServer)
    $smtpClient.Send($mailMessage)
}
