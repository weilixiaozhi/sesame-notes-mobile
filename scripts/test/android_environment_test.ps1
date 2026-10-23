#requires -Version 5.1
# 在 Temp 隔离目录使用模拟 Flutter 验证真实构建入口。
$ErrorActionPreference = 'Stop'
$sourceRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$tempRoot = [IO.Path]::GetFullPath((Join-Path $sourceRoot 'Temp'))
$fixture = Join-Path $tempRoot ('sesame-notes-environment-test-with space-' + [guid]::NewGuid().ToString('N'))
$originalJavaToolOptions = [Environment]::GetEnvironmentVariable('JAVA_TOOL_OPTIONS', 'Process')
$global:environmentTestArguments = $null
$global:environmentTestJavaToolOptions = $null
$global:environmentTestExit = 0
$global:environmentTestNoOutput = $false
$checks = 0
<# .SYNOPSIS 断言隔离测试结果并记录检查数量。 #>
function Assert-Condition([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
    $script:checks++
}
<# .SYNOPSIS 执行真实构建入口，并核对成功与失败路径都恢复调用方的 Java 环境。 #>
function Invoke-Entry([hashtable]$Parameters) {
    $global:environmentTestArguments = $null
    $javaOptionsBeforeEntry = [Environment]::GetEnvironmentVariable('JAVA_TOOL_OPTIONS', 'Process')
    try {
        & (Join-Path $fixture 'scripts/build_android.ps1') @Parameters
    } finally {
        Assert-Condition ([Environment]::GetEnvironmentVariable('JAVA_TOOL_OPTIONS', 'Process') -ceq $javaOptionsBeforeEntry) 'Build entry did not restore JAVA_TOOL_OPTIONS.'
    }
}
<# .SYNOPSIS 确认非法配置被拒绝，并检查 Flutter 是否尚未调用。 #>
function Assert-Rejected([hashtable]$Parameters, [string]$Message, [bool]$BeforeFlutter = $true) {
    $rejected = $false
    try { Invoke-Entry $Parameters } catch { $rejected = $true }
    Assert-Condition $rejected $Message
    if ($BeforeFlutter) {
        Assert-Condition ($null -eq $global:environmentTestArguments) ('Flutter invoked: ' + $Message)
    }
}
<# .SYNOPSIS 捕获构建参数和 Java 环境，用隔离产物模拟 Flutter 的成功与失败。 #>
function global:flutter {
    $global:environmentTestArguments = @($args)
    $global:environmentTestJavaToolOptions = [Environment]::GetEnvironmentVariable('JAVA_TOOL_OPTIONS', 'Process')
    $global:LASTEXITCODE = $global:environmentTestExit
    if ($global:environmentTestExit -ne 0 -or $global:environmentTestNoOutput -or $args -contains '--config-only') { return }
    $flavorIndex = [Array]::IndexOf($args, '--flavor')
    $flavor = $args[$flavorIndex + 1].ToLowerInvariant()
    $mode = if ($args -contains '--release') { 'release' } elseif ($args -contains '--profile') { 'profile' } else { 'debug' }
    $apk = Join-Path (Get-Location).Path "build/app/outputs/flutter-apk/app-$flavor-$mode.apk"
    $null = New-Item -ItemType Directory -Force -Path (Split-Path -Parent $apk)
    [IO.File]::WriteAllText($apk, 'fake Flutter output - not an APK')
}
try {
    $null = New-Item -ItemType Directory -Path (Join-Path $fixture 'scripts'), (Join-Path $fixture 'config') -Force
    Copy-Item -LiteralPath (Join-Path $sourceRoot 'scripts/build_android.ps1') -Destination (Join-Path $fixture 'scripts/build_android.ps1')
    [IO.File]::WriteAllText((Join-Path $fixture 'pubspec.yaml'), ('version: 1.2.3+4' + [Environment]::NewLine))
    # 独立准备构建文件时允许 Flutter 不输出 APK，也不能创建分发目录。
    foreach ($environment in @('test', 'prod')) {
        Invoke-Entry @{ Environment = $environment; ConfigOnly = $true }
        $prepareCall = $global:environmentTestArguments
        Assert-Condition ($prepareCall -contains '--config-only') 'Configuration-only did not request Flutter configuration generation.'
        Assert-Condition ($prepareCall -contains "--dart-define=APP_ENV=$environment") 'Configuration-only lost the selected environment.'
        Assert-Condition (-not (Test-Path -LiteralPath (Join-Path $fixture 'build'))) 'Configuration-only created APK output directories.'
    }
    Assert-Rejected @{ Environment = 'test'; ValidateOnly = $true; ConfigOnly = $true } 'Accepted conflicting validation and configuration-only modes.'
    Assert-Rejected @{ Environment = 'test'; ConfigOnly = $true; DartDefine = @('APP_ENV=prod') } 'Configuration-only bypassed environment validation.'
    foreach ($environment in @('test', 'prod')) {
        Invoke-Entry @{ Environment = $environment }
        $localCall = $global:environmentTestArguments
        Assert-Condition ($localCall -contains "--dart-define=APP_ENV=$environment") 'Local build did not inject the selected environment.'
        Assert-Condition (-not ($localCall -match '^--dart-define-from-file=')) 'Local build used a missing configuration file.'
        Assert-Condition (-not ($localCall -match 'API_BASE_URL')) 'Local build injected a placeholder server URL.'
    }
    Invoke-Entry @{ Environment = 'test'; DartDefine = @('API_BASE_URL=http://127.0.0.1:8080') }
    Assert-Condition ($global:environmentTestArguments -contains '--dart-define=API_BASE_URL=http://127.0.0.1:8080') 'Server override without a configuration file was lost.'
    Copy-Item -LiteralPath (Join-Path $sourceRoot 'config/test.example.json') -Destination (Join-Path $fixture 'config/test.local.json')
    Copy-Item -LiteralPath (Join-Path $sourceRoot 'config/prod.example.json') -Destination (Join-Path $fixture 'config/prod.local.json')
    [IO.File]::WriteAllText((Join-Path $fixture 'pubspec.yaml'), ('version: 1.2.3+4' + [Environment]::NewLine))
    Invoke-Entry @{ Environment = 'prod'; ValidateOnly = $true }
    Assert-Condition ($null -eq $global:environmentTestArguments) 'Validation-only invoked Flutter.'
    Assert-Rejected @{ Environment = 'prod'; ConfigPath = 'config/missing.local.json' } 'Accepted missing config file.'
    $customPath = Join-Path $fixture 'config/custom with spaces.json'
    Copy-Item -LiteralPath (Join-Path $fixture 'config/test.local.json') -Destination $customPath
    Invoke-Entry @{ Environment = 'test'; ConfigPath = 'config/custom with spaces.json' }
    Assert-Condition ($global:environmentTestArguments -contains "--dart-define-from-file=$customPath") 'Custom relative config path was not resolved against repository root.'
    Invoke-Entry @{ Environment = 'test'; ConfigPath = $customPath }
    Assert-Condition ($global:environmentTestArguments -contains "--dart-define-from-file=$customPath") 'Absolute config path was not preserved.'
    Invoke-Entry @{ Environment = 'test'; ConfigPath = $customPath; ConfigOnly = $true }
    Assert-Condition ($global:environmentTestArguments -contains "--dart-define-from-file=$customPath") 'Configuration-only lost the explicit config path.'
    Invoke-Entry @{ Environment = 'test' }
    $call = $global:environmentTestArguments
    Assert-Condition ($call -contains '--debug' -and $call -contains 'envTest') 'Test flavor/mode mismatch.'
    Assert-Condition ($call -contains "--dart-define-from-file=$(Join-Path $fixture 'config/test.local.json')") 'Test config was not supplied.'
    $testArtifact = Join-Path $fixture 'build/test/Sesame-Notes-test-v1.2.3-android-arm64-test-id.apk'
    Assert-Condition (Test-Path -LiteralPath $testArtifact) 'Missing test artifact.'
    Assert-Condition ([IO.File]::ReadAllText($testArtifact) -eq 'fake Flutter output - not an APK') 'Artifact contents changed.'
    # 工作目录已有旧 APK 时，准备模式仍不能把它重新当作新产物复制。
    [IO.File]::WriteAllText($testArtifact, 'existing artifact must stay unchanged')
    Invoke-Entry @{ Environment = 'test'; ConfigOnly = $true }
    Assert-Condition ([IO.File]::ReadAllText($testArtifact) -eq 'existing artifact must stay unchanged') 'Configuration-only copied a stale APK.'
    if ($env:OS -eq 'Windows_NT') {
        # 带空格的仓库路径保持单个 JVM 参数，已有调用方参数在构建期间继续保留。
        $expectedSocketOption = '"-Djdk.net.unixdomain.tmpdir=' + (Join-Path $fixture 'Temp').Replace('\', '/') + '"'
        Assert-Condition ($global:environmentTestJavaToolOptions.Contains($expectedSocketOption)) 'Java socket directory was not supplied as one quoted option.'
        $env:JAVA_TOOL_OPTIONS = '-Dsesame.build.test=caller'
        Invoke-Entry @{ Environment = 'test' }
        Assert-Condition ($global:environmentTestJavaToolOptions.StartsWith('-Dsesame.build.test=caller ')) 'Caller Java options were not preserved during the build.'
    }
    Invoke-Entry @{ Environment = 'test'; ProfileProbe = $true }
    $call = $global:environmentTestArguments
    Assert-Condition ($call -contains '--profile' -and $call -contains 'envTestProbe' -and $call -contains 'e2e/day_profile_probe.dart') 'Test probe flavor/target mismatch.'
    Assert-Condition ($call -contains "--dart-define-from-file=$(Join-Path $fixture 'config/test.local.json')") 'Probe config missing.'
    Invoke-Entry @{ Environment = 'prod'; DartDefine = @('LABEL=value with spaces', 'API_BASE_URL=https://example.invalid') }
    $call = $global:environmentTestArguments
    Assert-Condition ($call -contains '--release' -and $call -contains 'prod') 'Production flavor/mode mismatch.'
    Assert-Condition ($call -contains "--dart-define-from-file=$(Join-Path $fixture 'config/prod.local.json')") 'Production config missing.'
    Assert-Condition ($call -contains '--dart-define=LABEL=value with spaces') 'Caller definition split.'
    Assert-Condition (Test-Path -LiteralPath (Join-Path $fixture 'build/prod/Sesame-Notes-prod-v1.2.3.apk')) 'Missing production artifact.'
    Assert-Rejected @{ Environment = 'dev' } 'Accepted dev.'
    Invoke-Entry @{ Environment = 'prod'; TargetPlatform = 'android-x64' }
    Assert-Condition (Test-Path -LiteralPath (Join-Path $fixture 'build/prod/Sesame-Notes-prod-v1.2.3-android-x64.apk')) 'Missing distinct alternate production ABI artifact.'
    Assert-Condition (Test-Path -LiteralPath (Join-Path $fixture 'build/prod/Sesame-Notes-prod-v1.2.3.apk')) 'Alternate ABI replaced the canonical arm64 artifact.'
    Assert-Rejected @{ Environment = 'prod'; ProfileProbe = $true } 'Accepted prod profile probe.'
    foreach ($definitions in @(
        @('BROKEN'), @('APP_ENV=prod'), @('BAD KEY=value'), @('api_base_url=https://example.invalid'),
        @('LABEL=a', 'LABEL=b'), @('API_BASE_URL= '),
        @('UPDATE_MANIFEST_URL=https://updates.example.invalid/update.json')
    )) {
        Assert-Rejected @{ Environment = 'test'; DartDefine = $definitions } 'Accepted unsafe or invalid test define.'
    }
    Invoke-Entry @{ Environment = 'test'; DartDefine = @('API_BASE_URL=') }
    Assert-Condition ($global:environmentTestArguments -contains '--dart-define=API_BASE_URL=') 'Explicit local configuration was lost.'
    Assert-Rejected @{ Environment = 'prod'; DartDefine = @('API_BASE_URL=http://127.0.0.1:8080') } 'Accepted test endpoint for prod.'
    foreach ($invalidApi in @('https://user:secret@example.invalid', 'https://example.invalid?query=1', 'https://example.invalid#fragment', 'https://example.invalid:0', 'https://example.invalid:65536', ' https://example.invalid')) {
        Assert-Rejected @{ Environment = 'prod'; DartDefine = @("API_BASE_URL=$invalidApi") } 'Accepted invalid production API URL.'
    }
    foreach ($invalidUpdate in @('http://updates.example.invalid', 'https://user:secret@updates.example.invalid', 'https://updates.example.invalid?query=1', 'https://updates.example.invalid#fragment')) {
        Assert-Rejected @{ Environment = 'prod'; DartDefine = @("UPDATE_MANIFEST_URL=$invalidUpdate") } 'Accepted invalid update URL.'
    }
    Invoke-Entry @{ Environment = 'prod'; DartDefine = @('UPDATE_MANIFEST_URL=https://updates.example.invalid/update.json') }
    $testConfigPath = Join-Path $fixture 'config/test.local.json'
    $originalConfig = [IO.File]::ReadAllText($testConfigPath)
    [IO.File]::WriteAllText($testConfigPath, $originalConfig.Replace('"test"', '"prod"'))
    Assert-Rejected @{ Environment = 'test' } 'Accepted config/environment mismatch.'
    [IO.File]::WriteAllText($testConfigPath, $originalConfig)
    [IO.File]::WriteAllText($testConfigPath, '{')
    Assert-Rejected @{ Environment = 'test' } 'Accepted malformed JSON.'
    [IO.File]::WriteAllText($testConfigPath, '{"APP_ENV":"test","API_BASE_URL":"","UPDATE_MANIFEST_URL":""}')
    Invoke-Entry @{ Environment = 'test'; ValidateOnly = $true }
    Assert-Condition ($null -eq $global:environmentTestArguments) 'Local configuration validation invoked Flutter.'
    [IO.File]::WriteAllText($testConfigPath, '{"APP_ENV":"test","API_BASE_URL":123,"UPDATE_MANIFEST_URL":""}')
    Assert-Rejected @{ Environment = 'test' } 'Accepted non-string API address.'
    [IO.File]::WriteAllText($testConfigPath, '{"APP_ENV":"test","api_base_url":"http://127.0.0.1:8080","UPDATE_MANIFEST_URL":""}')
    Assert-Rejected @{ Environment = 'test' } 'Accepted incorrect case for compile variable.'
    [IO.File]::WriteAllText($testConfigPath, $originalConfig)
    Assert-Condition (Test-Path -LiteralPath (Join-Path $fixture 'Temp/android-build-errors.log')) 'Build failure details were not logged.'
    $global:environmentTestExit = 17
    Assert-Rejected @{ Environment = 'test' } 'Accepted failed Flutter build.' $false
    Assert-Rejected @{ Environment = 'test'; ConfigOnly = $true } 'Accepted failed Flutter configuration preparation.' $false
    $global:environmentTestExit = 0
    $global:environmentTestNoOutput = $true
    Remove-Item -LiteralPath (Join-Path $fixture 'build/app/outputs/flutter-apk/app-envtest-debug.apk')
    Assert-Rejected @{ Environment = 'test'; TargetPlatform = 'android-x64' } 'Accepted missing Flutter output.' $false
    $global:LASTEXITCODE = 0
    Write-Output "Android environment behavior checks passed ($checks assertions; fake Flutter, no APK build)."
} finally {
    if ($null -eq $originalJavaToolOptions) {
        Remove-Item -LiteralPath 'Env:\JAVA_TOOL_OPTIONS' -ErrorAction SilentlyContinue
    } else {
        [Environment]::SetEnvironmentVariable('JAVA_TOOL_OPTIONS', $originalJavaToolOptions, 'Process')
    }
    Remove-Item -LiteralPath 'Function:\flutter' -ErrorAction SilentlyContinue
    $resolvedFixture = [IO.Path]::GetFullPath($fixture)
    $allowedPrefix = $tempRoot.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    if (-not $resolvedFixture.StartsWith($allowedPrefix, [StringComparison]::OrdinalIgnoreCase) -or
        [IO.Path]::GetFileName($resolvedFixture) -notlike 'sesame-notes-environment-test-*') {
        throw 'Refusing cleanup outside this test fixture.'
    }
    if (Test-Path -LiteralPath $resolvedFixture) { Remove-Item -LiteralPath $resolvedFixture -Recurse -Force }
}
