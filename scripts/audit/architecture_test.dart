// ignore_for_file: avoid_print

/// 使用隔离Dart夹具验证审计语义，不构建Flutter或访问设备。
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'architecture.dart';

/// 断言失败保留需求说明，避免进程成功掩盖工具误判。
void require(bool condition, String message) {
  if (!condition) throw StateError(message);
}

/// 只在本次夹具目录写入源码，生产仓库文件保持只读。
void writeFixture(Directory root, String relative, String content) {
  final file = File(p.join(root.path, relative));
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(content);
}

/// 定位准确的声明身份，不能用同名成员的文本命中代替符号消费。
String declarationKey(ArchitectureAudit audit, String file, String name) =>
    audit.declarations.entries
        .singleWhere(
          (entry) => entry.value['file'] == file && entry.value['name'] == name,
        )
        .key;

/// 夹具覆盖package/export/show-hide、生成part、命名extension和同名符号。
Future<void> main() async {
  Directory? fixture;
  final temp = Directory(p.join(Directory.current.path, 'Temp'));
  try {
    temp.createSync(recursive: true);
    fixture = temp.createTempSync('architecture-audit-test-');
    // 让rg把夹具视为独立源码树，不继承仓库对Temp的忽略规则。
    Directory(p.join(fixture.path, '.git')).createSync();
    writeFixture(
      fixture,
      'pubspec.yaml',
      'name: fixture_app\nenvironment:\n  sdk: ^3.12.0\n',
    );
    writeFixture(
      fixture,
      '.dart_tool/package_config.json',
      jsonEncode({
        'configVersion': 2,
        'packages': [
          {
            'name': 'fixture_app',
            'rootUri': '../',
            'packageUri': 'lib/',
            'languageVersion': '3.12',
          },
          {
            'name': 'fixture_core',
            'rootUri': '../packages/core',
            'packageUri': 'lib/',
            'languageVersion': '3.12',
          },
        ],
      }),
    );
    writeFixture(
      fixture,
      'packages/core/lib/api.dart',
      "export 'src/types.dart' show Alpha;",
    );
    writeFixture(
      fixture,
      'packages/core/lib/src/types.dart',
      'class Alpha {}\nclass Hidden {}',
    );
    writeFixture(
      fixture,
      'lib/barrel.dart',
      "export 'extension.dart' show Times, Hidden;\n"
          "export 'export_stub.dart' if (dart.library.io) 'export_io.dart' show Exported;",
    );
    writeFixture(fixture, 'lib/export_stub.dart', 'class Exported {}');
    writeFixture(fixture, 'lib/export_io.dart', 'class Exported {}');
    writeFixture(
      fixture,
      'lib/extension.dart',
      'extension Times on int { int get scaled => this * 2; }\nclass Hidden {}',
    );
    writeFixture(
      fixture,
      'lib/same_a.dart',
      'class SameName { int used() => 1; }',
    );
    writeFixture(
      fixture,
      'lib/same_b.dart',
      'class SameName { int used() => 2; }',
    );
    writeFixture(
      fixture,
      'lib/state.dart',
      "part 'state.g.dart';\nint handwrittenByGenerated() => 1;",
    );
    writeFixture(
      fixture,
      'lib/state.g.dart',
      "part of 'state.dart';\nint generatedValue() => handwrittenByGenerated();",
    );
    writeFixture(
      fixture,
      'lib/named_owner.dart',
      "library fixture.named;\npart 'named_part.dart';",
    );
    writeFixture(
      fixture,
      'lib/named_part.dart',
      'part of fixture.named;\nint namedValue() => 1;',
    );
    writeFixture(
      fixture,
      'lib/platform_stub.dart',
      'int platformValue() => 0;',
    );
    writeFixture(fixture, 'lib/platform_io.dart', 'int platformValue() => 1;');
    writeFixture(fixture, 'lib/中文.dart', 'int chineseValue() => 7;');
    writeFixture(
      fixture,
      'lib/native_entry.dart',
      "@pragma('vm:entry-point')\nvoid backgroundEntry() {}",
    );
    writeFixture(fixture, 'lib/main.dart', '''
import 'package:fixture_core/api.dart' show Alpha;
import 'barrel.dart' hide Hidden;
import 'same_a.dart' as first;
import 'same_b.dart' as second;
import 'platform_stub.dart' if (dart.library.io) 'platform_io.dart';
import 'state.dart';
import '中文.dart';
void main() {
  Alpha();
  Exported();
  first.SameName().used();
  print(2.scaled);
  print(generatedValue());
  print(platformValue());
  print(chineseValue());
}
''');
    final before = {
      for (final file in fixture.listSync(recursive: true).whereType<File>())
        file.path: file.readAsBytesSync(),
    };
    final audit = ArchitectureAudit(fixture.path, symbols: true);
    final report = await audit.run();
    require(
      (report['analysisFailures'] as List).isEmpty,
      '完整夹具必须解析成功：${report['analysisFailures']}',
    );
    require(report['symbolAnalysisComplete'] == true, '符号分析完成标记必须对应完整解析');
    require((report['boundaryViolations'] as List).isEmpty, '合法依赖不能误判边界');
    require((report['libraryScc'] as List).isEmpty, '生成part组成关系不能成为普通SCC');
    require(audit.parts['lib/state.g.dart'] == 'lib/state.dart', '必须归并生成part');
    require(
      audit.edges.any((edge) => edge.to == 'packages/core/lib/api.dart'),
      'package名必须通过package_config映射至目录名不同的本地包',
    );
    require(
      audit.edges.any(
        (edge) => edge.conditional && edge.to == 'lib/platform_io.dart',
      ),
      '条件导入必须保留所有分支',
    );
    require(
      audit.edges.any(
        (edge) =>
            edge.kind == 'export' &&
            edge.conditional &&
            edge.to == 'lib/export_io.dart',
      ),
      '条件导出必须保留所有分支及公共出口',
    );
    require(
      (audit.consumers[declarationKey(
                audit,
                'lib/state.dart',
                'handwrittenByGenerated',
              )] ??
              {})
          .contains('lib/state.g.dart'),
      '生成part必须计入手写声明消费者',
    );
    require(
      (audit.consumers[declarationKey(audit, 'lib/中文.dart', 'chineseValue')] ??
              {})
          .contains('lib/main.dart'),
      'UTF8源码路径必须正确枚举、解析和归一化',
    );
    require(
      (audit.consumers[declarationKey(audit, 'lib/extension.dart', 'scaled')] ??
              {})
          .contains('lib/main.dart'),
      'show/export后的命名extension调用必须被识别',
    );
    require(
      (audit.consumers[declarationKey(audit, 'lib/extension.dart', 'Times')] ??
                  {})
              .contains('lib/main.dart') &&
          !(report['symbolCandidates'] as List).any(
            (entry) => (entry as Map)['name'] == 'Times',
          ),
      '隐式成员调用必须消费所属extension，不能把活跃扩展列为零消费候选',
    );
    require(
      (audit.consumers[declarationKey(audit, 'lib/same_a.dart', 'used')] ?? {})
          .contains('lib/main.dart'),
      '必须识别实际调用的同名成员',
    );
    require(
      (audit.consumers[declarationKey(audit, 'lib/same_b.dart', 'used')] ?? {})
          .isEmpty,
      '同名文本不能给未消费声明制造调用',
    );
    require(
      (audit.consumers[declarationKey(audit, 'lib/extension.dart', 'Hidden')] ??
              {})
          .isEmpty,
      'export/show/hide命名空间组合子不能算执行消费者',
    );
    require(
      !(report['symbolCandidates'] as List).any(
        (entry) => (entry as Map)['name'] == 'backgroundEntry',
      ),
      '原生入口注解不能作为零消费者精简候选',
    );
    for (final entry in before.entries) {
      require(
        base64Encode(File(entry.key).readAsBytesSync()) ==
            base64Encode(entry.value),
        '审计不得改写源码：${entry.key}',
      );
    }
    require(
      stronglyConnectedComponents({
            'a': {'b'},
            'b': {'a'},
            'c': {},
          }).single.join(',') ==
          'a,b',
      'Tarjan必须报告真实跨library循环',
    );
    writeFixture(
      fixture,
      'lib/state.g.dart',
      "part of 'wrong.dart';\nint generatedValue() => handwrittenByGenerated();",
    );
    final wrongUri = await ArchitectureAudit(fixture.path).run();
    require(
      wrongUri['analysisComplete'] == false &&
          (wrongUri['analysisFailures'] as List).isNotEmpty,
      '快速模式必须拒绝URI归属错误的part of',
    );
    writeFixture(
      fixture,
      'lib/state.g.dart',
      "part of 'state.dart';\nint generatedValue() => handwrittenByGenerated();",
    );
    writeFixture(fixture, 'lib/named_part.dart', 'part of wrong.library;');
    final wrongName = await ArchitectureAudit(fixture.path).run();
    require(
      wrongName['analysisComplete'] == false &&
          (wrongName['analysisFailures'] as List).isNotEmpty,
      '快速模式必须拒绝名称归属错误的part of',
    );
    writeFixture(
      fixture,
      'lib/named_part.dart',
      'part of fixture.named;\nint namedValue() => 1;',
    );
    final restored = await ArchitectureAudit(fixture.path).run();
    require(restored['analysisComplete'] == true, '合法URI和命名part不得被误报');
    writeFixture(fixture, 'lib/orphan.dart', "part of 'missing_owner.dart';");
    final orphan = await ArchitectureAudit(fixture.path).run();
    require(orphan['analysisComplete'] == false, '孤立part必须使快速分析失败');
    File(p.join(fixture.path, 'lib/orphan.dart')).deleteSync();
    writeFixture(fixture, 'lib/state.g.dart', 'int generatedValue() => 1;');
    final missingDeclaration = await ArchitectureAudit(fixture.path).run();
    require(
      missingDeclaration['analysisComplete'] == false,
      'part目标缺少part of时必须使快速分析失败',
    );
    writeFixture(
      fixture,
      'lib/state.g.dart',
      "part of 'state.dart';\nint generatedValue() => handwrittenByGenerated();",
    );
    writeFixture(
      fixture,
      'lib/core/forbidden.dart',
      "import 'package:fixture_app/shared/domain/choice.dart';",
    );
    writeFixture(fixture, 'lib/shared/domain/choice.dart', 'const choice = 1;');
    final invalid = await ArchitectureAudit(fixture.path).run();
    require(
      (invalid['boundaryViolations'] as List).any(
        (entry) =>
            (entry as Map)['rule'].toString().startsWith('CORE_DIRECTION'),
      ),
      '明确反向边必须失败，不能用候选数白名单掩盖',
    );
    writeFixture(fixture, 'lib/broken.dart', 'void broken( {');
    final incomplete = await ArchitectureAudit(fixture.path).run();
    require(
      (incomplete['analysisFailures'] as List).isNotEmpty,
      '语法不完整时不能把部分结果报告为完整通过',
    );
    require(incomplete['analysisComplete'] == false, '部分分析不能标记为完整完成');
    final emptyRoot = Directory(p.join(fixture.path, 'empty'))..createSync();
    Directory(p.join(emptyRoot.path, 'lib')).createSync();
    final emptyRun = Process.runSync(
      Platform.resolvedExecutable,
      [p.join(Directory.current.path, 'scripts/audit/architecture.dart')],
      workingDirectory: emptyRoot.path,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    require(
      emptyRun.exitCode == 2 &&
          (emptyRun.stderr as String).contains('没有可审计的Dart源码'),
      '空源码覆盖必须以退出码2失败，不能输出空报告冒充通过：${emptyRun.stderr}',
    );
    print('架构审计语义夹具通过：生成part、package、条件分支、show/hide、extension、同名符号、只读性及边界。');
  } catch (error, stack) {
    stderr.writeln('架构审计回归失败：工具实现或夹具与语言语义不一致，请查看诊断。\n$error\n$stack');
    exitCode = 1;
  } finally {
    if (fixture != null) {
      try {
        final absolute = p.normalize(fixture.absolute.path);
        if (!p.isWithin(p.normalize(temp.absolute.path), absolute)) {
          throw StateError('拒绝清理Temp之外的夹具目录');
        }
        fixture.deleteSync(recursive: true);
      } catch (error, stack) {
        stderr.writeln('清理本次架构审计夹具失败，请保留诊断。\n$error\n$stack');
        exitCode = 1;
      }
    }
  }
}
