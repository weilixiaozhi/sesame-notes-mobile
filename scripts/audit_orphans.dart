#!/usr/bin/env dart
// ignore_for_file: avoid_print

/// 孤儿/未接线扫描:找出「注册了但没有入口」的死代码候选。
///
/// 四类扫描(启发式,结果是候选清单,需人工确认;误报来源见各类注释):
/// 1. 死路由:Routes 常量在路由文件之外零引用(注册了但没人跳转);
/// 2. 孤儿页面:presentation 下的 *Page 类在自身文件之外零引用;
/// 3. 死文案键:app_en.arb 的键在 lib(不含 l10n)零引用;
/// 4. 未用 provider:lib 中声明的 Provider 在自身文件之外零引用。
///
/// 用法:dart scripts/audit_orphans.dart
library;

import 'dart:io';

const repoRoot = '.';
const libRoot = 'lib';

/// 递归收集目录下所有文件路径(相对仓库根)。
List<String> walk(String dir) {
  final out = <String>[];
  for (final e in Directory(dir).listSync(recursive: true)) {
    if (e is File && e.path.endsWith('.dart')) {
      out.add(e.path.replaceAll('\\', '/'));
    }
  }
  return out;
}

/// 统计 [needle] 在 [files] 中的出现次数(不含自身文件)。
int countRefs(String needle, List<String> files, {String? excludeSelf}) {
  var count = 0;
  for (final f in files) {
    if (excludeSelf != null && f == excludeSelf) continue;
    final text = File(f).readAsStringSync();
    count += RegExp(RegExp.escape(needle)).allMatches(text).length;
  }
  return count;
}

/// 输出分组清单。
void report(String title, List<String> items) {
  print('');
  print('== $title ==');
  if (items.isEmpty) {
    print('  (无)');
    return;
  }
  for (final i in items) {
    print('  $i');
  }
}

void main() {
  final allLib = walk(libRoot);

  // ---- 1. 死路由 ----
  // 提取 route_consts.dart 的 Routes 常量名与路径。
  const routeFile = '$libRoot/router/route_consts.dart';
  final routeText = File(routeFile).readAsStringSync();
  final constRe = RegExp(r"static const String (\w+) = '([^']+)'");
  final routeNames = <String, String>{};
  for (final m in constRe.allMatches(routeText)) {
    routeNames[m.group(1)!] = m.group(2)!;
  }
  final deadRoutes = <String>[];
  for (final e in routeNames.entries) {
    if (e.key == 'all') continue;
    final refs = countRefs(
      'Routes.${e.key}',
      allLib,
      excludeSelf: routeFile,
    );
    if (refs == 0) deadRoutes.add('${e.key} (${e.value})');
  }
  report('死路由:Routes 常量在路由文件之外零引用', deadRoutes);

  // ---- 2. 孤儿页面 ----
  final pageFiles = allLib
      .where((f) => f.contains('/presentation/') && f.endsWith('_page.dart'))
      .toList();
  final orphanPages = <String>[];
  for (final f in pageFiles) {
    final text = File(f).readAsStringSync();
    final m = RegExp(r'class (\w+Page) ').firstMatch(text);
    if (m == null) continue;
    final refs = countRefs(m.group(1)!, allLib, excludeSelf: f);
    if (refs == 0) orphanPages.add('${m.group(1)} ($f)');
  }
  report('孤儿页面:presentation 下 *Page 类在自身文件之外零引用', orphanPages);

  // ---- 3. 死文案键 ----
  // app_en.arb 为模板;提取顶层消息键(排除 @ 元数据)。
  final arbText = File('$libRoot/l10n/app_en.arb').readAsStringSync();
  final keyRe = RegExp(r'^    "(?![@\\"])[^"]+":', multiLine: true);
  final arbKeys = keyRe
      .allMatches(arbText)
      .map((m) => m.group(0)!.substring(5, m.group(0)!.length - 2))
      .toList();
  final codeFiles = allLib.where((f) => !f.startsWith('$libRoot/l10n/'));
  final deadKeys = <String>[];
  for (final k in arbKeys) {
    var refs = 0;
    for (final f in codeFiles) {
      refs += RegExp(RegExp.escape(k)).allMatches(
        File(f).readAsStringSync(),
      ).length;
    }
    if (refs == 0) deadKeys.add(k);
  }
  report('死文案键:app_en.arb 键在 lib(不含 l10n)零引用', deadKeys);

  // ---- 4. 未用 provider ----
  final providerRe = RegExp(
    r'final (\w+Provider) = (?:[A-Za-z0-9_<>.]+|FutureProvider[^;]+|Provider<[^>]+>\([^)]*\)|NotifierProvider[^;]+)',
  );
  final unusedProviders = <String>[];
  for (final f in allLib) {
    final text = File(f).readAsStringSync();
    for (final m in providerRe.allMatches(text)) {
      final name = m.group(1)!;
      // 引用总数含自身文件:仅剩声明行(1 次)才算未用。
      final refs = countRefs(name, allLib);
      if (refs <= 1) unusedProviders.add('$name ($f)');
    }
  }
  report('未用 provider:全 lib 仅剩声明行', unusedProviders);

  print('');
  print('提示:以上均为候选,请人工确认。误报常见原因:动态路由拼接、字符串键、测试专用注入。');
}
