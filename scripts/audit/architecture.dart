// ignore_for_file: avoid_print

/// 只读架构审计：编译依赖、语言单元循环、明确边界及符号消费候选。
library;

import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:path/path.dart' as p;

/// URI边保留组合子和条件分支，不能解释为运行时调用。
class AuditEdge {
  /// 来源及目标均为归一化仓库路径，外部依赖保留原始URI。
  const AuditEdge({
    required this.from,
    required this.to,
    required this.kind,
    required this.line,
    required this.directive,
    this.conditional = false,
  });

  final String from, to, kind, directive;
  final int line;
  final bool conditional;

  /// JSON结构保留准确指令，便于人工核对show/hide和条件分支。
  Map<String, Object?> toJson() => {
    'from': from,
    'to': to,
    'kind': kind,
    'line': line,
    'directive': directive,
    'conditional': conditional,
  };
}

/// 基于职责而非现有违规数量定义边界，不接受按候选数压制的白名单。
String? boundaryViolation(AuditEdge edge) {
  final from = edge.from, to = edge.to;
  if (edge.kind == 'part') return null;
  if (from.startsWith('lib/core/') &&
      (to.startsWith('lib/features/') ||
          to.startsWith('lib/shared/') ||
          to.startsWith('lib/infrastructure/') ||
          to.startsWith('lib/providers/'))) {
    return 'CORE_DIRECTION: core不得依赖业务、共享装配或基础设施实现';
  }
  if (from.startsWith('lib/infrastructure/api/') &&
      (to.startsWith('lib/shared/') || to.startsWith('lib/features/'))) {
    return 'API_DIRECTION: API传输装配不得反向读取共享/业务Provider';
  }
  if (from == 'lib/shared/providers/app_bootstrap_providers.dart' &&
      (to.startsWith('lib/features/') || to.startsWith('lib/providers/'))) {
    return 'BOOTSTRAP_PORT: 启动端口不得依赖顶层实现或业务模块';
  }
  if (from.startsWith('lib/shared/domain/') &&
      (to.startsWith('lib/features/') ||
          to.startsWith('lib/infrastructure/') ||
          to.startsWith('lib/shared/providers/'))) {
    return 'SHARED_DOMAIN: 共享领域规则不得依赖业务实现或状态装配';
  }
  if ((from.startsWith('lib/domain/') ||
          RegExp(r'^lib/features/[^/]+/domain/').hasMatch(from)) &&
      (to.contains('/presentation/') ||
          to.contains('/application/') ||
          to.startsWith('lib/shared/providers/'))) {
    return 'DOMAIN_DIRECTION: 领域规则不得依赖界面、用例或状态装配';
  }
  if (from.startsWith('packages/sesame_cloud_backup/lib/') &&
      (to.startsWith('lib/') ||
          RegExp(
            r'^packages/sesame_cloud_backup_(s3|supabase|webdav)/',
          ).hasMatch(to))) {
    return 'BACKUP_CORE: 云备份核心不得依赖应用或具体服务商适配器';
  }
  return null;
}

/// Tarjan按语言单元求非平凡SCC，目录聚合环另行报告。
List<List<String>> stronglyConnectedComponents(Map<String, Set<String>> graph) {
  var next = 0;
  final indices = <String, int>{}, low = <String, int>{};
  final stack = <String>[], active = <String>{};
  final components = <List<String>>[];

  /// 回溯最低序号，part组成关系在调用前已经归并。
  void visit(String node) {
    indices[node] = next;
    low[node] = next++;
    stack.add(node);
    active.add(node);
    for (final target in graph[node] ?? <String>{}) {
      if (!indices.containsKey(target)) {
        visit(target);
        if (low[target]! < low[node]!) low[node] = low[target]!;
      } else if (active.contains(target) && indices[target]! < low[node]!) {
        low[node] = indices[target]!;
      }
    }
    if (low[node] != indices[node]) return;
    final component = <String>[];
    String member;
    do {
      member = stack.removeLast();
      active.remove(member);
      component.add(member);
    } while (member != node);
    if (component.length > 1 || (graph[node]?.contains(node) ?? false)) {
      components.add(component..sort());
    }
  }

  for (final node in graph.keys.toList()..sort()) {
    if (!indices.containsKey(node)) visit(node);
  }
  return components..sort((a, b) => a.first.compareTo(b.first));
}

/// 归一化URI，package映射取实际package_config而非猜测目录名。
String resolveAuditUri(
  String root,
  String from,
  String uri,
  Map<String, String> packageLibraries,
) {
  if (uri.startsWith('dart:')) return uri;
  final parsed = Uri.parse(uri);
  String absolute;
  if (parsed.scheme == 'package') {
    final segments = parsed.pathSegments;
    final library = packageLibraries[segments.first];
    if (library == null) return uri;
    absolute = p.normalize(p.joinAll([library, ...segments.skip(1)]));
  } else if (parsed.isAbsolute) {
    if (parsed.scheme != 'file') return uri;
    absolute = p.normalize(parsed.toFilePath());
  } else {
    absolute = p.normalize(
      File(p.join(root, from)).uri.resolveUri(parsed).toFilePath(),
    );
  }
  return p.isWithin(root, absolute)
      ? p.relative(absolute, from: root).replaceAll('\\', '/')
      : uri;
}

/// 数据、测试、工具及生成消费者分别统计；生成物不进入手写生产主图。
String auditCategory(String file) {
  if (file.startsWith('packages/sesame_api_client/lib/') ||
      file.endsWith('.g.dart') ||
      file.endsWith('.freezed.dart') ||
      file.startsWith('lib/l10n/app_localizations') ||
      file == 'lib/data/models/fitness_catalog_registry.dart') {
    return 'generated';
  }
  if (file.startsWith('test/') || file.contains('/test/')) return 'test';
  if (file.startsWith('e2e/')) return 'e2e';
  if (file.startsWith('scripts/')) return 'tool';
  return 'production';
}

/// 业务feature按名称聚合，本地包按包目录聚合，其余保留实际顶层目录。
String auditModule(String file) {
  final segments = file.split('/');
  if (segments.first == 'packages') return segments.take(2).join('/');
  if (segments.length > 2 && segments[1] == 'features') {
    return segments.take(3).join('/');
  }
  return segments.length > 2 ? segments.take(2).join('/') : segments.first;
}

/// 架构图和符号消费者均只读取源码；仅明确边界或分析不完整导致失败。
class ArchitectureAudit {
  /// root必须为目标仓库，符号分析默认关闭以支持快速边界检查。
  ArchitectureAudit(String root, {this.symbols = false})
    : root = p.normalize(p.absolute(root));

  final String root;
  final bool symbols;
  final edges = <AuditEdge>[];
  final failures = <String>[];
  final declarations = <String, Map<String, Object?>>{};
  final consumers = <String, Set<String>>{};
  final parts = <String, String>{};

  /// 声明身份以规范源路径、偏移及元素种类区分同名符号。
  String? elementKey(Element? input) {
    if (input == null) return null;
    final element = input.baseElement.nonSynthetic;
    final fragment = element.firstFragment;
    final path = fragment.libraryFragment?.source.fullName;
    if (path == null || !p.isWithin(root, p.normalize(path))) return null;
    return '${relative(path)}:${fragment.offset}:${element.kind.name}:${element.name}';
  }

  /// 输出相对路径，报告不包含账号、配置或用户数据。
  String relative(String path) =>
      p.relative(p.normalize(path), from: root).replaceAll('\\', '/');

  /// 将part追溯到所属library，组成关系不会成为普通编译循环。
  String libraryOf(String file) {
    final seen = <String>{};
    while (parts.containsKey(file)) {
      if (!seen.add(file)) throw StateError('part归属形成循环：$file');
      file = parts[file]!;
    }
    return file;
  }

  /// 使用rg遵守gitignore枚举所有应用、本地包、测试、工具的Dart源码。
  List<String> _files() {
    final directories = [
      'lib',
      'packages',
      'test',
      'scripts',
      'e2e',
    ].where((name) => Directory(p.join(root, name)).existsSync()).toList();
    if (directories.isEmpty) {
      throw StateError('没有可审计的Dart源码目录，请在目标仓库根目录运行');
    }
    final result = Process.runSync(
      'rg',
      ['--files', ...directories, '-g', '*.dart'],
      workingDirectory: root,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    if (result.exitCode > 1) {
      throw StateError('rg枚举失败(${result.exitCode})：${result.stderr}');
    }
    final files =
        (result.stdout as String)
            .split(RegExp(r'\r?\n'))
            .where((file) => file.isNotEmpty)
            .map((file) => file.replaceAll('\\', '/'))
            .toList()
          ..sort();
    // 空覆盖不能代表检查完成，忽略规则或运行目录错误必须明确失败。
    if (files.isEmpty) {
      throw StateError('没有可审计的Dart源码，请检查运行目录和忽略规则');
    }
    return files;
  }

  /// 只从当前仓库现有解析配置读取本地包，不解析依赖或下载安装。
  Map<String, String> _packages() {
    final config = File(p.join(root, '.dart_tool/package_config.json'));
    final json = jsonDecode(config.readAsStringSync()) as Map;
    return {
      for (final item in json['packages'] as List)
        item['name'] as String: p.normalize(
          Directory.fromUri(
            config.uri.resolve(item['rootUri'] as String),
          ).uri.resolve(item['packageUri'] as String? ?? 'lib/').toFilePath(),
        ),
    };
  }

  /// AST处理完整URI指令和所有条件分支，组合子由后续元素解析精确消费。
  void _parse(String file, Map<String, String> packages) {
    final result = parseString(
      content: File(p.join(root, file)).readAsStringSync(),
      path: p.normalize(p.join(root, file)),
      throwIfDiagnostics: false,
    );
    if (result.errors.isNotEmpty) {
      failures.add('$file：语法解析失败 ${result.errors}');
    }
    for (final directive in result.unit.directives) {
      if (directive is! UriBasedDirective) continue;
      final uri = directive.uri.stringValue;
      if (uri == null) {
        failures.add('$file：URI不能求值，偏移${directive.offset}');
        continue;
      }
      final kind = directive is ImportDirective
          ? 'import'
          : directive is ExportDirective
          ? 'export'
          : 'part';
      final target = resolveAuditUri(root, file, uri, packages);
      edges.add(
        AuditEdge(
          from: file,
          to: target,
          kind: kind,
          line: result.lineInfo.getLocation(directive.offset).lineNumber,
          directive: directive.toSource(),
        ),
      );
      if (kind == 'part') {
        final previous = parts[target];
        if (previous != null && previous != file) {
          failures.add('$target：被多个library声明为part');
        }
        parts[target] = file;
      }
      if (directive is NamespaceDirective) {
        for (final branch in directive.configurations) {
          final alternative = branch.uri.stringValue;
          if (alternative == null) {
            failures.add('$file：条件URI不能求值，偏移${branch.offset}');
            continue;
          }
          edges.add(
            AuditEdge(
              from: file,
              to: resolveAuditUri(root, file, alternative, packages),
              kind: kind,
              line: result.lineInfo.getLocation(branch.offset).lineNumber,
              directive: branch.toSource(),
              conditional: true,
            ),
          );
        }
      }
    }
  }

  /// 分析已解析元素，包括生成part、命名extension、注解和构造入口。
  Future<void> _resolve(List<String> files) async {
    final collection = AnalysisContextCollection(includedPaths: [root]);
    try {
      for (final file in files.where((file) => !parts.containsKey(file))) {
        try {
          final path = p.normalize(p.join(root, file));
          final result = await collection
              .contextFor(path)
              .currentSession
              .getResolvedLibrary(path);
          if (result is! ResolvedLibraryResult) {
            failures.add('$file：未获得完整library解析 ${result.runtimeType}');
            continue;
          }
          for (final unit in result.units) {
            final unitFile = relative(unit.path);
            final errors = unit.diagnostics.where(
              (error) => error.diagnosticCode.severity.name == 'ERROR',
            );
            if (errors.isNotEmpty) {
              failures.add('$unitFile：解析错误 ${errors.join('; ')}');
            }
            unit.unit.accept(_SymbolVisitor(this, unitFile, unit));
          }
        } catch (error, stack) {
          failures.add('$file：符号分析异常 ${error.runtimeType}');
          stderr.writeln('架构审计符号解析失败：$file\n$error\n$stack');
        }
      }
    } finally {
      await collection.dispose();
    }
  }

  /// 汇总编译图、边界和候选；候选数与SCC数不改变退出码。
  Future<Map<String, Object?>> run() async {
    final files = _files(), packages = _packages();
    for (final file in files) {
      try {
        _parse(file, packages);
      } catch (error, stack) {
        failures.add('$file：AST分析异常 ${error.runtimeType}');
        stderr.writeln('架构审计AST解析失败：$file\n$error\n$stack');
      }
    }
    final production = files
        .where((file) => auditCategory(file) == 'production')
        .map(libraryOf)
        .toSet();
    final graph = {for (final file in production) file: <String>{}};
    final violations = <Map<String, Object?>>[];
    for (final edge in edges) {
      final from = libraryOf(edge.from), to = libraryOf(edge.to);
      if (edge.kind != 'part' &&
          from != to &&
          production.contains(from) &&
          production.contains(to)) {
        graph[from]!.add(to);
      }
      if (['production', 'generated'].contains(auditCategory(edge.from))) {
        final reason = boundaryViolation(edge);
        if (reason != null) {
          violations.add({...edge.toJson(), 'rule': reason});
        }
      }
      if (!edge.to.contains(':') && !files.contains(edge.to)) {
        failures.add('${edge.from}:${edge.line}：仓内目标不存在 ${edge.to}');
      }
    }
    if (symbols) await _resolve(files);
    final modules = <String, Set<String>>{};
    final moduleSources = <String, Set<String>>{};
    for (final entry in graph.entries) {
      final from = auditModule(entry.key);
      modules.putIfAbsent(from, () => <String>{});
      for (final target in entry.value) {
        final to = auditModule(target);
        modules.putIfAbsent(to, () => <String>{});
        if (from == to) continue;
        modules[from]!.add(to);
        (moduleSources['$from -> $to'] ??= {}).add(entry.key);
      }
    }
    final candidates = <Map<String, Object?>>[];
    for (final entry in declarations.entries) {
      final declaration = entry.value;
      final references = consumers[entry.key] ?? <String>{};
      if (declaration['category'] == 'production' &&
          declaration['private'] == false &&
          (declaration['retentionHints'] as List).isEmpty &&
          references.isEmpty) {
        candidates.add({
          ...declaration,
          'identity': entry.key,
          'status': '零显式符号消费者候选，不能作为删除证明',
        });
      }
    }
    final counts = <String, int>{};
    for (final file in files) {
      counts.update(
        auditCategory(file),
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    return {
      'sourceRoot': root,
      'coverage': counts,
      'productionLibraries': production.length,
      'edges': edges.map((edge) => edge.toJson()).toList(),
      'parts': parts,
      'libraryScc': stronglyConnectedComponents(graph),
      'directoryScc': stronglyConnectedComponents(modules),
      'moduleEdges': {
        for (final entry in moduleSources.entries)
          entry.key: {
            'sourceLibraryCount': entry.value.length,
            'sourceLibraries': entry.value.toList()..sort(),
          },
      },
      'boundaryViolations': violations,
      'analysisFailures': failures,
      'analysisComplete': failures.isEmpty,
      'symbolAnalysisRequested': symbols,
      'symbolAnalysisComplete': symbols && failures.isEmpty,
      'declarations': declarations,
      'consumers': {
        for (final entry in consumers.entries)
          entry.key: entry.value.toList()..sort(),
      },
      'symbolCandidates': candidates,
      'limits': [
        '只处理Dart编译引用，原生入口、资源、动态注册、虚分派及跨仓消费者必须人工补证。',
        'part合并为library；show/hide由元素身份解析；条件分支全部入图，符号解析使用当前分析配置。',
        '生成代码参与符号消费者，生成API/翻译/registry与测试不进入手写生产SCC。',
        'SCC和零消费者仅报告，不按数量失败；明确边界违规或解析不完整才失败。',
      ],
    };
  }
}

/// 元素身份区分同名getter与接口，未解析动态调用不虚构消费者。
class _SymbolVisitor extends RecursiveAstVisitor<void> {
  /// 每个解析单元共享全仓声明及消费者索引。
  _SymbolVisitor(this.audit, this.file, this.result);

  final ArchitectureAudit audit;
  final String file;
  final ResolvedUnitResult result;

  /// 仅收集library及类型成员，局部变量和参数不是精简目标。
  void _declare(Declaration node) {
    final element = node.declaredFragment?.element.baseElement.nonSynthetic;
    if (element == null) return;
    final parent = element.enclosingElement;
    if (parent is! LibraryElement &&
        parent is! InterfaceElement &&
        parent is! ExtensionElement) {
      return;
    }
    final key = audit.elementKey(element);
    if (key == null) return;
    audit.declarations[key] = {
      'file': file,
      'line': result.lineInfo.getLocation(node.offset).lineNumber,
      'name': element.name,
      'kind': element.kind.name,
      'parent': parent?.name,
      'private': element.isPrivate,
      'category': auditCategory(file),
      'retentionHints': [
        if (parent is LibraryElement && element.name == 'main') 'Dart入口',
        if (node.metadata.any(
          (annotation) => annotation.toSource().contains('vm:entry-point'),
        ))
          '原生或后台入口注解',
        if (node.metadata.any(
          (annotation) => annotation.name.name == 'override',
        ))
          '接口或框架覆盖成员',
      ],
      'annotations': element.metadata.annotations
          .map((a) => a.toSource())
          .toList(),
    };
  }

  /// 记录静态引用；构造器消费同时登记所属类型。
  void _reference(Element? element) {
    final key = audit.elementKey(element);
    if (key != null) (audit.consumers[key] ??= {}).add(file);
    if (element is ConstructorElement) {
      final typeKey = audit.elementKey(element.enclosingElement);
      if (typeKey != null) (audit.consumers[typeKey] ??= {}).add(file);
    }
  }

  /// 普通标识符按已解析元素登记，声明名和show/hide组合子不算消费。
  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (!node.inDeclarationContext() && node.parent is! Combinator) {
      _reference(node.element);
    }
    super.visitSimpleIdentifier(node);
  }

  /// 类型注解同样消费声明，不能只统计方法调用。
  @override
  void visitNamedType(NamedType node) {
    _reference(node.element);
    super.visitNamedType(node);
  }

  /// 构造调用消费构造器及其所属类型。
  @override
  void visitConstructorName(ConstructorName node) {
    _reference(node.element);
    super.visitConstructorName(node);
  }

  /// 注册和生成注解按真实元素计入消费。
  @override
  void visitAnnotation(Annotation node) {
    _reference(node.element);
    super.visitAnnotation(node);
  }

  /// 收集类及其成员，继续遍历方法体中的引用。
  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _declare(node);
    super.visitClassDeclaration(node);
  }

  /// 命名及未命名构造器保留各自声明身份。
  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    _declare(node);
    super.visitConstructorDeclaration(node);
  }

  /// 泛型别名保持独立声明，避免把类型使用误当文本同名。
  @override
  void visitGenericTypeAlias(GenericTypeAlias node) {
    _declare(node);
    super.visitGenericTypeAlias(node);
  }

  /// 扩展类型参与当前Dart语义单元的声明统计。
  @override
  void visitExtensionTypeDeclaration(ExtensionTypeDeclaration node) {
    _declare(node);
    super.visitExtensionTypeDeclaration(node);
  }

  /// mixin保持类型成员身份，不把组合语义当模块循环。
  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    _declare(node);
    super.visitMixinDeclaration(node);
  }

  /// 枚举声明与成员引用分别登记。
  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    _declare(node);
    super.visitEnumDeclaration(node);
  }

  /// 命名extension及其getter/方法按扩展元素身份登记。
  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    _declare(node);
    super.visitExtensionDeclaration(node);
  }

  /// 顶层函数参与候选，局部闭包由声明拥有者筛选。
  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _declare(node);
    super.visitFunctionDeclaration(node);
  }

  /// 字段和顶层变量登记存储声明，合成访问器归一化到同一元素。
  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    _declare(node);
    super.visitVariableDeclaration(node);
  }

  /// 方法、显式getter和setter保留元素类别及所属类型。
  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _declare(node);
    super.visitMethodDeclaration(node);
  }
}

/// CLI始终只读；--json便于重定向到仓库Temp，--symbols启用较慢的完整符号分析。
Future<void> main(List<String> arguments) async {
  try {
    final unknown = arguments.where(
      (arg) => arg != '--json' && arg != '--symbols',
    );
    if (unknown.isNotEmpty) throw ArgumentError('仅支持 --json 与 --symbols');
    final report = await ArchitectureAudit(
      Directory.current.path,
      symbols: arguments.contains('--symbols'),
    ).run();
    if (arguments.contains('--json')) {
      print(const JsonEncoder.withIndent('  ').convert(report));
    } else {
      print(
        '覆盖：${report['coverage']}；手写生产library：${report['productionLibraries']}',
      );
      print('编译SCC（仅候选）：${report['libraryScc']}');
      print('明确边界违规：${report['boundaryViolations']}');
      final failures = report['analysisFailures'] as List;
      print('分析失败：${failures.length} 项 ${failures.take(12).toList()}');
      if (failures.length > 12) print('完整诊断请使用 --json，未省略任何失败判定。');
      print('零显式消费者候选：${(report['symbolCandidates'] as List).length}；不代表可删除。');
      print('原生、资源、动态入口、虚分派及跨仓消费者需人工核查。');
    }
    if ((report['analysisFailures'] as List).isNotEmpty) {
      exitCode = 2;
    } else if ((report['boundaryViolations'] as List).isNotEmpty) {
      exitCode = 1;
    }
  } catch (error, stack) {
    stderr.writeln('架构审计未完成，请检查现有依赖配置与详细诊断。\n$error\n$stack');
    exitCode = 2;
  }
}
