#requires -Version 5.1
# Generate / verify the checked-in Dart API client.
# Windows: powershell.exe -NoProfile -File scripts/openapi/generate_api_client.ps1 [-Preview|-Check]
# Linux/macOS CI: pwsh -NoProfile -File scripts/openapi/generate_api_client.ps1 [-Preview|-Check]
# 本轮临时产物独占仓库 Temp/openapi-generation 下的随机目录。
param(
  [switch]$Preview,
  [switch]$Check,
  [switch]$Offline
)

$ErrorActionPreference = 'Stop'

function Assert-OpenApiRuntime {
  param(
    [bool]$Windows = ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT),
    [version]$Version = $PSVersionTable.PSVersion
  )
  if ($Windows -and ($Version.Major -ne 5 -or $Version.Minor -ne 1)) {
    throw 'On Windows, run this script with Windows PowerShell 5.1 (powershell.exe), not pwsh.'
  }
  if (-not $Windows -and $Version.Major -lt 7) {
    throw 'On Linux/macOS, PowerShell 7 or newer is required.'
  }
}

function Get-OpenApiCanonicalPath {
  param([string]$Path)
  $Windows = [Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT
  if ([string]::IsNullOrWhiteSpace($Path) -or
      -not [IO.Path]::IsPathRooted($Path) -or
      ($Windows -and $Path -notmatch '^(?:[A-Za-z]:[\\/]|[\\/]{2}[^\\/]+[\\/][^\\/]+(?:[\\/]|$))') -or
      $Path -match '(?:^|[\\/])\.\.(?:[\\/]|$)') {
    throw ('An absolute path without parent traversal is required: ' + $Path)
  }
  $FullPath = [IO.Path]::GetFullPath($Path)
  $PathRoot = [IO.Path]::GetPathRoot($FullPath)
  # Preserve drive / UNC / Unix roots; TrimEndingDirectorySeparator is not in .NET Framework.
  if ($FullPath.Length -gt $PathRoot.Length) {
    $FullPath = $FullPath.TrimEnd([char[]]@([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar))
  }
  return $FullPath
}

function Assert-OpenApiNoLinks {
  param([string]$Path, [switch]$Recurse)
  $Current = Get-OpenApiCanonicalPath -Path $Path
  while ($Current) {
    if (Test-Path -LiteralPath $Current) {
      $Item = Get-Item -LiteralPath $Current -Force
      if (($Item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 -or $Item.LinkType) {
        throw ('OpenAPI paths must not contain links or junctions: ' + $Current)
      }
    }
    $Current = Split-Path -Path $Current -Parent
  }
  if ($Recurse -and (Test-Path -LiteralPath $Path)) {
    $Pending = [Collections.Generic.Stack[string]]::new()
    $Pending.Push($Path)
    while ($Pending.Count -gt 0) {
      $Directory = $Pending.Pop()
      foreach ($Child in Get-ChildItem -LiteralPath $Directory -Force) {
        if (($Child.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 -or $Child.LinkType) {
          throw ('OpenAPI trees must not contain links or junctions: ' + $Child.FullName)
        }
        if ($Child.PSIsContainer) { $Pending.Push($Child.FullName) }
      }
    }
  }
}

function Get-OpenApiCheckedRelativePath {
  param([string]$Root, [string]$Path, [string[]]$AllowedRelativePaths)
  $RootPath = Get-OpenApiCanonicalPath -Path $Root
  $AbsolutePath = Get-OpenApiCanonicalPath -Path $Path
  $Comparison = if ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT) {
    [StringComparison]::OrdinalIgnoreCase
  } else { [StringComparison]::Ordinal }
  $RootPrefix = $RootPath
  if (-not $RootPrefix.EndsWith([string][IO.Path]::DirectorySeparatorChar)) {
    $RootPrefix += [IO.Path]::DirectorySeparatorChar
  }
  if (-not $AbsolutePath.StartsWith($RootPrefix, $Comparison)) {
    throw ('OpenAPI path escapes the repository: ' + $AbsolutePath)
  }
  foreach ($Relative in $AllowedRelativePaths) {
    $Allowed = Get-OpenApiCanonicalPath -Path (Join-Path $RootPath $Relative)
    if ($AbsolutePath.Equals($Allowed, $Comparison)) {
      Assert-OpenApiNoLinks -Path $AbsolutePath
      # Return the canonical allowlist entry instead of the PS7-only GetRelativePath API.
      return $Relative.Replace('\', '/')
    }
  }
  throw ('OpenAPI path is not an allowed output: ' + $AbsolutePath)
}

function Get-OpenApiOutputRelativePath {
  param([string]$Root, [string]$OutDir, [string]$RunId)
  if ($RunId -cnotmatch '^[a-f0-9]{32}$') { throw 'Invalid OpenAPI generation run ID.' }
  return Get-OpenApiCheckedRelativePath -Root $Root -Path $OutDir -AllowedRelativePaths @(
    'packages/sesame_api_client',
    ('Temp/openapi-generation/preview/' + $RunId),
    ('Temp/openapi-generation/check/' + $RunId)
  )
}

function Assert-OpenApiInputDirectory {
  param([string]$Root, [string]$Path, [string]$RunId)
  if ($RunId -cnotmatch '^[a-f0-9]{32}$') { throw 'Invalid OpenAPI generation run ID.' }
  $null = Get-OpenApiCheckedRelativePath -Root $Root -Path $Path -AllowedRelativePaths @(
    ('Temp/openapi-generation/input/' + $RunId)
  )
}

Assert-OpenApiRuntime
$RunningOnWindows = [Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT
if ($Preview -and $Check) { throw '-Preview and -Check are mutually exclusive.' }
foreach ($Command in @('node', 'docker', 'dart')) {
  $null = Get-Command $Command -ErrorAction Stop
}
if ($Check) { $null = Get-Command git -ErrorAction Stop }

# Keep the formal generator image pinned.
$Image = 'openapitools/openapi-generator-cli:v7.24.0'
$SpecRel = 'api/openapi/sesame-notes-api-v1.0.0.json'

$Root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Assert-OpenApiNoLinks -Path $Root
$Spec = Join-Path $Root $SpecRel
if (-not (Test-Path $Spec)) { throw 'OpenAPI 文件不存在: ' + $Spec }
$ContractVersion = (Get-Content -LiteralPath $Spec -Raw | ConvertFrom-Json).info.version
if ($ContractVersion -notmatch '^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$') {
  throw 'OpenAPI 版本号无效'
}

$RunId = [guid]::NewGuid().ToString('N')
$Mode = if ($Check) { 'check' } else { 'preview' }
$OutDir = Join-Path $Root ('Temp/openapi-generation/' + $Mode + '/' + $RunId)
$Target = if ($Preview) { $OutDir } else { Join-Path $Root 'packages/sesame_api_client' }
$OutRel = Get-OpenApiOutputRelativePath -Root $Root -OutDir $OutDir -RunId $RunId
$null = Get-OpenApiOutputRelativePath -Root $Root -OutDir $Target -RunId $RunId
$InputRel = 'Temp/openapi-generation/input/' + $RunId
$NormalizedDirectory = Join-Path $Root $InputRel
Assert-OpenApiInputDirectory -Root $Root -Path $NormalizedDirectory -RunId $RunId
$NormalizedInput = Join-Path $NormalizedDirectory 'sesame-notes-normalized.json'
$OwnedOutput = $false
$OwnedInput = $false
$GenerationCompleted = $false

try {
  # 先确认 Docker 可用，生成和校验完成前保留正式包。
  docker info --format '{{.ServerVersion}}' | Out-Null
  if ($LASTEXITCODE -ne 0) { throw 'Docker 不可用' }
  # Never reuse or remove a different invocation's workspace.
  if ((Test-Path -LiteralPath $OutDir) -or (Test-Path -LiteralPath $NormalizedDirectory)) {
    throw 'The new OpenAPI workspace already exists; refusing to reuse it.'
  }
  $null = Get-OpenApiOutputRelativePath -Root $Root -OutDir $OutDir -RunId $RunId
  Assert-OpenApiInputDirectory -Root $Root -Path $NormalizedDirectory -RunId $RunId
  $null = New-Item -ItemType Directory -Path $OutDir
  $OwnedOutput = $true
  $null = New-Item -ItemType Directory -Path $NormalizedDirectory
  $OwnedInput = $true

  # 规范化输入只供本次生成使用，固定契约保持原样。
  Write-Host '==> normalize_openapi.mjs'
  node (Join-Path $Root 'scripts/openapi/normalize_openapi.mjs') $Spec $NormalizedInput
  if ($LASTEXITCODE -ne 0) { throw 'normalize_openapi 失败' }

  # 生成生产客户端，行为断言由根工程的手写契约测试负责。
  Write-Host ('==> openapi-generator ' + $Image + ' -> ' + $OutRel)
  $Mount = 'type=bind,source=' + $Root + ',target=/local'
  # 容器默认以 root 写挂载目录，Linux 上产物属 root，调用方随后读写与清理都会被拒；
  # 非 Windows 让容器以当前用户身份运行（Windows 的 Docker Desktop 已做属主映射）。
  $UserArgs = @()
  if ($Offline) {
    # 离线验证只使用已存在的生成器镜像，缺失时直接失败。
    $UserArgs += '--pull=never'
  }
  if (-not $RunningOnWindows) {
    $UserArgs += @('--user', ('{0}:{1}' -f (& id -u), (& id -g)), '--env', 'HOME=/tmp')
  }
  docker run --rm @UserArgs --mount $Mount $Image generate --skip-validate-spec -i ('/local/' + $InputRel + '/sesame-notes-normalized.json') -g dart-dio -o ('/local/' + $OutRel) --global-property apiTests=false,modelTests=false,apiDocs=false,modelDocs=false --openapi-generator-ignore-list 'README.md,doc/**' --additional-properties "pubName=sesame_api_client,pubLibrary=sesame_api_client,pubDescription=Sesame%20Notes%20v$($ContractVersion.Split('.')[0])%20OpenAPI%20client,pubVersion=$ContractVersion"
  if ($LASTEXITCODE -ne 0) { throw 'openapi-generator 失败' }

  # 生成模板可能重复声明同一个运行时导入，按完整指令确定性去重。
  foreach ($DartFile in Get-ChildItem -LiteralPath (Join-Path $OutDir 'lib') -Filter '*.dart' -Recurse -File) {
    $ImportSeen = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $DartLines = [Collections.Generic.List[string]]::new()
    $ImportsChanged = $false
    foreach ($DartLine in [IO.File]::ReadAllLines($DartFile.FullName)) {
      if ($DartLine -match '^import .+;$' -and -not $ImportSeen.Add($DartLine)) {
        $ImportsChanged = $true
      } else {
        $DartLines.Add($DartLine)
      }
    }
    if ($ImportsChanged) {
      [IO.File]::WriteAllLines($DartFile.FullName, $DartLines, [Text.UTF8Encoding]::new($false))
    }
  }

  # 模板固定产生的 unused 提示统一压制，追加规则幂等。
  $AoFile = Join-Path $OutDir 'analysis_options.yaml'
  $AoText = Get-Content $AoFile -Raw
  if ($AoText -notmatch 'unused_import') {
    Add-Content -Path $AoFile -Value "    unused_import: ignore`r`n    unused_element_parameter: ignore"
  }

  # built_value 的 .g.dart 与格式化结果均参与生成比较；失败也恢复调用方目录。
  Push-Location $OutDir
  try {
    # Pub 原生移除空模板测试的依赖，并解析生成客户端所需依赖。
    Write-Host '==> dart pub remove test'
    $PubArguments = @('pub', 'remove', 'test')
    if ($Offline) { $PubArguments += '--offline' }
    dart @PubArguments | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'dart pub remove test 失败' }
    Write-Host '==> dart run build_runner build'
    dart run build_runner build | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'build_runner 失败' }
    Write-Host '==> dart format lib'
    dart format lib | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'dart format 失败' }
  } finally {
    Pop-Location
  }

  foreach ($DocumentationRoot in @($OutDir, $Target)) {
    if ((Test-Path -LiteralPath (Join-Path $DocumentationRoot 'README.md')) -or
        (Test-Path -LiteralPath (Join-Path $DocumentationRoot 'doc'))) {
      throw ('Generated SDK documentation must be absent: ' + $DocumentationRoot)
    }
  }
  if ($Check) {
    # 仅比较生成器负责的文件，排除 pub/build_runner 产生的 .dart_tool、build、pubspec.lock。
    # --ignore-cr-at-eol 消除 Windows 检出 CRLF 与容器生成 LF 的行尾噪声。
    $GeneratedEntries = @(
      '.gitignore',
      '.openapi-generator',
      '.openapi-generator-ignore',
      'analysis_options.yaml',
      'lib',
      'pubspec.yaml'
    )
    $prevEAP = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $diff = @()
    $rc = 0
    foreach ($Entry in $GeneratedEntries) {
      $entryDiff = & git diff --no-index --stat --ignore-cr-at-eol (Join-Path $Target $Entry) (Join-Path $OutDir $Entry) 2>&1
      if ($LASTEXITCODE -ne 0) {
        $rc = 1
        $diff += $entryDiff
      }
    }
    $ErrorActionPreference = $prevEAP
    if ($rc -eq 0) {
      Write-Host '==> OK: 重新生成结果与当前工作树一致'
    } else {
      Write-Host '==> FAIL: 重新生成结果与当前工作树不一致：'
      $diff | Select-Object -First 60
      throw '生成结果不可重复，请检查是否手工改过生成代码或升级了依赖'
    }
  } else {
    if (-not $Preview) {
      # 生成成功才替换正式目录，缺工具或生成失败不会清空可用客户端。
      $null = Get-OpenApiOutputRelativePath -Root $Root -OutDir $Target -RunId $RunId
      $null = Get-OpenApiOutputRelativePath -Root $Root -OutDir $OutDir -RunId $RunId
      Assert-OpenApiNoLinks -Path $Target -Recurse
      Assert-OpenApiNoLinks -Path $OutDir -Recurse
      if (Test-Path -LiteralPath $Target) { Remove-Item -LiteralPath $Target -Recurse -Force }
      Move-Item -LiteralPath $OutDir -Destination $Target
    }
    Write-Host ('==> 完成: ' + $Target)
  }
  $GenerationCompleted = $true
} catch {
  Write-Error ('OpenAPI 客户端生成失败：' + $_.Exception.Message) -ErrorAction Continue
  throw
} finally {
  # Only this invocation's new workspaces are eligible for cleanup.
  if ($OwnedOutput -and (-not $Preview -or -not $GenerationCompleted) -and
      (Test-Path -LiteralPath $OutDir)) {
    $null = Get-OpenApiOutputRelativePath -Root $Root -OutDir $OutDir -RunId $RunId
    Assert-OpenApiNoLinks -Path $OutDir -Recurse
    Remove-Item -LiteralPath $OutDir -Recurse -Force
  }
  if ($OwnedInput -and (Test-Path -LiteralPath $NormalizedDirectory)) {
    Assert-OpenApiInputDirectory -Root $Root -Path $NormalizedDirectory -RunId $RunId
    Assert-OpenApiNoLinks -Path $NormalizedDirectory -Recurse
    Remove-Item -LiteralPath $NormalizedDirectory -Recurse -Force
  }
}
