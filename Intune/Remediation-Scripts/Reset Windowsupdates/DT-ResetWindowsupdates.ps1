$service = Get-Service -Name wuauserv

$folderExists = Test-Path -Path "C:\Windows\SoftwareDistribution"

if ($service.Status -ne 'Running' -or -not $folderExists) {
    Write-Output "Bereinigung benötigt"
    exit 1
} else {
    Write-Output "Alles in Ordnung"
    exit 0
}
