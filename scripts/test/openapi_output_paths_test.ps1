#requires -Version 5.1
# Pure AST / virtual-filesystem checks: no generator, installation, or real deletion.
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
try {
  $ScriptPath = Join-Path $PSScriptRoot '../openapi/generate_api_client.ps1'
  $Tokens = $null
  $ParseErrors = $null
  $Ast = [Management.Automation.Language.Parser]::ParseFile($ScriptPath, [ref]$Tokens, [ref]$ParseErrors)
  if ($ParseErrors.Count) { throw ($ParseErrors | Out-String) }
  foreach ($Name in @('Assert-OpenApiRuntime', 'Get-OpenApiCanonicalPath', 'Assert-OpenApiNoLinks',
      'Get-OpenApiCheckedRelativePath', 'Get-OpenApiOutputRelativePath', 'Assert-OpenApiInputDirectory')) {
    $Function = $Ast.Find({ param($Node)
      $Node -is [Management.Automation.Language.FunctionDefinitionAst] -and $Node.Name -eq $Name
    }, $false)
    if ($null -eq $Function) { throw ('Missing safety function: ' + $Name) }
    . ([ScriptBlock]::Create($Function.Extent.Text))
  }
  $Windows = [Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT
  $Comparer = if ($Windows) { [StringComparer]::OrdinalIgnoreCase } else { [StringComparer]::Ordinal }
  $global:OpenApiSafetyVirtualItems = [Collections.Generic.Dictionary[string, object]]::new($Comparer)
  $global:OpenApiSafetyEvents = [Collections.Generic.List[string]]::new()
  function Test-Path { param([string]$LiteralPath) return $global:OpenApiSafetyVirtualItems.ContainsKey($LiteralPath) }
  function Get-Item { param([string]$LiteralPath, [switch]$Force) return $global:OpenApiSafetyVirtualItems[$LiteralPath] }
  function Get-ChildItem {
    param([string]$LiteralPath, [string]$Filter, [switch]$Force, [switch]$Recurse)
    foreach ($Item in $global:OpenApiSafetyVirtualItems.Values) {
      if ((Split-Path -Path $Item.FullName -Parent) -eq $LiteralPath -and
          (-not $Filter -or $Item.Name -like $Filter)) { $Item }
    }
  }
  function Add-VirtualItem {
    param([string]$Path, [switch]$File, [switch]$Link)
    $Attributes = if ($File) { [IO.FileAttributes]::Normal } else { [IO.FileAttributes]::Directory }
    if ($Link) { $Attributes = $Attributes -bor [IO.FileAttributes]::ReparsePoint }
    $global:OpenApiSafetyVirtualItems[$Path] = [pscustomobject]@{
      FullName = $Path; Name = (Split-Path -Path $Path -Leaf)
      PSIsContainer = -not $File; Attributes = $Attributes
      LinkType = $(if ($Link) { 'Junction' } else { $null })
    }
  }
  function Assert-Rejected {
    param([scriptblock]$Action, [string]$Label)
    $global:OpenApiSafetyChecks++
    $Rejected = $false
    try { & $Action | Out-Null } catch { $Rejected = $true }
    if (-not $Rejected) { throw ('Expected rejection: ' + $Label) }
  }
  $global:OpenApiSafetyChecks = 0
  Assert-OpenApiRuntime -Windows $true -Version ([version]'5.1')
  Assert-OpenApiRuntime -Windows $false -Version ([version]'7.0')
  Assert-Rejected { Assert-OpenApiRuntime -Windows $true -Version ([version]'7.6') } 'Windows PS7'
  Assert-Rejected { Assert-OpenApiRuntime -Windows $true -Version ([version]'5.0') } 'Windows PS5.0'
  Assert-Rejected { Assert-OpenApiRuntime -Windows $false -Version ([version]'6.0') } 'Unix PS6'
  $RunId = '0123456789abcdef0123456789abcdef'
  $Roots = if ($Windows) { @('C:\work\sesame notes mobile', 'C:\', '\\server\share\') }
    else { @('/home/runner/work/sesame-notes-mobile/sesame-notes-mobile', '/') }
  $Outputs = @('packages/sesame_api_client', "Temp/openapi-generation/preview/$RunId", "Temp/openapi-generation/check/$RunId")
  foreach ($Root in $Roots) {
    foreach ($Output in $Outputs) {
      $Expected = Join-Path $Root $Output
      $Candidates = @($Expected, ($Expected + [IO.Path]::DirectorySeparatorChar))
      if ($Windows) { $Candidates += $Expected.ToUpperInvariant(); $Candidates += $Expected.Replace('\', '/') }
      foreach ($Candidate in $Candidates) {
        $global:OpenApiSafetyChecks++
        $Actual = Get-OpenApiOutputRelativePath -Root $Root -OutDir $Candidate -RunId $RunId
        if ($Actual -cne $Output) { throw "Expected $Output, received $Actual" }
      }
    }
    $RejectedPaths = @($Root, (Join-Path $Root 'Temp'), (Join-Path $Root 'Temp/openapi_preview'),
      (Join-Path $Root 'Temp/openapi_check'), (Join-Path $Root 'packages/sesame_api_client-other'),
      (Join-Path $Root 'packages/sesame_api_client/lib'), (Join-Path $Root '../outside'),
      (Join-Path $Root 'Temp/openapi-generation/check/../preview'),
      (Join-Path $Root 'Temp/openapi-generation/check/ffffffffffffffffffffffffffffffff'))
    if ($Root -notin @('C:\', '/')) { $RejectedPaths += (Join-Path ($Root.TrimEnd('\', '/') + '-other') $Outputs[1]) }
    if ($Windows) { $RejectedPaths += 'D:\outside\packages\sesame_api_client' }
    else { $RejectedPaths += (Join-Path $Root ('TEMP/openapi-generation/check/' + $RunId)) }
    foreach ($Candidate in $RejectedPaths) {
      Assert-Rejected { Get-OpenApiOutputRelativePath -Root $Root -OutDir $Candidate -RunId $RunId } $Candidate
    }
  }
  $Root = $Roots[0]
  $Output = Join-Path $Root $Outputs[1]
  Assert-Rejected { Get-OpenApiOutputRelativePath -Root '.' -OutDir $Output -RunId $RunId } 'relative root'
  Assert-Rejected { Get-OpenApiOutputRelativePath -Root $Root -OutDir 'packages/sesame_api_client' -RunId $RunId } 'relative output'
  Assert-Rejected { Get-OpenApiOutputRelativePath -Root $Root -OutDir $Output -RunId '../other' } 'run traversal'
  $InputDirectory = Join-Path $Root "Temp/openapi-generation/input/$RunId"
  Assert-OpenApiInputDirectory -Root $Root -Path $InputDirectory -RunId $RunId
  Assert-Rejected { Assert-OpenApiInputDirectory -Root $Root -Path (Join-Path $Root 'Temp/openapi') -RunId $RunId } 'old input directory'
  foreach ($LinkedPath in @($Root, (Join-Path $Root 'Temp'), $Output)) {
    Add-VirtualItem -Path $LinkedPath -Link
    Assert-Rejected { Get-OpenApiOutputRelativePath -Root $Root -OutDir $Output -RunId $RunId } ('junction ' + $LinkedPath)
    $global:OpenApiSafetyVirtualItems.Clear()
  }
  $Target = Join-Path $Root 'packages/sesame_api_client'
  Add-VirtualItem -Path $Target
  Add-VirtualItem -Path (Join-Path $Target 'lib') -Link
  Assert-Rejected { Assert-OpenApiNoLinks -Path $Target -Recurse } 'SDK descendant link'
  $global:OpenApiSafetyVirtualItems.Clear()
  # Run the real entrypoint with all filesystem commands and external tools mocked.
  # Static file IO in generated Dart normalization has no inputs (the virtual lib is empty).
  function Resolve-Path { param([string]$Path) return [pscustomobject]@{ Path = $global:OpenApiSafetyFixtureRoot } }
  function New-Item {
    param([string]$ItemType, [string]$Path)
    if (Test-Path -LiteralPath $Path) { throw 'Workspace collision' }
    Add-VirtualItem -Path $Path
    $global:OpenApiSafetyEvents.Add('mkdir:' + $Path)
  }
  function Remove-Item {
    param([string]$LiteralPath, [switch]$Recurse, [switch]$Force)
    if ($LiteralPath -match '[\\/]Temp(?:[\\/]|$)' -and $LiteralPath -notmatch '[\\/]Temp[\\/]openapi-generation[\\/](input|preview|check)[\\/][a-f0-9]{32}$') { throw 'An unrelated temporary path was touched' }
    if ($LiteralPath -eq $global:OpenApiSafetyFixtureTarget -and -not $global:OpenApiSafetyBuildCompleted) { throw 'SDK removed before compilation' }
    $global:OpenApiSafetyEvents.Add('remove:' + $LiteralPath)
    $Prefix = $LiteralPath + [IO.Path]::DirectorySeparatorChar
    foreach ($Key in @($global:OpenApiSafetyVirtualItems.Keys)) {
      if ($Key -eq $LiteralPath -or $Key.StartsWith($Prefix)) { $null = $global:OpenApiSafetyVirtualItems.Remove($Key) }
    }
  }
  function Move-Item {
    param([string]$LiteralPath, [string]$Destination)
    if (-not $global:OpenApiSafetyBuildCompleted) { throw 'SDK moved before compilation' }
    $global:OpenApiSafetyEvents.Add('move:' + $Destination)
    $null = $global:OpenApiSafetyVirtualItems.Remove($LiteralPath)
    Add-VirtualItem -Path $Destination
  }
  function Get-Content {
    param([string]$LiteralPath, [switch]$Raw)
    if ($LiteralPath -like '*sesame-notes-api-v1.0.0.json') { return '{"info":{"version":"1.0.0"}}' }
    if ($LiteralPath -like '*analysis_options.yaml') { return 'unused_import: ignore' }
    throw ('Unexpected read: ' + $LiteralPath)
  }
  function Add-Content { throw 'Unexpected file write' }
  function Push-Location { param([string]$Path) }
  function Pop-Location { }
  function docker {
    $global:OpenApiSafetyEvents.Add('docker:' + $args[0])
    if ($args[0] -eq 'run') {
      if ($global:OpenApiSafetyScenario -eq 'offline' -and $args -notcontains '--pull=never') {
        throw 'Offline generation allowed an image download'
      }
      $MountIndex = [array]::IndexOf($args, '--mount')
      $InputIndex = [array]::IndexOf($args, '-i')
      $OutputIndex = [array]::IndexOf($args, '-o')
      if ($MountIndex -lt 0 -or $args[$MountIndex + 1] -cne ('type=bind,source=' + $global:OpenApiSafetyFixtureRoot + ',target=/local')) {
        throw 'Docker bind mount argument was split or changed'
      }
      if ($InputIndex -lt 0 -or $OutputIndex -lt 0 -or
          $args[$InputIndex + 1] -cnotmatch '^/local/Temp/openapi-generation/input/([a-f0-9]{32})/sesame-notes-normalized\.json$') {
        throw 'Docker normalized input argument escaped its allowlist'
      }
      $InputRun = $Matches[1]
      if ($args[$OutputIndex + 1] -cnotmatch '^/local/Temp/openapi-generation/(preview|check)/([a-f0-9]{32})$' -or
          $Matches[2] -cne $InputRun -or $args -notcontains 'openapitools/openapi-generator-cli:v7.24.0') {
        throw 'Docker output argument or pinned generator changed'
      }
    }
    $global:LASTEXITCODE = $(if (($args[0] -eq 'info' -and $global:OpenApiSafetyScenario -eq 'docker-failure') -or
      ($args[0] -eq 'run' -and $global:OpenApiSafetyScenario -eq 'generator-failure')) { 1 } else { 0 })
  }
  function node { $global:OpenApiSafetyEvents.Add('node'); $global:LASTEXITCODE = $(if ($global:OpenApiSafetyScenario -eq 'normalize-failure') { 1 } else { 0 }) }
  function id { '1000' }
  function dart {
    $Command = $args -join ' '
    if ($Command -notin @('pub remove test', 'pub remove test --offline', 'run build_runner build', 'format lib')) { throw 'Unexpected Dart arguments' }
    if ($global:OpenApiSafetyScenario -eq 'offline' -and $args[0] -eq 'pub' -and $args -notcontains '--offline') {
      throw 'Offline generation allowed dependency downloads'
    }
    if ($args[0] -eq 'run') {
      $global:OpenApiSafetyEvents.Add('build')
      $global:OpenApiSafetyBuildCompleted = $global:OpenApiSafetyScenario -notin @('build-failure', 'preview-build-failure')
      $global:LASTEXITCODE = $(if ($global:OpenApiSafetyBuildCompleted) { 0 } else { 1 })
    } elseif ($args[0] -eq 'format' -and $global:OpenApiSafetyScenario -eq 'format-failure') {
      $global:OpenApiSafetyEvents.Add('format-failure')
      $global:LASTEXITCODE = 1
    } else { $global:LASTEXITCODE = 0 }
  }
  function git {
    $global:OpenApiSafetyEvents.Add('diff')
    $global:LASTEXITCODE = $(if ($global:OpenApiSafetyScenario -eq 'check-diff-failure') { 1 } else { 0 })
  }
  $global:OpenApiSafetyFixtureRoot = $Root
  $global:OpenApiSafetyFixtureTarget = Join-Path $Root 'packages/sesame_api_client'
  foreach ($Scenario in @('docker-failure', 'normalize-failure', 'generator-failure', 'build-failure', 'format-failure', 'preview-build-failure', 'check-diff-failure', 'replace', 'offline', 'check', 'preview')) {
    $global:OpenApiSafetyScenario = $Scenario
    $global:OpenApiSafetyVirtualItems.Clear()
    $global:OpenApiSafetyEvents.Clear()
    $global:OpenApiSafetyBuildCompleted = $false
    Add-VirtualItem -Path $global:OpenApiSafetyFixtureTarget
    $Marker = Join-Path $global:OpenApiSafetyFixtureTarget 'keep.txt'
    Add-VirtualItem -Path $Marker -File
    Add-VirtualItem -Path (Join-Path $Root 'api/openapi/sesame-notes-api-v1.0.0.json') -File
    $Foreign = Join-Path $Root 'Temp/openapi-generation/check/ffffffffffffffffffffffffffffffff'
    Add-VirtualItem -Path $Foreign
    $Rejected = $false
    try {
      if ($Scenario -like 'check*') { & $ScriptPath -Check 2>$null }
      elseif ($Scenario -like 'preview*') { & $ScriptPath -Preview 2>$null }
      elseif ($Scenario -eq 'offline') { & $ScriptPath -Offline 2>$null }
      else { & $ScriptPath 2>$null }
    } catch { $Rejected = $true; $Failure = $_ }
    $ExpectedFailure = $Scenario.EndsWith('-failure')
    if ($Rejected -ne $ExpectedFailure) { throw ('Unexpected result for ' + $Scenario + ': ' + $Failure) }
    if ($Scenario -eq 'docker-failure' -and -not $global:OpenApiSafetyEvents.Contains('docker:info')) { throw 'Docker failure was not reached' }
    if ($Scenario -eq 'normalize-failure' -and -not $global:OpenApiSafetyEvents.Contains('node')) { throw 'Normalizer failure was not reached' }
    if ($Scenario -in @('build-failure', 'preview-build-failure') -and -not $global:OpenApiSafetyEvents.Contains('build')) { throw 'Build failure was not reached' }
    if ($Scenario -eq 'generator-failure' -and -not $global:OpenApiSafetyEvents.Contains('docker:run')) { throw 'Generator failure was not reached' }
    if ($Scenario -eq 'format-failure' -and -not $global:OpenApiSafetyEvents.Contains('format-failure')) { throw 'Formatter failure was not reached' }
    if ($Scenario -eq 'check-diff-failure' -and -not $global:OpenApiSafetyEvents.Contains('diff')) { throw 'Difference check was not reached' }
    if ($Scenario -notin @('replace', 'offline') -and -not (Test-Path -LiteralPath $Marker)) { throw 'Existing SDK was changed' }
    if (-not (Test-Path -LiteralPath $Foreign)) { throw 'A different run was removed' }
    $OwnWorkspaces = @($global:OpenApiSafetyVirtualItems.Keys | Where-Object { $_ -like '*openapi-generation*' -and $_ -ne $Foreign })
    if ($Scenario -eq 'preview') {
      if ($OwnWorkspaces.Count -ne 1 -or $OwnWorkspaces[0] -notlike '*openapi-generation*preview*') { throw 'Preview output was not preserved exactly' }
    } elseif ($OwnWorkspaces.Count -ne 0) { throw ('Workspaces leaked after ' + $Scenario) }
    if ($Scenario -in @('replace', 'offline') -and (-not $global:OpenApiSafetyEvents.Contains('remove:' + $global:OpenApiSafetyFixtureTarget) -or
        -not $global:OpenApiSafetyEvents.Contains('move:' + $global:OpenApiSafetyFixtureTarget))) { throw 'Successful generation did not replace the SDK' }
    $global:OpenApiSafetyChecks++
  }
  $global:OpenApiSafetyEvents.Clear()
  Assert-Rejected { & $ScriptPath -Preview -Check } 'mutually exclusive switches'
  if ($global:OpenApiSafetyEvents.Count -ne 0) { throw 'Invalid switches invoked tools or changed virtual files' }
  Write-Output "OpenAPI safety checks passed: $global:OpenApiSafetyChecks ($([Environment]::OSVersion.Platform)); virtual files only."
} catch {
  Write-Error $_
  exit 1
}
