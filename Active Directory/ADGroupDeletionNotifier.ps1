# Credentials for the internal SMTP server
$smtpServer = ""  # Internal SMTP server
$smtpPort = 25    # Default SMTP port without SSL

# Email information
$to = "email@example.com"
$from = "email@example.com"
$subject = "Active Directory - Group Deleted"

# Function to retrieve the latest event with ID 4730
function Get-LatestDeletedGroupEvent {
    try {
        # Retrieve the latest event with ID 4730 from the Security Log
        $event = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4730} -MaxEvents 1
        if ($event) {
            # Convert the EventLog to an XML object
            $eventXml = [xml]$event.ToXml()
            # Check if EventData and Data elements are present
            if ($eventXml.Event.EventData -and $eventXml.Event.EventData.Data) {
                # Extract the group name and the username of the person who performed the action
                $deletedGroupName = ($eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetUserName' }).'#text'
                $subjectUserName = ($eventXml.Event.EventData.Data | Where-Object { $_.Name -eq 'SubjectUserName' }).'#text'
                if ($deletedGroupName -and $subjectUserName) {
                    return $deletedGroupName, $subjectUserName
                }
            }
        }
    } catch {
        Write-Host "Error retrieving the event: $_"
    }
    return $null, $null
}

# Retrieve the group name and the username for the latest deleted group event
$groupName, $userName = Get-LatestDeletedGroupEvent

# If a group name and username are found, send an email
if ($groupName -and $userName) {
    $body = "The group named `"$groupName`" was deleted by `"$userName`" from Active Directory."
    
    # Send the email with UTF-8 encoding
    $mailParameters = @{
        SmtpServer = $smtpServer
        Port = $smtpPort
        To = $to
        From = $from
        Subject = $subject
        Body = $body
        BodyAsHtml = $true
        Encoding = [System.Text.Encoding]::UTF8
    }

    Send-MailMessage @mailParameters
} else {
    Write-Host "No current event to send an email for."
}
