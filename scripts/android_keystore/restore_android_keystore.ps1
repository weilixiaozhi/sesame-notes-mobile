#requires -Version 7.0
<# .SYNOPSIS 从发布环境变量还原签名材料，凭据使用 Java Properties 转义且不输出日志。 #>
$ErrorActionPreference = 'Stop'
$RepoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
try {
    . (Join-Path $PSScriptRoot 'properties.ps1')
    foreach ($Name in @('KEYSTORE_BASE64', 'KEYSTORE_PASSWORD', 'KEY_ALIAS', 'KEY_PASSWORD')) {
        if ([string]::IsNullOrEmpty([Environment]::GetEnvironmentVariable($Name))) {
            throw "缺少发布签名配置：$Name"
        }
    }
    $StorePath = Join-Path $RepoRoot 'android/app/release.keystore'
    $PropertiesPath = Join-Path $RepoRoot 'android/key.properties'
    if ((Test-Path -LiteralPath $StorePath) -or (Test-Path -LiteralPath $PropertiesPath)) {
        throw '已有签名材料，拒绝覆盖。'
    }
    $Bytes = [Convert]::FromBase64String($env:KEYSTORE_BASE64)
    if ($Bytes.Length -eq 0) { throw '发布密钥内容为空。' }
    $Values = [ordered]@{
        storeFile = 'release.keystore'
        storePassword = $env:KEYSTORE_PASSWORD
        keyAlias = $env:KEY_ALIAS
        keyPassword = $env:KEY_PASSWORD
    }
    $Lines = foreach ($Entry in $Values.GetEnumerator()) {
        "$($Entry.Key)=$(ConvertTo-PropertyValue $Entry.Value)"
    }
    $null = New-Item -ItemType Directory -Force -Path (Split-Path -Parent $StorePath)
    [IO.File]::WriteAllBytes($StorePath, $Bytes)
    [IO.File]::WriteAllText($PropertiesPath, ($Lines -join "`n") + "`n", [Text.Encoding]::ASCII)
    Write-Host '发布签名材料已还原。'
} catch {
    # 不序列化异常对象，转换错误可能含有环境变量中的敏感原文。
    Write-Error "发布签名还原失败（$($_.Exception.GetType().Name)），请检查签名配置和目标文件权限。`n$($_.ScriptStackTrace)" -ErrorAction Continue
    exit 1
}
