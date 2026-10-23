#requires -Version 7.0
<#
.SYNOPSIS
跨平台创建新的 Android 发布密钥及 android/key.properties；拒绝覆盖已有签名材料。
.DESCRIPTION
需要已有 JDK keytool。密码读取 KEYSTORE_PASSWORD / KEY_PASSWORD，缺失时隐藏输入；
留空生成随机密码或复用 Keystore 密码。密码只写入属性文件，不输出到日志或命令参数。
#>
param(
    [string]$OutFile = 'android/app/release.keystore',
    [string]$Alias = 'release',
    [ValidateRange(1, 36500)][int]$Validity = 3650,
    [string]$DName = 'CN=Unknown, OU=Dev, O=Org, L=City, S=State, C=CN'
)

$ErrorActionPreference = 'Stop'
$RepoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$AppDir = Join-Path $RepoRoot 'android/app'
$OutFile = [IO.Path]::GetFullPath($OutFile, $RepoRoot)
$KeyPropsPath = Join-Path $RepoRoot 'android/key.properties'
foreach ($Path in @($OutFile, $KeyPropsPath)) {
    if (Test-Path -LiteralPath $Path) { throw "已有签名材料，拒绝覆盖：$Path" }
}
if ([string]::IsNullOrWhiteSpace($Alias)) { throw '密钥别名不能为空' }

$Keytool = if ($env:JAVA_HOME) {
    $Candidate = Join-Path $env:JAVA_HOME $(if ($IsWindows) { 'bin/keytool.exe' } else { 'bin/keytool' })
    if (Test-Path -LiteralPath $Candidate) { $Candidate }
}
if (-not $Keytool) { $Keytool = (Get-Command keytool -ErrorAction Stop).Source }

. (Join-Path $PSScriptRoot 'properties.ps1')

$StorePass = $env:KEYSTORE_PASSWORD
if (-not $StorePass) {
    $Secret = Read-Host 'Keystore 密码（留空自动生成，密码只保存到属性文件）' -AsSecureString
    $StorePass = [Net.NetworkCredential]::new('', $Secret).Password
    if (-not $StorePass) { $StorePass = [Convert]::ToBase64String([Security.Cryptography.RandomNumberGenerator]::GetBytes(24)) }
}
$KeyPass = $env:KEY_PASSWORD
if (-not $KeyPass) {
    $Secret = Read-Host 'Key 密码（留空复用 Keystore 密码）' -AsSecureString
    $KeyPass = [Net.NetworkCredential]::new('', $Secret).Password
    if (-not $KeyPass) { $KeyPass = $StorePass }
}
if ($StorePass.Length -lt 6 -or $KeyPass.Length -lt 6) { throw '密码至少需要 6 个字符' }

$PreviousStorePass = $env:KEYSTORE_PASSWORD
$PreviousKeyPass = $env:KEY_PASSWORD
try {
    $env:KEYSTORE_PASSWORD = $StorePass
    $env:KEY_PASSWORD = $KeyPass
    $null = New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutFile)
    # 显式 JKS 支持独立 Key 密码；默认 PKCS12 会忽略不同的 Key 密码。
    & $Keytool -genkeypair -noprompt -storetype JKS -alias $Alias -keystore $OutFile `
        -storepass:env KEYSTORE_PASSWORD -keypass:env KEY_PASSWORD -dname $DName `
        -validity $Validity -keyalg RSA -keysize 2048
    if ($LASTEXITCODE -ne 0) { throw "keytool 失败（exit=$LASTEXITCODE），未写入属性文件" }
    $Properties = @{
        storeFile = [IO.Path]::GetRelativePath($AppDir, $OutFile).Replace('\', '/')
        storePassword = $StorePass
        keyAlias = $Alias
        keyPassword = $KeyPass
    }
    $Lines = foreach ($Key in @('storeFile', 'storePassword', 'keyAlias', 'keyPassword')) {
        "$Key=$(ConvertTo-PropertyValue $Properties[$Key])"
    }
    # CreateNew 再次拒绝覆盖；ASCII 转义避免旧 PowerShell 的 UTF-8 BOM 损坏首个键。
    $Stream = [IO.File]::Open($KeyPropsPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write)
    try {
        $Bytes = [Text.Encoding]::ASCII.GetBytes(($Lines -join "`n") + "`n")
        $Stream.Write($Bytes)
    } finally { $Stream.Dispose() }
} finally {
    $env:KEYSTORE_PASSWORD = $PreviousStorePass
    $env:KEY_PASSWORD = $PreviousKeyPass
}
Write-Host "已创建密钥：$OutFile"
Write-Host "凭据已保存：$KeyPropsPath；请将密钥和凭据加密备份。"
