import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { createHash, randomBytes } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, realpathSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '../..');
const helper = join(root, 'scripts/openapi/generator_dependencies.ps1');
const seed = join(root, 'scripts/openapi/generator.pubspec.lock');
const manifest = readFileSync(join(root, 'packages/sesame_api_client/pubspec.yaml'), 'utf8').replaceAll('\r\n', '\n');

/** 仅在独立的生成工作区内建立夹具，结束时核对身份后清理本次目录。 */
function fixture(run) {
  const parent = join(root, 'Temp/openapi-generation/check');
  mkdirSync(parent, { recursive: true });
  const directory = join(parent, randomBytes(16).toString('hex'));
  mkdirSync(directory);
  try {
    writeFileSync(join(directory, 'pubspec.yaml'), manifest);
    return run(directory);
  } finally {
    const actual = realpathSync(directory);
    assert.equal(dirname(actual), realpathSync(parent));
    assert.match(actual.slice(dirname(actual).length + 1), /^[a-f0-9]{32}$/);
    rmSync(actual, { recursive: true });
  }
}

/** 直接执行正式准备函数，不加载生成入口、不调用 Docker/Pub，也不连接网络。 */
function execute(directory, script, { lock = seed } = {}) {
  try {
    return spawnSync(process.platform === 'win32' ? 'powershell.exe' : 'pwsh', [
      '-NoProfile', '-Command',
      "$ErrorActionPreference='Stop'; [Console]::OutputEncoding=[Text.UTF8Encoding]::new($false); try { . $env:OPENAPI_TEST_HELPER; " + script +
      " } catch { [Console]::Error.WriteLine($_.Exception.ToString()); exit 1 }",
    ], {
      encoding: 'utf8', windowsHide: true,
      env: { ...process.env, OPENAPI_TEST_HELPER: helper, OPENAPI_TEST_ROOT: root,
        OPENAPI_TEST_DIRECTORY: directory, OPENAPI_TEST_LOCK: lock },
    });
  } catch (cause) {
    throw new Error('生成依赖测试进程启动失败，请检查 PowerShell。', { cause });
  }
}

const initialize = '$hash=Initialize-OpenApiGeneratorDependencies -Root $env:OPENAPI_TEST_ROOT -Directory $env:OPENAPI_TEST_DIRECTORY -LockPath $env:OPENAPI_TEST_LOCK;';

test('空模板测试依赖确定性移除，原依赖范围和完整锁输入保持', () => fixture((directory) => {
  try {
    const withTest = manifest.replace('dev_dependencies:\n', "dev_dependencies:\n  test: '^1.16.0'\n");
    writeFileSync(join(directory, 'pubspec.yaml'), withTest);
    const result = execute(directory, initialize + 'Assert-OpenApiGeneratorLock -Directory $env:OPENAPI_TEST_DIRECTORY -ExpectedHash $hash; Write-Output $hash');
    assert.equal(result.status, 0, result.stderr);
    assert.equal(readFileSync(join(directory, 'pubspec.yaml'), 'utf8'), manifest);
    const expected = readFileSync(seed, 'utf8').replaceAll('\r\n', '\n');
    assert.equal(readFileSync(join(directory, 'pubspec.lock'), 'utf8'), expected);
    assert.equal(result.stdout.trim(), createHash('sha256').update(expected).digest('hex').toUpperCase());
  } catch (cause) { throw new Error('固定依赖准备结果不符合预期。', { cause }); }
}));

test('已存在的本轮锁拒绝覆盖，清单和锁均保留原文', () => fixture((directory) => {
  try {
    writeFileSync(join(directory, 'pubspec.lock'), 'owned-lock\n');
    const result = execute(directory, initialize);
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /本轮依赖锁已存在/);
    assert.equal(readFileSync(join(directory, 'pubspec.lock'), 'utf8'), 'owned-lock\n');
    assert.equal(readFileSync(join(directory, 'pubspec.yaml'), 'utf8'), manifest);
  } catch (cause) { throw new Error('已有依赖锁保护未满足要求。', { cause }); }
}));

test('正式 SDK 目录不能作为依赖准备目标', () => {
  try {
    const directory = join(root, 'packages/sesame_api_client');
    const before = readFileSync(join(directory, 'pubspec.yaml'));
    const result = execute(directory, initialize);
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /生成依赖只能准备到本轮独立 Temp 工作区/);
    assert.deepEqual(readFileSync(join(directory, 'pubspec.yaml')), before);
  } catch (cause) { throw new Error('正式 SDK 目录保护未满足要求。', { cause }); }
});

test('锁被 Pub 或生成步骤改写时明确失败', () => fixture((directory) => {
  try {
    const result = execute(directory, initialize +
      'Add-Content -LiteralPath (Join-Path $env:OPENAPI_TEST_DIRECTORY pubspec.lock) -Value changed;' +
      'Assert-OpenApiGeneratorLock -Directory $env:OPENAPI_TEST_DIRECTORY -ExpectedHash $hash');
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /固定依赖锁发生变化/);
    assert.notEqual(readFileSync(join(directory, 'pubspec.lock'), 'utf8'), readFileSync(seed, 'utf8'));
  } catch (cause) { throw new Error('依赖锁漂移未被正确拒绝。', { cause }); }
}));

test('生成工具必须使用固定 stable Dart 版本', () => {
  try {
    const good = execute(root, "Assert-OpenApiGeneratorDartVersion -Output 'Dart SDK version: 3.13.2 (stable) (build)' -ExpectedVersion '3.13.2'");
    assert.equal(good.status, 0, good.stderr);
    for (const version of ['3.13.3 (stable)', '3.13.2 (beta)', '3.12.0 (stable)']) {
      const result = execute(root, "Assert-OpenApiGeneratorDartVersion -Output 'Dart SDK version: " + version + " (build)' -ExpectedVersion '3.13.2'");
      assert.notEqual(result.status, 0, version);
      assert.match(result.stderr, /生成要求 Dart 3\.13\.2 stable/);
    }
  } catch (cause) { throw new Error('Dart 版本保护未满足要求。', { cause }); }
});

test('不完整工具锁在写入工作区前失败', () => fixture((directory) => {
  try {
    const badLock = join(directory, 'incomplete.lock');
    writeFileSync(badLock, 'packages:\n  build_runner:\n    version: "2.16.2"\n');
    const result = execute(directory, initialize, { lock: badLock });
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /生成依赖锁不完整/);
    assert.equal(existsSync(join(directory, 'pubspec.lock')), false);
    assert.equal(readFileSync(join(directory, 'pubspec.yaml'), 'utf8'), manifest);
  } catch (cause) { throw new Error('不完整生成工具锁未被正确拒绝。', { cause }); }
}));
