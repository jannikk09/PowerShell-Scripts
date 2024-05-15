$tempFiles = Get-ChildItem -Path "$env:TEMP" -Recurse
if ($tempFiles.Count -eq 0) {
    Write-Output "OK"
    exit 0
} else {
    exit 1
}
