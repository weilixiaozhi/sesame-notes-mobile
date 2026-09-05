#!/usr/bin/env dart
// ignore_for_file: avoid_print

/// 孤儿/未接线扫描:找出「注册了但没有入口」的死代码候选。
///
/// 四类扫描(启发式,结果是候选清单,需人工确认;误报来源见各类注释):
/// 1. 死路由:Routes 常量在路由文件之外零引用(注册了但没人跳转);
/// 2. 孤儿页面:presentation 下的 *Page 类在自身文件之外零引用;
/// 3. 未用 provider:lib 中声明的 Provider 全库仅剩声明行;
/// 4. 未用公共方法:Repository/Service/Actions/Coordinator 类的公共方法在
///    自身文件之外零引用(如「有实现有测试但生产从不调用」的 P0 死代码)。
///
/// 注意:l10n 未使用/多余键的检查与清理由 scripts/i18n/check_status.dart 负责,
/// 本脚本不做文案扫描,避免重复。
///
/// 用法:dart scripts/audit/orphans.dart
library;

import 'dart:io';

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
    final refs = countRefs('Routes.${e.key}', allLib, excludeSelf: routeFile);
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

  // ---- 3. 未用 provider ----
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

  // ---- 4. 未用公共方法 ----
  // 只扫数据/编排层的类:这些类的公共方法若全库无人调用,大概率是
  // 「有实现有测试、生产从不接线」的死代码(如未接线的 purge 编排)。
  final targetClassRe = RegExp(
    r'class \w+(Repository|Service|Actions|Coordinator)\s',
  );
  final methodRe = RegExp(
    r'^\s{2}(?:static\s+)?(?:Future<\S+>|Future|void|bool|String|int|double|File|Uint8List|Stream<\S+>)\s+(\w+)\s*\(',
    multiLine: true,
  );
  final deadMethods = <String>[];
  for (final f in allLib) {
    if (f.endsWith('.g.dart')) continue;
    final text = File(f).readAsStringSync();
    if (!targetClassRe.hasMatch(text)) continue;
    for (final m in methodRe.allMatches(text)) {
      final name = m.group(1)!;
      if (name.startsWith('_')) continue;
      // 引用总数含自身文件:仅剩声明行(1 次)才算死代码,
      // 类内部自用的静态/私有辅助方法不会被误报。
      final refs = countRefs(name, allLib);
      if (refs <= 1) deadMethods.add('$name ($f)');
    }
  }
  report(
    '未用公共方法:Repository/Service/Actions/Coordinator 方法在自身文件外零引用',
    deadMethods,
  );

  print('');
  print('提示:以上均为候选,请人工确认。误报常见原因:动态路由拼接、测试专用注入、接口动态分发、字符串键。');
}
