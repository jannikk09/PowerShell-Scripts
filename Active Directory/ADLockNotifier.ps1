# This script should be executed when the following trigger is met:
# "Source: Microsoft Windows security auditing."
# "Event ID: 4740"

# SMTP Server Credentials
$smtpServer = ""
$smtpPort = 587
$smtpUser = ""
$smtpPass = ""

# Email Information
$to = ""
$from = ""
$subject = "Active Directory - User Account Locked"

# Create a Secure Password
$securePassword = ConvertTo-SecureString $smtpPass -AsPlainText -Force

# Create Credentials
$credentials = New-Object System.Management.Automation.PSCredential($smtpUser, $securePassword)

# Check for Locked Accounts
$lockedAccounts = Search-ADAccount -LockedOut

# If Locked Accounts Exist, Send Email
foreach ($account in $lockedAccounts) {
    $body = "The user account with the name $($account.SamAccountName) has been locked in Active Directory."

    Send-MailMessage -SmtpServer $smtpServer -Port $smtpPort -UseSsl -Credential $credentials -To $to -From $from -Subject $subject -Body $body
}
