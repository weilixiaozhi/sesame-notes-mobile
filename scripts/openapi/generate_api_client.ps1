# 生成 / 校验 Sesame Notes Dart API 客户端（dart-dio）。
#
# 用法（仓库根目录执行）：
#   powershell -File scripts/openapi/generate_api_client.ps1 -Preview   # 预览：输出到 build/openapi_preview（git 忽略）
#   powershell -File scripts/openapi/generate_api_client.ps1           # 正式：输出到 packages/sesame_api_client（提交）
#   powershell -File scripts/openapi/generate_api_client.ps1 -Check    # 可重复校验：临时目录重新生成 + build_runner，
#                                                                       # 与已提交输出 diff，不一致则退出码非 0
#
# 设计意图：
# - 生成器镜像 tag 固定（OpenAPI Generator CLI 7.24.0），杜绝静默跟随上游模板变化；
# - 生成代码不手工编辑：任何对 lib/ 的手改都会在 -Check 时暴露；
# - 枚举/空值规范化（normalize_openapi.mjs）把后端 TypeBox 的 anyOf 单值枚举与纯 null
#   表达收敛为 dart-dio 可消费的标准 enum / nullable，冻结契约文件本身不被修改；
# - build_runner 产物（.g.dart）参与生成结果比较，防止生成代码漂移。
param(
  [switch]$Preview,
  [switch]$Check
)

$ErrorActionPreference = 'Stop'

# 固定版本：官方 dart-dio 生成器。升级必须显式改这里并重跑 -Check。
$Image = 'openapitools/openapi-generator-cli:v7.24.0'
$SpecRel = 'api/openapi/sesame-notes-api-v1.0.0.json'

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$Spec = Join-Path $Root $SpecRel
if (-not (Test-Path $Spec)) { throw 'OpenAPI 文件不存在: ' + $Spec }

$Target = if ($Preview) { Join-Path $Root 'build/openapi_preview' } else { Join-Path $Root 'packages/sesame_api_client' }
$OutDir = $Target

# -Check：输出到仓库内临时目录（须在挂载根之下，且被 git 忽略），随后与正式目录 diff
if ($Check) {
  $OutDir = Join-Path $Root 'build/openapi_check'
}

# 容器内路径：挂载仓库根到 /local，输出目录必须是 /local 下相对路径
$OutRel = $OutDir.Substring($Root.Length).TrimStart('\').Replace('\', '/')

# 生成器不会主动删除已从契约移除的文件，因此每次都从空目录开始。
# 只允许清理三个固定输出目录，并校验其绝对路径仍位于仓库内，避免路径计算错误扩大删除范围。
$RootPrefix = $Root.TrimEnd('\') + '\'
$OutDirPath = [IO.Path]::GetFullPath($OutDir)
$AllowedOutDirs = @(
  [IO.Path]::GetFullPath((Join-Path $Root 'packages/sesame_api_client')),
  [IO.Path]::GetFullPath((Join-Path $Root 'build/openapi_preview')),
  [IO.Path]::GetFullPath((Join-Path $Root 'build/openapi_check'))
)
if (-not $OutDirPath.StartsWith($RootPrefix, [StringComparison]::OrdinalIgnoreCase) -or
    $AllowedOutDirs -notcontains $OutDirPath) {
  throw ('拒绝清理非预期 OpenAPI 输出目录: ' + $OutDirPath)
}
if (Test-Path -LiteralPath $OutDir) {
  Remove-Item -LiteralPath $OutDir -Recurse -Force
}

# 1) 规范化枚举/空值表达（确定性，见 normalize_openapi.mjs 头部注释）
Write-Host '==> normalize_openapi.mjs'
node (Join-Path $Root 'scripts/openapi/normalize_openapi.mjs') $Spec (Join-Path $Root 'build/openapi/sesame-notes-normalized.json')
if ($LASTEXITCODE -ne 0) { throw 'normalize_openapi 失败' }

# 2) 用固定版本生成器生成 dart-dio 客户端
Write-Host ('==> openapi-generator ' + $Image + ' -> ' + $OutRel)
$Mount = 'type=bind,source=' + $Root + ',target=/local'
docker run --rm --mount $Mount $Image generate --skip-validate-spec -i '/local/build/openapi/sesame-notes-normalized.json' -g dart-dio -o ('/local/' + $OutRel) --additional-properties pubName=sesame_api_client,pubLibrary=sesame_api_client,pubDescription=Sesame%20Notes%20v1%20OpenAPI%20client,pubVersion=1.0.0
if ($LASTEXITCODE -ne 0) { throw 'openapi-generator 失败' }

# 3) 生成代码的 lint 噪音（unused_import / unused_element_parameter）由模板固定产生，
#    统一压制，保证 dart analyze 干净。追加规则幂等。
$AoFile = Join-Path $OutDir 'analysis_options.yaml'
$AoText = Get-Content $AoFile -Raw
if ($AoText -notmatch 'unused_import') {
  Add-Content -Path $AoFile -Value "    unused_import: ignore`r`n    unused_element_parameter: ignore"
}

# 3) 解析依赖并生成 built_value 实现（.g.dart），随后统一格式化生成代码：
#    - dart-dio 模板产出的模型是 built_value 抽象类（part 'xxx.g.dart'; + factory = _$Xxx），
#      缺 .g.dart 无法编译；build_runner 产物会纳入 -Check 比较。
#    - 生成器原始输出不保证 dart format 合规，统一格式化使提交产物通过 CI 格式检查，
#      同时保证 -Check 与已提交输出逐字节一致。
Push-Location $OutDir
Write-Host '==> dart pub get'
dart pub get | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'dart pub get 失败' }
Write-Host '==> dart run build_runner build'
dart run build_runner build | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'build_runner 失败' }
Write-Host '==> dart format lib test'
dart format lib test | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'dart format 失败' }
Pop-Location

if ($Check) {
  try {
    # 仅比较生成器负责的文件，排除 pub/build_runner 产生的 .dart_tool、build、pubspec.lock。
    # --ignore-cr-at-eol 消除 Windows 检出 CRLF 与容器生成 LF 的行尾噪声。
    $GeneratedEntries = @(
      '.gitignore',
      '.openapi-generator',
      '.openapi-generator-ignore',
      'analysis_options.yaml',
      'doc',
      'lib',
      'pubspec.yaml',
      'README.md',
      'test'
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
      Write-Host '==> OK: 重新生成结果与已提交输出一致（可重复）'
    } else {
      Write-Host '==> FAIL: 重新生成结果与已提交输出不一致：'
      $diff | Select-Object -First 60
      throw '生成结果不可重复，请检查是否手工改过生成代码或升级了依赖'
    }
  } finally {
    if (Test-Path -LiteralPath $OutDir) {
      Remove-Item -LiteralPath $OutDir -Recurse -Force
    }
  }
} else {
  Write-Host ('==> 完成: ' + $Target)
}
