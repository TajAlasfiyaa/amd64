<#
This was made because I refuse to continue taking part in the unwritten
PowerShell/Batch obfuscation contest.
#>

param (
    [Parameter()]
    [Switch]$ForDownload
)

<#
There are myths that some Windows versions do not work without this.

Since I can't be arsed to verify this, I'm just adding this to lower the number
of reports to which I would normally respond with "works on my machine".
#>
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {
    Write-Error "不支持 Abandonware 操作系统。"
    Exit 1
}

$filesDownload = @('aria2c.exe')
$filesConvert = @('aria2c.exe', '7zr.exe', 'uup-converter-wimlib.7z')

$urls = @{
    'aria2c.exe' = 'https://www.uupdump.cn/public/autodl_files/files20231108/aria2c.exe';
    '7zr.exe' = 'https://www.uupdump.cn/public/autodl_files/files20231108/7zr.exe';
    'uup-converter-wimlib.7z' = 'https://www.uupdump.cn/public/autodl_files/files20231108/uup-converter-wimlib.7z';
}

$hashes = @{
    'aria2c.exe' = '0ae98794b3523634b0af362d6f8c04a9bbd32aeda959b72ca0e7fc24e84d2a66';
    '7zr.exe' = '108ab5f1e36f2068e368fe97cd763c639e403cac8f511c6681eaf19fc585d814';
    'uup-converter-wimlib.7z' = '7f07dfc0fa041820746c55c2704fd18f8930b984ca472d2ac397a1c69f15f3af';
}

function Retrieve-File {
    param (
        [String]$File,
        [String]$Url
    )

    Write-Host -BackgroundColor Black -ForegroundColor Yellow "正在下载 ${File}..."
    Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile "files\$File" -ErrorAction Stop
}

function Test-Hash {
    param (
        [String]$File,
        [String]$Hash
    )

    Write-Host -BackgroundColor Black -ForegroundColor Cyan "正在验证 ${File}..."

    $fileHash = (Get-FileHash -Path "files\$File" -Algorithm SHA256 -ErrorAction Stop).Hash
    return ($fileHash.ToLower() -eq $Hash)
}

if($ForDownload.IsPresent) {
    $files = $filesDownload
} else {
    $files = $filesConvert
}

if(-not (Test-Path -PathType Container -Path "files")) {
    $null = New-Item -Path "files" -ItemType Directory
}

foreach($file in $files) {
    try {
        Retrieve-File -File $file -Url $urls[$file]
    } catch {
        Write-Host "下载 $file 失败"
        Write-Host $_
        Exit 1
    }
}

Write-Host ""

foreach($file in $files) {
    if(-not (Test-Hash -File $file -Hash $hashes[$file])) {
        Write-Error "$file MD5校验不一致"
        Exit 1
    }
}

Write-Host ""
Write-Host -BackgroundColor Black -ForegroundColor Green "所有的依赖都准备好了"