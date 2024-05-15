try {
    Get-ChildItem -Path "C:\Windows\Temp", "$env:TEMP" -Recurse | Remove-Item -Force -Recurse -ErrorAction Stop
    exit 0  # Erfolgreich
} catch {
    Write-Error "Fehler beim Löschen der Dateien: $_"
    exit 1  # Fehler
}
