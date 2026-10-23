#requires -Version 7.0
# 在本轮 Temp checkout 创建测试密钥；绝不访问正式 android/key.properties。
$ErrorActionPreference = 'Stop'
$Root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$TempRoot = Join-Path $Root 'Temp'
$Fixture = Join-Path $TempRoot "keystore-test-$([guid]::NewGuid().ToString('N'))"
$PreviousStore = $env:KEYSTORE_PASSWORD
$PreviousKey = $env:KEY_PASSWORD
$PreviousBase64 = $env:KEYSTORE_BASE64
$PreviousAlias = $env:KEY_ALIAS
try {
    $null = New-Item -ItemType Directory -Force -Path "$Fixture/scripts/android_keystore", "$Fixture/android/app"
    $Script = "$Fixture/scripts/android_keystore/generate_android_keystore.ps1"
    Copy-Item -LiteralPath "$Root/scripts/android_keystore/generate_android_keystore.ps1" -Destination $Script
    Copy-Item -LiteralPath "$Root/scripts/android_keystore/properties.ps1" -Destination "$Fixture/scripts/android_keystore/properties.ps1"
    Copy-Item -LiteralPath "$Root/scripts/android_keystore/restore_android_keystore.ps1" -Destination "$Fixture/scripts/android_keystore/restore_android_keystore.ps1"
    $env:KEYSTORE_PASSWORD = 'test-store-123'
    $env:KEY_PASSWORD = ' key\:=测试-123'
    & $Script -OutFile 'android/app/path with spaces/test.keystore' -Alias 'test-key'
    if ($LASTEXITCODE -ne 0) { throw '生成失败' }
    $Properties = "$Fixture/android/key.properties"
    $Before = [IO.File]::ReadAllBytes($Properties)
    # 使用真实 Java Properties 和 JKS 读回凭据，验证 BOM、转义与不同 Key 密码。
    $Java = @'
import java.nio.file.*;
import java.util.*;
import java.security.*;
class Check {
  public static void main(String[] args) throws Exception {
    var properties = new Properties();
    try (var stream = Files.newInputStream(Path.of(args[0], "android/key.properties"))) { properties.load(stream); }
    if (!properties.getProperty("keyPassword").equals(System.getenv("KEY_PASSWORD"))) throw new AssertionError("property roundtrip");
    var keyStore = KeyStore.getInstance("JKS");
    try (var stream = Files.newInputStream(Path.of(args[0], "android/app").resolve(properties.getProperty("storeFile")))) {
      keyStore.load(stream, properties.getProperty("storePassword").toCharArray());
    }
    if (keyStore.getKey(properties.getProperty("keyAlias"), properties.getProperty("keyPassword").toCharArray()) == null) throw new AssertionError("key missing");
  }
}
'@
    [IO.File]::WriteAllText("$Fixture/Check.java", $Java)
    & java "$Fixture/Check.java" $Fixture
    if ($LASTEXITCODE -ne 0) { throw 'Java 无法读取生成的签名材料' }
    foreach ($Output in @('android/app/path with spaces/test.keystore', 'android/app/another.keystore')) {
        $Rejected = $false
        try { & $Script -OutFile $Output } catch { $Rejected = $_.Exception.Message -match '拒绝覆盖' }
        if (-not $Rejected) { throw "未拒绝覆盖：$Output" }
    }
    if ([Convert]::ToBase64String($Before) -cne [Convert]::ToBase64String([IO.File]::ReadAllBytes($Properties))) {
        throw '已有属性文件被修改'
    }
    # 只删除本轮测试文件，验证 keytool 失败不会生成误导性的属性文件。
    Remove-Item -LiteralPath $Properties
    $env:KEYSTORE_BASE64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$Fixture/android/app/path with spaces/test.keystore"))
    $env:KEY_ALIAS = 'test-key'
    & "$Fixture/scripts/android_keystore/restore_android_keystore.ps1"
    if ($LASTEXITCODE -ne 0) { throw '发布签名还原失败' }
    & java "$Fixture/Check.java" $Fixture
    if ($LASTEXITCODE -ne 0) { throw 'Java 无法读取还原的签名材料' }
    Remove-Item -LiteralPath $Properties
    $Failed = $false
    try { & $Script -OutFile 'android/app/invalid.keystore' -DName 'invalid' } catch { $Failed = $true }
    if (-not $Failed -or (Test-Path -LiteralPath $Properties)) { throw 'keytool 失败路径不正确' }
    # 上一行刻意让 keytool 失败以验证失败路径，$LASTEXITCODE 仍为非零；
    # 断言全部通过后必须显式归零，否则 GitHub Actions 的 pwsh 包装会按该非零码判定脚本失败。
    $global:LASTEXITCODE = 0
    Write-Host '签名工具：真实 JKS/Properties 往返、禁止覆盖及失败路径通过。'
} finally {
    $env:KEYSTORE_PASSWORD = $PreviousStore
    $env:KEY_PASSWORD = $PreviousKey
    $env:KEYSTORE_BASE64 = $PreviousBase64
    $env:KEY_ALIAS = $PreviousAlias
    $Resolved = [IO.Path]::GetFullPath($Fixture)
    if (-not $Resolved.StartsWith([IO.Path]::GetFullPath($TempRoot) + [IO.Path]::DirectorySeparatorChar)) {
        throw '测试清理路径越界'
    }
    if (Test-Path -LiteralPath $Resolved) { Remove-Item -LiteralPath $Resolved -Recurse -Force }
}
