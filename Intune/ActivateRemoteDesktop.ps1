# Überprüfen, ob Remotedesktop bereits aktiviert ist
$rdpEnabled = Get-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" | Select-Object -ExpandProperty "fDenyTSConnections"

if ($rdpEnabled -eq 0) {
  Write-Host "Remotedesktop ist bereits aktiviert."
} else {
  # Aktivieren von Remotedesktop
  Set-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
  Set-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -value 1

  # Firewallregel hinzufügen
  netsh advfirewall firewall add rule name="Remote Desktop" dir=in action=allow protocol=TCP localport=3389

  Write-Host "Remotedesktop wurde erfolgreich aktiviert."
}
