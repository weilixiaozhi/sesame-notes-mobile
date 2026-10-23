import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '../..');
const read = file => readFileSync(resolve(root, file), 'utf8');
const test = JSON.parse(read('config/test.example.json'));
const prod = JSON.parse(read('config/prod.example.json'));
assert.equal(test.APP_ENV, 'test');
assert.equal(test.API_BASE_URL, '');
assert.equal(test.UPDATE_MANIFEST_URL, '');
assert.equal(prod.APP_ENV, 'prod');
assert.equal(prod.API_BASE_URL, '');
assert.equal(prod.UPDATE_MANIFEST_URL, '');
const gradle = read('android/app/build.gradle');
assert.match(gradle, /applicationId = "com\.sesame\.notes"/);
assert.match(gradle, /applicationIdSuffix = "\.test"/);
assert.match(gradle, /if \(!\(compileEnvironment in \['test', 'prod'\]\)\)/);
assert.match(gradle, /APP_ENV does not match the requested Android flavor/);
assert.match(gradle, /task\.contains\('envtestprobe'\) && compileEnvironment != 'test'/);
assert.match(gradle, /applicationIdSuffix = "\.test\.probe"/);
assert.doesNotMatch(gradle, /daysqa\s*\{/);
const probe = read('e2e/day_profile_probe.dart');
const guardIndex = probe.indexOf("package.packageName != 'com.sesame.notes.test.probe'");
assert(guardIndex >= 0 && guardIndex < probe.indexOf('getApplicationDocumentsDirectory()'));
assert.match(probe, /AppEnvironment\.name != 'test'/);
const workflow = read('.github/workflows/release.yml');
assert.match(workflow, /APP_NAME: "Sesame-Notes-prod"/);
assert.match(workflow, /build\/prod\/\$\{\{ env\.APP_NAME \}\}-\*\.apk/);
assert.match(workflow, /build\/prod\/update\.prod\.json/);
assert.match(workflow, /build_android\.ps1 -Environment prod/);
assert.match(workflow, /secrets\.API_BASE_URL/);
assert.match(workflow, /secrets\.UPDATE_MANIFEST_URL/);
assert.match(workflow, /-ConfigPath Temp\/release-config\.json -ValidateOnly/);
for (const file of [
  'lib/features/settings/infrastructure/app_update_service.dart',
  'android/app/src/main/kotlin/com/sesame/notes/AppUpdateDownloads.kt',
  'android/app/src/main/kotlin/com/sesame/notes/AppUpdateInstaller.kt',
]) {
  assert(read(file).includes('com.sesame.notes'), file + ' lost production package identity');
}
const manifest = read('scripts/generate_update_manifest.py');
assert(manifest.includes('expected_name = f"Sesame-Notes-prod-v{name}.apk"'));
assert(manifest.includes('apk.name != expected_name'));
assert(manifest.includes('"packageName": "com.sesame.notes"'));
assert(manifest.includes('/v{name}/{apk.name}'));
console.log('Environment configuration and published identity checks passed.');
