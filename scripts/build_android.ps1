<#
.SYNOPSIS
读取可选构建配置，在调用 Flutter 前校验地址和环境，生成对应 Android 安装包。
.PARAMETER ConfigPath
配置文件绝对路径或相对仓库根目录路径；默认读取存在的 config/<环境>.local.json，无文件时使用本地功能配置。
.PARAMETER ValidateOnly
只检查配置，不调用 Flutter 或构建安装包。
.PARAMETER ConfigOnly
校验配置并让 Flutter 准备 Android 构建文件和 Gradle wrapper，不编译或复制安装包。
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('test', 'prod')]
    [string]$Environment,
    [ValidateSet('android-arm', 'android-arm64', 'android-x64')]
    [string]$TargetPlatform = 'android-arm64',
    [switch]$ProfileProbe,
    [string]$ConfigPath = '',
    [switch]$ValidateOnly,
    [switch]$ConfigOnly,
    [string[]]$DartDefine = @()
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
try {
    if ($ValidateOnly -and $ConfigOnly) {
        throw 'ValidateOnly 与 ConfigOnly 不能同时使用，请选择配置校验或构建文件准备。'
    }
    if ($Environment -ne 'test' -and $ProfileProbe) {
        throw 'ProfileProbe is only valid for test.'
    }
    $explicitConfig = -not [string]::IsNullOrWhiteSpace($ConfigPath)
    if (-not $explicitConfig) {
        $ConfigPath = "config/$Environment.local.json"
    }
    $resolvedConfigPath = if ([IO.Path]::IsPathRooted($ConfigPath)) {
        [IO.Path]::GetFullPath($ConfigPath)
    } else {
        [IO.Path]::GetFullPath((Join-Path $repoRoot $ConfigPath))
    }
    $hasConfigFile = Test-Path -LiteralPath $resolvedConfigPath -PathType Leaf
    if ($explicitConfig -and -not $hasConfigFile) {
        throw '找不到指定的构建配置文件，请检查 ConfigPath；不指定配置文件也可以构建本地功能。'
    }
    $config = if ($hasConfigFile) {
        Get-Content -LiteralPath $resolvedConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
    } else {
        [pscustomobject]@{ APP_ENV = $Environment; API_BASE_URL = ''; UPDATE_MANIFEST_URL = '' }
    }
    # Dart 编译变量区分大小写，配置键必须原样匹配，避免校验值与实际注入值不同。
    foreach ($requiredKey in @('APP_ENV', 'API_BASE_URL', 'UPDATE_MANIFEST_URL')) {
        if ($config.PSObject.Properties.Name -cnotcontains $requiredKey) {
            throw "构建配置缺少 $requiredKey，键名必须使用大写。"
        }
    }
    if ($config.APP_ENV -cne $Environment) {
        throw 'APP_ENV in the configuration must match Environment.'
    }
    if ($config.API_BASE_URL -isnot [string] -or $config.UPDATE_MANIFEST_URL -isnot [string]) {
        throw '构建配置必须包含字符串类型的 API_BASE_URL 和 UPDATE_MANIFEST_URL（禁用更新时填空字符串）。'
    }
    $effectiveApi = [string]$config.API_BASE_URL
    $effectiveUpdate = [string]$config.UPDATE_MANIFEST_URL
    $definitions = @{}
    foreach ($definition in $DartDefine) {
        if ([string]::IsNullOrWhiteSpace($definition) -or $definition.IndexOf('=') -lt 1) {
            throw 'DartDefine must use NAME=value syntax.'
        }
        $separator = $definition.IndexOf('=')
        $key = $definition.Substring(0, $separator)
        $value = $definition.Substring($separator + 1)
        if ($key -cnotmatch '^[A-Za-z_][A-Za-z0-9_]*$') {
            throw 'DartDefine 的名称只能包含英文字母、数字和下划线，且不能以数字开头。'
        }
        if ($key -in @('API_BASE_URL', 'UPDATE_MANIFEST_URL') -and
            $key -cnotin @('API_BASE_URL', 'UPDATE_MANIFEST_URL')) {
            throw 'API_BASE_URL 和 UPDATE_MANIFEST_URL 的编译变量名称必须使用大写。'
        }
        if ($key -eq 'APP_ENV') {
            throw "$key is controlled by the build entry, not DartDefine."
        }
        if ($definitions.ContainsKey($key)) {
            throw "Duplicate DartDefine: $key"
        }
        $definitions[$key] = $value
        if ($key -eq 'API_BASE_URL') { $effectiveApi = $value }
        if ($key -eq 'UPDATE_MANIFEST_URL') { $effectiveUpdate = $value }
    }
    [Uri]$apiUri = $null
    if ($effectiveApi -ne '' -and ($effectiveApi.Trim() -cne $effectiveApi -or $effectiveApi.Contains('\') -or
        -not [Uri]::TryCreate($effectiveApi, [UriKind]::Absolute, [ref]$apiUri) -or
        $apiUri.Scheme -notin @('http', 'https') -or [string]::IsNullOrEmpty($apiUri.Host) -or
        $apiUri.Port -le 0 -or
        $apiUri.UserInfo -ne '' -or $apiUri.Query -ne '' -or $apiUri.Fragment -ne '')) {
        throw 'API_BASE_URL must be empty or an HTTP(S) server address without credentials, query or fragment.'
    }
    if ($effectiveApi -ne '' -and $Environment -eq 'prod' -and $apiUri.Scheme -ne 'https') {
        throw '正式环境的 API_BASE_URL 必须是 HTTPS 公网入口；Nginx 到后端的内部连接仍可使用 HTTP。'
    }
    if ($Environment -eq 'test' -and $effectiveUpdate -ne '') {
        throw 'Test packages do not use the production update channel.'
    }
    if ($effectiveUpdate -ne '') {
        [Uri]$updateUri = $null
        if ($effectiveUpdate.Trim() -cne $effectiveUpdate -or $effectiveUpdate.Contains('\') -or
            -not [Uri]::TryCreate($effectiveUpdate, [UriKind]::Absolute, [ref]$updateUri) -or
            $updateUri.Scheme -ne 'https' -or [string]::IsNullOrEmpty($updateUri.Host) -or
            $updateUri.Port -le 0 -or $updateUri.UserInfo -ne '' -or
            $updateUri.Query -ne '' -or $updateUri.Fragment -ne '') {
            throw 'UPDATE_MANIFEST_URL 必须为空或无凭据、查询参数或片段的 HTTPS 地址。'
        }
    }
    if ($ValidateOnly) {
        Write-Host "Android $Environment 构建配置校验通过。"
        return
    }
    $versionLine = Get-Content -LiteralPath (Join-Path $repoRoot 'pubspec.yaml') -Encoding UTF8 |
        Where-Object { $_ -match '^version:' } | Select-Object -First 1
    if ($versionLine -notmatch '^version:\s*(\d+\.\d+\.\d+)\+([1-9]\d*)\s*$') {
        throw 'pubspec.yaml must provide a semantic version and positive build number.'
    }
    $versionName = $Matches[1]
    $flutterCommand = Get-Command flutter -ErrorAction Stop
    # AGP 保留 test 前缀风味名，对外环境名使用 test/prod。
    $flavor = if ($Environment -eq 'prod') { 'prod' } elseif ($ProfileProbe) { 'envTestProbe' } else { 'envTest' }
    $mode = if ($Environment -eq 'prod') { 'release' } elseif ($ProfileProbe) { 'profile' } else { 'debug' }
    $buildArguments = @(
        'build', 'apk', "--$mode", '--flavor', $flavor,
        '--target-platform', $TargetPlatform, '--no-pub'
    )
    if ($ConfigOnly) { $buildArguments += '--config-only' }
    # 本地构建只注入真实环境，服务地址为空时不生成占位地址或临时配置。
    if ($hasConfigFile) {
        $buildArguments += "--dart-define-from-file=$resolvedConfigPath"
    } else {
        $buildArguments += "--dart-define=APP_ENV=$Environment"
    }
    if ($ProfileProbe) {
        $buildArguments += @('--target', 'e2e/day_profile_probe.dart')
    }
    foreach ($definition in $DartDefine) { $buildArguments += "--dart-define=$definition" }

    $javaToolOptionsBeforeBuild = [Environment]::GetEnvironmentVariable('JAVA_TOOL_OPTIONS', 'Process')
    $javaToolOptionsChanged = $false
    Push-Location -LiteralPath $repoRoot
    try {
        if ($env:OS -eq 'Windows_NT') {
            # Windows 的 Java NIO 唤醒管道在临时目录创建本地域套接字，目录必须允许本机连接。
            # 只为当前构建指定仓库内目录，子 Java 进程继承该配置，原有 JVM 参数完整保留。
            $socketDirectory = Join-Path $repoRoot 'Temp'
            $null = New-Item -ItemType Directory -Force -Path $socketDirectory
            $socketDirectory = (Get-Item -LiteralPath $socketDirectory -ErrorAction Stop).FullName.Replace('\', '/')
            $socketOption = '"-Djdk.net.unixdomain.tmpdir=' + $socketDirectory + '"'
            $buildJavaToolOptions = if ([string]::IsNullOrWhiteSpace($javaToolOptionsBeforeBuild)) {
                $socketOption
            } else {
                $javaToolOptionsBeforeBuild + ' ' + $socketOption
            }
            [Environment]::SetEnvironmentVariable('JAVA_TOOL_OPTIONS', $buildJavaToolOptions, 'Process')
            $javaToolOptionsChanged = $true
            Write-Verbose "Java 本地域套接字临时目录：$socketDirectory"
        }
        & $flutterCommand @buildArguments
        if ($LASTEXITCODE -ne 0) {
            throw "Android $Environment build failed with exit code $LASTEXITCODE."
        }
        if ($ConfigOnly) {
            # Flutter 已生成 local.properties 和 Gradle wrapper，原生测试可直接调用 Gradle。
            Write-Host "Android $Environment 构建文件准备完成。"
            return
        }
        $nativeApk = Join-Path $repoRoot "build/app/outputs/flutter-apk/app-$($flavor.ToLowerInvariant())-$mode.apk"
        if (-not (Test-Path -LiteralPath $nativeApk -PathType Leaf)) {
            throw "Flutter completed without its expected APK: $nativeApk"
        }
        $outputDirectory = Join-Path $repoRoot "build/$Environment"
        $null = New-Item -ItemType Directory -Force -Path $outputDirectory
        if ($Environment -eq 'prod') {
            # arm64 使用更新服务识别的标准文件名，其余架构使用独立名称。
            $abiSuffix = if ($TargetPlatform -eq 'android-arm64') { '' } else { "-$TargetPlatform" }
            $artifactName = "Sesame-Notes-prod-v$versionName$abiSuffix.apk"
        } else {
            $identity = if ($ProfileProbe) { 'profile-probe' } else { 'test-id' }
            $artifactName = "Sesame-Notes-test-v$versionName-$TargetPlatform-$identity.apk"
        }
        $artifact = Join-Path $outputDirectory $artifactName
        Copy-Item -LiteralPath $nativeApk -Destination $artifact -Force
        Write-Host "Android $Environment artifact: $artifact"
    } catch {
        Write-Error -Message ("Android 构建失败：`n" + ($_ | Out-String)) -ErrorAction Continue
        throw
    } finally {
        try {
            if ($javaToolOptionsChanged) {
                if ($null -eq $javaToolOptionsBeforeBuild) {
                    # 未设置与空字符串是不同状态，显式删除才能恢复未设置状态。
                    Remove-Item -LiteralPath 'Env:\JAVA_TOOL_OPTIONS' -ErrorAction SilentlyContinue
                } else {
                    [Environment]::SetEnvironmentVariable('JAVA_TOOL_OPTIONS', $javaToolOptionsBeforeBuild, 'Process')
                }
            }
        } catch {
            Write-Error -Message ("恢复 Java 构建环境失败：`n" + ($_ | Out-String)) -ErrorAction Continue
            throw
        } finally {
            Pop-Location
        }
    }
} catch {
    $buildFailure = $_
    try {
        $logDirectory = Join-Path $repoRoot 'Temp'
        $null = New-Item -ItemType Directory -Force -Path $logDirectory
        $logPath = Join-Path $logDirectory 'android-build-errors.log'
        $detail = "[$([DateTimeOffset]::Now.ToString('o'))] Android $Environment`n$($buildFailure | Format-List * -Force | Out-String)"
        Add-Content -LiteralPath $logPath -Value $detail -Encoding UTF8
        Write-Error -Message "Android 构建失败：$($buildFailure.Exception.Message) 详细日志位于 Temp/android-build-errors.log。" -ErrorAction Continue
    } catch {
        Write-Error -Message "Android 构建失败，且错误日志无法写入：$($_.Exception.Message)" -ErrorAction Continue
    }
    throw $buildFailure
}
