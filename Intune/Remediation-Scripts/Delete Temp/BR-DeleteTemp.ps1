Get-ChildItem -Path "C:\Windows\Temp" -Recurse | Remove-Item -Force -Recurse
Get-ChildItem -Path "$env:TEMP" -Recurse | Remove-Item -Force -Recurse
