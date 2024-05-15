Stop-Service -Name wuauserv -Force

$folderPath = "C:\Windows\SoftwareDistribution"
if (Test-Path -Path $folderPath) {
    Remove-Item -Path $folderPath -Recurse -Force
}

Start-Service -Name wuauserv

Restart-Computer -Force
