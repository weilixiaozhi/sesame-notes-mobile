# 固定生成工作区的依赖与 Dart 版本，公共 SDK 的依赖范围由生成模板保持。

<#
.SYNOPSIS
校验生成所用 Dart SDK，避免格式化与代码生成受本机 SDK 漂移影响。
#>
function Assert-OpenApiGeneratorDartVersion {
  param([string]$Output, [string]$ExpectedVersion)
  try {
    if ($Output -notmatch '^Dart SDK version: ([0-9]+\.[0-9]+\.[0-9]+) \(stable\)' -or
        $Matches[1] -cne $ExpectedVersion) {
      throw ('生成要求 Dart ' + $ExpectedVersion + ' stable；实际版本：' + $Output.Trim())
    }
  } catch {
    throw ('Dart 生成工具版本校验失败：' + $_.Exception.Message)
  }
}

<#
.SYNOPSIS
以相同的 .NET 字节算法计算锁摘要，不依赖不同 PowerShell 版本的模块搜索路径。
#>
function Get-OpenApiGeneratorFileHash {
  param([string]$Path)
  $Stream = $null
  $Algorithm = $null
  try {
    $Stream = [IO.File]::OpenRead($Path)
    $Algorithm = [Security.Cryptography.SHA256]::Create()
    return [BitConverter]::ToString($Algorithm.ComputeHash($Stream)).Replace('-', '')
  } catch {
    throw ('生成依赖锁摘要读取失败：' + $_.Exception.Message)
  } finally {
    if ($null -ne $Stream) { $Stream.Dispose() }
    if ($null -ne $Algorithm) { $Algorithm.Dispose() }
  }
}

<#
.SYNOPSIS
只在本轮 Temp 生成目录内移除空模板测试依赖，并复制经过版本管理的完整依赖锁。
#>
function Initialize-OpenApiGeneratorDependencies {
  param([string]$Root, [string]$Directory, [string]$LockPath)
  try {
    $RootPath = [IO.Path]::GetFullPath($Root).TrimEnd([char[]]@('\', '/'))
    $WorkPath = [IO.Path]::GetFullPath($Directory).TrimEnd([char[]]@('\', '/'))
    $Comparison = if ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT) {
      [StringComparison]::OrdinalIgnoreCase
    } else { [StringComparison]::Ordinal }
    $Prefix = $RootPath + [IO.Path]::DirectorySeparatorChar
    if (-not $WorkPath.StartsWith($Prefix, $Comparison)) { throw '生成依赖目录超出仓库边界。' }
    $Relative = $WorkPath.Substring($Prefix.Length).Replace('\', '/')
    if ($Relative -cnotmatch '^Temp/openapi-generation/(?:check|preview)/[a-f0-9]{32}$') {
      throw '生成依赖只能准备到本轮独立 Temp 工作区。'
    }
    $Current = $WorkPath
    while ($Current) {
      if (Test-Path -LiteralPath $Current) {
        $Item = Get-Item -LiteralPath $Current -Force
        if (($Item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 -or $Item.LinkType) {
          throw ('生成依赖目录不能包含链接：' + $Current)
        }
      }
      $Current = Split-Path -Path $Current -Parent
    }
    $Manifest = Join-Path $WorkPath 'pubspec.yaml'
    $OutputLock = Join-Path $WorkPath 'pubspec.lock'
    if (Test-Path -LiteralPath $OutputLock) { throw '本轮依赖锁已存在，拒绝覆盖。' }
    $LockItem = Get-Item -LiteralPath $LockPath -Force
    if ($LockItem.PSIsContainer -or ($LockItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
      throw '生成依赖锁必须是版本化普通文件。'
    }
    $LockContent = [IO.File]::ReadAllText($LockItem.FullName).Replace("`r`n", "`n")
    if ($LockContent -notmatch '(?m)^packages:\s*$' -or
        $LockContent -notmatch '(?m)^  build_runner:\s*$' -or
        $LockContent -notmatch '(?m)^  built_value_generator:\s*$') {
      throw '生成依赖锁不完整，必须包含生成器及其传递依赖。'
    }
    $ManifestItem = Get-Item -LiteralPath $Manifest -Force
    if (($ManifestItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
      throw '生成依赖清单不能是链接。'
    }
    $Content = [IO.File]::ReadAllText($Manifest).Replace("`r`n", "`n")
    $Lines = $Content.Split([char]"`n")
    $Output = [Collections.Generic.List[string]]::new()
    $InDevelopment = $false
    $DevelopmentSections = 0
    $RemovedTests = 0
    foreach ($Line in $Lines) {
      if ($Line -match '^dev_dependencies:\s*$') {
        $InDevelopment = $true
        $DevelopmentSections++
      } elseif ($Line -match '^\S') {
        $InDevelopment = $false
      }
      # 只删除模板的独立 test 依赖，其他包、约束和非开发依赖保持原文。
      if ($InDevelopment -and $Line -match '^  test:\s*\S+\s*$') {
        $RemovedTests++
      } else {
        $Output.Add($Line)
      }
    }
    if ($DevelopmentSections -ne 1 -or $RemovedTests -gt 1) {
      throw '生成模板的开发依赖结构不符合预期，请审阅生成器版本。'
    }
    $Encoding = [Text.UTF8Encoding]::new($false)
    [IO.File]::WriteAllText($Manifest, ($Output -join "`n"), $Encoding)
    [IO.File]::WriteAllText($OutputLock, $LockContent, $Encoding)
    return Get-OpenApiGeneratorFileHash -Path $OutputLock
  } catch {
    throw ('生成依赖准备失败，正式 SDK 保持原样：' + $_.Exception.Message)
  }
}

<#
.SYNOPSIS
校验 Pub 和代码生成均未改写本轮固定依赖锁，发现漂移时拒绝发布生成结果。
#>
function Assert-OpenApiGeneratorLock {
  param([string]$Directory, [string]$ExpectedHash)
  try {
    $CurrentHash = Get-OpenApiGeneratorFileHash -Path (Join-Path $Directory 'pubspec.lock')
    if ($CurrentHash -cne $ExpectedHash) {
      throw '固定依赖锁发生变化，请显式审阅工具链升级；本轮结果不会替换正式 SDK。'
    }
  } catch {
    throw ('生成依赖锁校验失败：' + $_.Exception.Message)
  }
}
