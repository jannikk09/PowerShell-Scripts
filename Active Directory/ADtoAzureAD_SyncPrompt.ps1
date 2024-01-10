# ADtoAzureAD_SyncPrompt.ps1

# Prompt for user credentials
# This will open a dialog box for the user to enter their username and password
$Credential = Get-Credential

# Establish a session with the specified server using the provided credentials
# Replace 'SERVERNAME' with your server name
$Session = New-PSSession -ComputerName SERVERNAME -Credential $Credential

# Execute the command to start a delta synchronization cycle between AD and Azure AD
$Result = Invoke-Command -Session $Session -ScriptBlock { Start-ADSyncSyncCycle -PolicyType Delta }

# Close the session
Remove-PSSession $Session

# Output the result of the operation
if ($Result) {
  Write-Output "Command executed successfully."
} else {
  Write-Output "An error occurred."
}
