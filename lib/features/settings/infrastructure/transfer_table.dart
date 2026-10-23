import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import 'parsers/csv_parser.dart';
import '../../../utils/date/date_parser.dart';
import 'parsers/generic_parser.dart';

/// 所有业务共用字段识别、映射与缺省值；业务转换只消费映射后的值。
class TransferField {
  final String key;
  final String label;
  final List<String> aliases;
  final String? defaultValue;
  final bool required;
  const TransferField(
    this.key,
    this.label, {
    this.aliases = const [],
    this.defaultValue,
    this.required = false,
  });
}

enum TransferKind { ledger, days, memo, credentials, fitness }

/// 账号密码导入时的字段名建议：命中常见表头的列用规范名，其余保留表头原文。
const credentialFieldAliases = <String, List<String>>{
  '账号': ['account', 'username', '用户名'],
  '密码': ['password'],
  '手机号': ['phone', '电话'],
  '邮箱': ['email'],
  '备注': ['remark', 'note'],
};

/// 卡片字段的默认名：表头命中别名用规范名，否则原样使用表头。
String credentialFieldName(String header) {
  final normalized = normalizeTransferHeader(header);
  for (final entry in credentialFieldAliases.entries) {
    if ([
      entry.key,
      ...entry.value,
    ].any((alias) => normalizeTransferHeader(alias) == normalized)) {
      return entry.key;
    }
  }
  return header.trim();
}

const transferFields = <TransferKind, List<TransferField>>{
  TransferKind.ledger: [
    TransferField(
      'date',
      '日期',
      aliases: ['时间', '交易时间', 'happened_at'],
      required: true,
    ),
    TransferField('type', '类型', defaultValue: 'expense'),
    TransferField('amount', '金额', required: true),
    TransferField('currency', '币种'),
    TransferField('category', '分类', required: true),
    TransferField('sub_category', '二级分类'),
    TransferField('category_icon', '分类图标'),
    TransferField('sub_category_icon', '二级分类图标'),
    TransferField('note', '备注', aliases: ['remark']),
  ],
  TransferKind.days: [
    TransferField('name', '名称', aliases: ['标题', 'title'], required: true),
    TransferField(
      'category',
      '类别',
      aliases: ['分类', 'type'],
      defaultValue: 'anniversary',
    ),
    TransferField('date', '日期', aliases: ['event_date', '生日', '纪念日期']),
    TransferField(
      'calendar',
      '历法',
      aliases: ['calendar_type'],
      defaultValue: 'solar',
    ),
    TransferField('is_leap_month', '闰月', defaultValue: 'false'),
    TransferField('repeat_type', '重复规则', aliases: ['repeat']),
    TransferField('statistic_type', '统计方式', defaultValue: 'day'),
    TransferField('start_date', '开始日期'),
    TransferField('start_calendar', '开始历法', defaultValue: 'solar'),
    TransferField('start_is_leap_month', '开始闰月', defaultValue: 'false'),
    TransferField('end_date', '结束日期'),
    TransferField('end_calendar', '结束历法', defaultValue: 'solar'),
    TransferField('end_is_leap_month', '结束闰月', defaultValue: 'false'),
    TransferField('countdown_mode', '倒数方式'),
    TransferField('interval_days', '间隔天数'),
    TransferField('created_at', '创建时间'),
    TransferField('updated_at', '修改时间'),
    TransferField('id', '记录关联标识'),
  ],
  TransferKind.memo: [
    TransferField('title', '标题', aliases: ['name', '名称']),
    TransferField(
      'body',
      '正文',
      aliases: ['content', 'text', '内容'],
      required: true,
    ),
    TransferField('created_at', '创建时间'),
    TransferField('updated_at', '修改时间'),
  ],
  // 账号密码只固定标题与时间；其余列在映射页逐列确认字段名后写进卡片。
  TransferKind.credentials: [
    TransferField('title', '标题', aliases: ['name', '名称']),
    TransferField('created_at', '创建时间'),
    TransferField('updated_at', '修改时间'),
  ],
  TransferKind.fitness: [
    TransferField(
      'entity_type',
      '数据类型',
      aliases: ['type'],
      defaultValue: 'fitness_plan',
    ),
    TransferField(
      'name',
      '名称',
      aliases: ['计划名称', '训练名称', 'plan', 'title'],
      required: true,
    ),
    TransferField('day', '训练日', defaultValue: '1'),
    TransferField('day_index', '训练日序号（从 0 开始）'),
    TransferField('cycle_days', '循环天数'),
    TransferField('exercise', '动作', aliases: ['exercise_id', '动作名称']),
    TransferField('weight', '重量'),
    TransferField('weight_left', '左侧重量'),
    TransferField('weight_right', '右侧重量'),
    TransferField('reps', '次数'),
    TransferField(
      'set_count',
      '组数',
      aliases: ['组', 'sets_count'],
      defaultValue: '1',
    ),
    TransferField('kind', '组类型', defaultValue: 'working'),
    TransferField('rest_seconds', '休息秒数', defaultValue: '90'),
    TransferField('scheduled_date', '训练日期', aliases: ['date', '日期']),
    TransferField('start_date', '计划开始日期'),
    TransferField('status', '状态'),
    TransferField('completed', '完成', defaultValue: 'false'),
    TransferField('exercises', '动作与组'),
    TransferField('sets', '组明细'),
    TransferField('slot', '训练安排'),
    TransferField('days', '训练日安排'),
    TransferField('generation_state', '计划执行状态'),
    TransferField('pending_schedule', '待生效安排'),
    TransferField('catalog_origin', '官方来源'),
    TransferField('source_kind', '训练来源'),
    TransferField('source_plan_id', '关联计划'),
    TransferField('source_plan_name', '关联计划名称'),
    TransferField('source_template_id', '关联模板'),
    TransferField('occurrence_key', '计划发生标识'),
    TransferField('run_segments', '执行时段'),
    TransferField('rest_timer', '计时状态'),
    TransferField('preferences', '健身偏好'),
    TransferField('id', '记录关联标识'),
    TransferField('created_at', '创建时间'),
    TransferField('updated_at', '修改时间'),
  ],
};

String normalizeTransferHeader(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[\s_\-（）()]'), '');

class TransferTable {
  final List<String> headers;
  final List<Map<String, Object?>> records;
  final List<int> lineNumbers;
  final List<String> recordPaths;
  final String recordPath;

  /// 备忘录交换格式（sesame-memos）声明的本子类型与本名；其它格式为 null。
  ///
  /// 目标本类型与文件声明不一致时逐条都会报必填缺失，页面据此给出明确提示。
  final String? memoBookType;
  final String? memoBookName;
  const TransferTable(
    this.headers,
    this.records,
    this.lineNumbers, {
    this.recordPaths = const [],
    this.recordPath = '',
    this.memoBookType,
    this.memoBookName,
  });

  factory TransferTable.parse(
    String text,
    TransferKind kind, {
    bool hasHeader = true,
    String? recordPath,
  }) {
    final clean = text.replaceFirst(RegExp(r'^\uFEFF'), '').trimLeft();
    if (utf8.encode(clean).length > 64 * 1024 * 1024) {
      throw const FormatException('文件不能超过 64 MiB');
    }
    if (clean.startsWith('[') || clean.startsWith('{')) {
      final decoded = jsonDecode(clean);
      final sources = <String, List<Map<String, dynamic>>>{};
      // 逐层下钻收集所有对象数组：交换格式把明细包在 books[].entries 一类
      // 嵌套数组里，只认顶层数组会误把外层包装对象当成记录。
      void collect(Object? node, String path) {
        if (node is List) {
          if (node.isNotEmpty && node.every((r) => r is Map<String, dynamic>)) {
            // 同一路径可分布于多个父对象，按文件顺序收集，不覆盖或去重真实记录。
            sources
                .putIfAbsent(path, () => <Map<String, dynamic>>[])
                .addAll(node.cast<Map<String, dynamic>>());
          }
          for (final item in node) {
            collect(item, path);
          }
          return;
        }
        if (node is Map<String, dynamic>) {
          for (final entry in node.entries) {
            collect(
              entry.value,
              path.isEmpty ? entry.key : '$path.${entry.key}',
            );
          }
        }
      }

      collect(decoded, '');
      if (decoded is Map<String, dynamic>) sources[''] = [decoded];
      final directFields = decoded is Map<String, dynamic>
          ? _detect(decoded.keys.toList(), kind)
          : const {};
      // 备忘录交换格式带本子信封：默认直接落到 books[].entries 明细，
      // 其它格式沿用「先注册的数组即明细」这一可预期选择。
      final selected =
          recordPath ??
          (directFields.isNotEmpty && sources.containsKey('')
              ? ''
              : sources.containsKey(_memoEntriesPath) &&
                    _memoExchangeBook(decoded) != null
              ? _memoEntriesPath
              : sources.keys.firstOrNull ?? '');
      final source = sources[selected];
      if (source == null) {
        throw const FormatException('JSON 应包含对象数组，每个对象是一条记录');
      }
      // 保留对象本身以支持富文本，同时展开对象属性供外部嵌套字段手动映射。
      Map<String, Object?> flatten(Map<String, dynamic> input) {
        final output = <String, Object?>{...input};
        void visit(Object? node, String prefix, {bool inArray = false}) {
          if (node is List) {
            for (final item in node) {
              visit(item, '$prefix[]', inArray: true);
            }
            return;
          }
          if (node is! Map<String, dynamic>) return;
          for (final entry in node.entries) {
            final key = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
            output[key] = inArray ? null : entry.value;
            visit(entry.value, key, inArray: inArray);
          }
        }

        visit(input, '');
        return output;
      }

      final records = source.map(flatten).toList();
      final book = _memoExchangeBook(decoded);
      return TransferTable(
        records.expand((r) => r.keys).toSet().toList(),
        records,
        List.generate(records.length, (i) => i + 1),
        recordPaths: sources.keys.toList(),
        recordPath: selected,
        memoBookType: book?.type,
        memoBookName: book?.name,
      );
    }
    final rows = CsvParser.parse(text, preserveValues: true);
    if (rows.isEmpty) return const TransferTable([], [], []);
    var header = 0;
    if (hasHeader) {
      if (kind == TransferKind.ledger) {
        header = GenericBillParser().findHeaderRow(rows);
      } else {
        var best = 0;
        for (var i = 0; i < rows.length && i < 30; i++) {
          final score = _detect(rows[i], kind).length;
          if (score > best) {
            best = score;
            header = i;
          }
        }
      }
    }
    final width = rows
        .skip(header)
        .fold(0, (n, r) => r.length > n ? r.length : n);
    final columns = List.generate(
      width,
      (i) =>
          hasHeader && i < rows[header].length ? rows[header][i] : '列 ${i + 1}',
    );
    // 同名表头加序号，避免 Map 覆盖用户数据。
    final names = <String>[];
    for (var i = 0; i < columns.length; i++) {
      var name = columns[i].trim().isEmpty ? '列 ${i + 1}' : columns[i].trim();
      final base = name;
      var suffix = i + 1;
      while (names.contains(name)) {
        name = '$base (${suffix++})';
      }
      names.add(name);
    }
    final records = <Map<String, Object?>>[];
    final lines = <int>[];
    for (var i = hasHeader ? header + 1 : 0; i < rows.length; i++) {
      if (rows[i].every((v) => v.trim().isEmpty)) continue;
      records.add({
        for (var c = 0; c < names.length; c++)
          names[c]: c < rows[i].length ? rows[i][c] : null,
      });
      lines.add(i + 1);
    }
    return TransferTable(names, records, lines);
  }

  /// 备忘录交换格式的明细数组路径：本子信封与明细分两层，明细固定在 books[].entries。
  static const _memoEntriesPath = 'books.entries';

  /// 读取备忘录交换格式声明的本子身份；非该格式或字段不合法时返回 null。
  static ({String type, String name})? _memoExchangeBook(Object? decoded) {
    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != 'sesame-memos' ||
        decoded['books'] is! List) {
      return null;
    }
    final books = decoded['books'] as List;
    if (books.length != 1 || books.single is! Map<String, dynamic>) return null;
    final book = books.single as Map<String, dynamic>;
    final type = book['type'];
    final name = book['name'];
    if (type is! String || name is! String) return null;
    return (type: type, name: name);
  }

  static Map<String, String> _detect(List<String> headers, TransferKind kind) {
    final result = <String, String>{};
    if (kind == TransferKind.ledger) {
      GenericBillParser()
          .mapColumns(headers)
          .forEach((k, v) => result[k] = headers[v]);
    }
    for (final field in transferFields[kind]!) {
      final aliases = [
        field.key,
        field.label,
        ...field.aliases,
      ].map(normalizeTransferHeader).toSet();
      final matches = headers
          .where((h) => aliases.contains(normalizeTransferHeader(h)))
          .toList();
      if (matches.isEmpty) {
        matches.addAll(
          headers.where(
            (h) => aliases.contains(normalizeTransferHeader(h.split('.').last)),
          ),
        );
      }
      if (matches.length == 1) result[field.key] = matches.single;
    }
    return result;
  }

  Map<String, String?> detect(TransferKind kind) => <String, String?>{
    ..._detect(headers, kind),
  };

  /// 提取映射后的业务字段；未提供的日子来源标识不参与内容指纹。
  Map<String, Object?> mapped(
    int index,
    TransferKind kind,
    Map<String, String?> mapping, [
    Map<String, String> defaults = const {},
  ]) {
    final row = <String, Object?>{
      for (final f in transferFields[kind]!)
        f.key: _value(
          _nested(
            records[index][mapping[f.key]],
            mapping[f.key] ?? '',
            mapping,
            defaults,
            transferFields[kind]!,
          ),
          defaults[f.key] ?? f.defaultValue,
        ),
    };
    // 来源标识存在时区分内容相同的独立分包；缺省时只按实际业务内容识别重导。
    if (kind == TransferKind.days && row['id'] == null) row.remove('id');
    return row;
  }

  /// 数组内字段也使用同一张映射表，第三方动作和组无需照抄内部字段名。
  static Object? _nested(
    Object? value,
    String path,
    Map<String, String?> mapping,
    Map<String, String> defaults,
    List<TransferField> fields,
  ) {
    if (value is List) {
      return [
        for (final item in value)
          _nested(item, '$path[]', mapping, defaults, fields),
      ];
    }
    if (value is! Map) return value;
    final result = <String, Object?>{};
    final overrides = <String, Object?>{};
    for (final entry in value.entries) {
      final childPath = '$path.${entry.key}';
      final cleared = fields
          .where(
            (f) =>
                mapping.containsKey(f.key) &&
                mapping[f.key] == null &&
                (f.key == entry.key || f.aliases.contains(entry.key)),
          )
          .firstOrNull;
      if (cleared != null) {
        overrides[cleared.key] = _value(
          null,
          defaults[cleared.key] ?? cleared.defaultValue,
        );
        continue;
      }
      final child = _nested(entry.value, childPath, mapping, defaults, fields);
      result[entry.key as String] = child;
      for (final field in mapping.entries.where((m) => m.value == childPath)) {
        overrides[field.key] = child;
      }
    }
    // 人工映射优先于原有同名键，不受 JSON 字段排列顺序影响。
    return {...result, ...overrides};
  }

  static Object? _value(Object? value, String? fallback) =>
      value == null || value is String && value.isEmpty
      ? (fallback == '' ? null : fallback)
      : value;
}

TransferTable parseTransferTable((String, TransferKind, bool, String?) input) =>
    TransferTable.parse(
      input.$1,
      input.$2,
      hasHeader: input.$3,
      recordPath: input.$4,
    );

/// 身份取决于映射后的源记录，勾选子集与重试不会改变身份，也不要求文件携带 UUID。
String transferId(Object? value) {
  final bytes = sha256
      .convert(utf8.encode(jsonEncode(value)))
      .bytes
      .take(16)
      .toList();
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  return Uuid.unparse(bytes);
}

DateTime transferTimestamp(Object? value, DateTime fallback, String field) {
  if (value == null || value == '') return fallback;
  final raw = value.toString().trim();
  final parsed = DateParser.tryParseStrict(raw);
  if (parsed == null || parsed.year < 1) {
    throw FormatException('$field：日期或时间无效');
  }
  // 没有时分秒的日期按自然日处理，不能因 UTC 转换变成前一天。
  if (!RegExp(r'\d{1,2}:\d{1,2}').hasMatch(raw)) {
    return DateTime.utc(parsed.year, parsed.month, parsed.day);
  }
  return parsed.toUtc();
}

String transferText(
  Map<String, Object?> row,
  String key, {
  String fallback = '',
}) => row[key]?.toString() ?? fallback;

bool transferBool(Object? value, String field) =>
    switch (value?.toString().trim().toLowerCase()) {
      null || '' || 'false' || '0' || '否' => false,
      'true' || '1' || '是' => true,
      _ => throw FormatException('$field：应为是／否或 true／false'),
    };
