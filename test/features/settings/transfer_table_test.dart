import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/features/settings/infrastructure/content_transfer.dart';
import 'package:sesame_notes/features/settings/infrastructure/fitness_table_transfer.dart';
import 'package:sesame_notes/features/settings/infrastructure/transfer_table.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';

void main() {
  final now = DateTime.utc(2026, 9, 14);
  final id = transferId('record');
  final book = MemoBook(
    id: transferId('book'),
    name: '备忘录',
    type: 'normal',
    createdAt: now,
    updatedAt: now,
  );

  test('数组内的动作、组和次数可以映射第三方字段，自动识别后也可更改', () {
    final table = TransferTable.parse(
      jsonEncode([
        {
          'name': '外部模板',
          'items': [
            {
              '动作': '0025',
              'rounds': [
                {'次数': 8, '替代次数': 12},
              ],
            },
          ],
        },
      ]),
      TransferKind.fitness,
    );
    final mapping = table.detect(TransferKind.fitness)
      ..['exercises'] = 'items'
      ..['sets'] = 'items[].rounds';
    expect(mapping['exercise'], 'items[].动作');
    expect(mapping['reps'], 'items[].rounds[].次数');
    final converter = FitnessTableConverter([], {}, now, book.id);
    Map<String, Object?> row() =>
        table.mapped(0, TransferKind.fitness, mapping, {'entity_type': '模板'});
    expect(
      converter.convert([row()], id).payload['exercises'][0]['sets'][0]['reps'],
      8,
    );
    mapping['reps'] = 'items[].rounds[].替代次数';
    expect(
      converter.convert([row()], id).payload['exercises'][0]['sets'][0]['reps'],
      12,
    );
  });

  test('手动改映射覆盖原有同名键，数组字段清除映射后使用指定默认值', () {
    final table = TransferTable.parse(
      jsonEncode([
        {
          'entity_type': 'template',
          'name': '模板',
          'exercises': [
            {
              'exercise_id': '0025',
              'sets': [
                {'alternate': 12, 'reps': 8},
              ],
            },
          ],
        },
      ]),
      TransferKind.fitness,
    );
    final mapping = table.detect(TransferKind.fitness)
      ..['reps'] = 'exercises[].sets[].alternate';
    final converter = FitnessTableConverter([], {}, now, book.id);
    expect(
      converter.convert([
        table.mapped(0, TransferKind.fitness, mapping),
      ], id).payload['exercises'][0]['sets'][0]['reps'],
      12,
    );
    mapping['reps'] = null;
    expect(
      converter.convert([
        table.mapped(0, TransferKind.fitness, mapping, {'reps': '10'}),
      ], id).payload['exercises'][0]['sets'][0]['reps'],
      10,
    );
  });

  test('所有类型共用识别；成功映射可改选，未知字段可人工映射，可选字段有默认值', () {
    for (final kind in TransferKind.values) {
      final fields = transferFields[kind]!;
      final field = fields.first;
      final table = TransferTable.parse('${field.label},自定义\n原值,新值', kind);
      final mapping = table.detect(kind);
      expect(mapping[field.key], field.label);
      mapping[field.key] = '自定义';
      expect(table.mapped(0, kind, mapping)[field.key], '新值');
      mapping[field.key] = null;
      expect(table.mapped(0, kind, mapping)[field.key], field.defaultValue);
    }
    final table = TransferTable.parse('标题,正文\n我的标题,内容', TransferKind.memo);
    expect(table.detect(TransferKind.memo), {'title': '标题', 'body': '正文'});
  });

  test('CSV 保留密码空白、tab、前导零和引号内换行，不丢多余列', () {
    final table = TransferTable.parse(
      '标题,账号,密码\n卡片,0025,"  a\tb\nc  ",extra',
      TransferKind.credentials,
    );
    final row = table.mapped(
      0,
      TransferKind.credentials,
      table.detect(TransferKind.credentials),
    );
    // 卡片字段直接读原始单元格，空白、tab、前导零与引号内换行都不改写。
    expect(table.records.single['账号'], '0025');
    expect(table.records.single['密码'], '  a\tb\nc  ');
    expect(table.records.single.values, contains('extra'));
    final cardBook = MemoBook(
      id: book.id,
      name: book.name,
      type: 'credentials',
      createdAt: now,
      updatedAt: now,
    );
    final entry = transferMemo(
      row,
      id,
      cardBook,
      now,
      0,
      record: table.records.single,
      cardFields: [(header: '账号', label: '账号'), (header: '密码', label: '密码')],
    );
    // 只把填过值的列写进卡片：空单元格与未采用的列都不出现。
    expect(entry.fields.map((field) => field.label).toList(), ['账号', '密码']);
    expect(entry.fields[0].value, '0025');
    expect(entry.fields[1].value, '  a\tb\nc  ');
    expect(entry.orderKey, 0);
    // 字段名与顺序取自字段表：原「电话」列现在声明为「手机号」。
    final full = TransferTable.parse(
      '标题,账号,密码,手机号,邮箱,备注\n卡片,u,p,13800000000,e@example.com,说明',
      TransferKind.credentials,
    );
    // 每列默认都作为卡片字段：命中别名的用规范名，其余保留表头原文；
    // 被用作标题的列是卡片名称，不再重复成为字段。
    final fullDetected = full.detect(TransferKind.credentials);
    final fullEntry = transferMemo(
      full.mapped(0, TransferKind.credentials, fullDetected),
      id,
      cardBook,
      now,
      0,
      record: full.records.single,
      cardFields: [
        for (final header in full.headers)
          if (header != fullDetected['title'])
            (header: header, label: credentialFieldName(header)),
      ],
    );
    expect(
      fullEntry.fields.map((field) => '${field.label}=${field.value}').toList(),
      ['账号=u', '密码=p', '手机号=13800000000', '邮箱=e@example.com', '备注=说明'],
    );
  });

  test('普通 JSON 无需版本、来源或 UUID；纯文本转换为合法富文本', () {
    final table = TransferTable.parse(
      '[{"标题":"计划","内容":"第一行\\n第二行"}]',
      TransferKind.memo,
    );
    final row = table.mapped(
      0,
      TransferKind.memo,
      table.detect(TransferKind.memo),
    );
    final entry = transferMemo(row, id, book, now, 0);
    expect(entry.body, {
      'ops': [
        {'insert': '第一行\n第二行\n'},
      ],
    });
    expect(entry.createdAt, now);
    final rich = {
      'ops': [
        {
          'insert': '加粗',
          'attributes': {'bold': true},
        },
        {'insert': '\n'},
      ],
    };
    expect(transferMemo({...row, 'body': rich}, id, book, now, 0).body, rich);
    expect(
      () => transferMemo(
        {
          ...row,
          'body': {
            'ops': [
              {'delete': 5},
            ],
          },
        },
        id,
        book,
        now,
        0,
      ),
      throwsFormatException,
    );
  });

  test('日期不存在或更新时间倒置均拒绝；纯日期不会因时区变成前一天', () {
    expect(
      transferTimestamp('2026-09-14', now, '日期'),
      DateTime.utc(2026, 9, 14),
    );
    for (final date in ['2026-02-30', '2026-13-01', 'not-a-date']) {
      expect(() => transferTimestamp(date, now, '日期'), throwsFormatException);
    }
    expect(
      () => transferMemo(
        {'body': '正文', 'created_at': '2026-09-14', 'updated_at': '2026-09-13'},
        id,
        book,
        now,
        0,
      ),
      throwsFormatException,
    );
  });

  test('日子公历农历分别验证，农历闰月完整保留', () {
    final table = TransferTable.parse(
      '名称,日期,历法,闰月\n纪念,2023-02-29,农历,是',
      TransferKind.days,
    );
    final row = table.mapped(
      0,
      TransferKind.days,
      table.detect(TransferKind.days),
    );
    final day = transferDay(row, id, book.id, now);
    expect(day.definition.event!.solarDate!.iso8601, '2023-04-19');
    expect(day.definition.event!.isLeapMonth, isTrue);
    expect(
      () => transferDay({...row, 'calendar': 'solar'}, id, book.id, now),
      throwsA(isA<Exception>()),
    );
  });

  test('健身表格按训练日和动作组合组，缺少内部标识时生成关系', () {
    final table = TransferTable.parse(
      '计划名称,训练日,动作,重量,次数,组数,循环天数\n增肌,1,0025,20,8,2,3\n增肌,1,0025,25,6,1,3\n增肌,3,0001,0,10,3,3',
      TransferKind.fitness,
    );
    final mapping = table.detect(TransferKind.fitness);
    final rows = [
      for (var i = 0; i < 3; i++)
        table.mapped(i, TransferKind.fitness, mapping),
    ];
    final converter = FitnessTableConverter([], {}, now, book.id);
    final record = converter.convert(rows, id);
    expect(record.entityType, 'fitness_plan');
    final days = record.payload['days'] as List;
    expect(days, hasLength(3));
    expect(days[1]['slot'], isNull);
    final exercises = days[0]['slot']['exercises'] as List;
    expect(exercises, hasLength(1));
    expect(exercises.single['sets'], hasLength(3));
    expect(exercises.single['sets'][2]['weight'], '25');
    expect(record.payload['status'], 'closed');
    expect(record.payload['start_date'], isNull);
    expect(
      () => converter.convert([
        {...rows.first, 'weight': '-1'},
      ], id),
      throwsA(isA<Exception>()),
    );
    expect(
      () => converter.convert([
        {...rows.first, 'day': '4'},
      ], id),
      throwsFormatException,
    );
    expect(
      () => converter.convert([
        {...rows.first, 'set_count': '1001'},
      ], id),
      throwsFormatException,
    );
  });

  test('动作未识别必须匹配，识别成功同样可以改选', () {
    final converter = FitnessTableConverter(
      [],
      {'外部动作': '0025', '0025': '0001'},
      now,
      book.id,
    );
    expect(converter.exerciseId('外部动作'), '0025');
    expect(converter.exerciseId('0025'), '0001');
    expect(() => converter.exerciseId('不存在'), throwsFormatException);
  });

  test('JSON 嵌套计划无需 UUID，也可以通过顶层字段映射提供训练日安排', () {
    final table = TransferTable.parse(
      jsonEncode([
        {
          '名称': '计划',
          '我的安排': [
            {
              'slot': {
                'exercises': [
                  {
                    'exercise_id': '0025',
                    'sets': [
                      {'reps': 8, 'weight': '20'},
                    ],
                  },
                ],
              },
            },
          ],
        },
      ]),
      TransferKind.fitness,
    );
    final mapping = table.detect(TransferKind.fitness)..['days'] = '我的安排';
    final record = FitnessTableConverter(
      [],
      {},
      now,
      book.id,
    ).convert([table.mapped(0, TransferKind.fitness, mapping)], id);
    expect(record.payload['cycle_days'], 1);
    expect(
      record.payload['days'][0]['slot']['exercises'][0]['sets'][0]['reps'],
      8,
    );
  });

  test('左右重量按列导入，空单元格视为未填写且载荷通过严格校验', () {
    final table = TransferTable.parse(
      jsonEncode([
        {
          '数据类型': '训练',
          '名称': '分侧训练',
          '训练日期': '2026-09-11',
          '动作': '0025',
          '左侧重量': '5',
          '右侧重量': '6.25',
          '次数': 8,
        },
        {
          '数据类型': '训练',
          '名称': '分侧训练',
          '训练日期': '2026-09-11',
          '动作': '0025',
          '左侧重量': '',
          '右侧重量': '',
          '次数': 10,
        },
      ]),
      TransferKind.fitness,
    );
    final mapping = table.detect(TransferKind.fitness);
    final rows = [
      for (var i = 0; i < 2; i++)
        table.mapped(i, TransferKind.fitness, mapping, {'entity_type': '训练'}),
    ];
    final record = FitnessTableConverter(
      [],
      {},
      now,
      book.id,
    ).convert(rows, id);
    final sets = record.payload['exercises'][0]['sets'] as List;
    expect(sets, hasLength(2));
    expect(
      [sets[0]['weight'], sets[0]['weight_left'], sets[0]['weight_right']],
      [null, '5', '6.25'],
    );
    expect([sets[1]['weight_left'], sets[1]['weight_right']], [null, null]);
    expect(
      () => validateFitnessPayload(record.entityType, record.payload),
      returnsNormally,
    );
  });

  test('无效 JSON 容器、未闭合 CSV 引号拒绝，空文件可识别', () {
    expect(
      () => TransferTable.parse('[1,2]', TransferKind.memo),
      throwsFormatException,
    );
    expect(
      () => TransferTable.parse('标题,正文\n标题,"坏数据', TransferKind.memo),
      throwsFormatException,
    );
    expect(TransferTable.parse('', TransferKind.memo).records, isEmpty);
  });

  test('外部 JSON 数据列表和嵌套字段均可改选，不依赖固定根键', () {
    const text =
        '{"notes":[{"meta":{"title":"一"},"body":"正文"}],"archive":[{"title":"二","body":"归档"}]}';
    final table = TransferTable.parse(text, TransferKind.memo);
    expect(table.recordPath, 'notes');
    expect(table.detect(TransferKind.memo)['title'], 'meta.title');
    expect(
      TransferTable.parse(
        text,
        TransferKind.memo,
        recordPath: 'archive',
      ).records.single['title'],
      '二',
    );
  });

  test('同路径多层明细按父数组顺序追加，保留重复行并隔离其它路径', () {
    final text = jsonEncode({
      'groups': [
        {
          'buckets': [
            {
              'entries': [
                {'title': '相同标题', 'body': '相同正文'},
              ],
            },
          ],
        },
        {'buckets': []},
        {
          'buckets': [
            {'entries': []},
            {
              'entries': [
                {'title': '相同标题', 'body': '相同正文'},
                {'title': '末条', 'body': '末条正文'},
              ],
            },
          ],
        },
      ],
      'archive': [
        {'title': '归档', 'body': '其他路径'},
      ],
    });
    final table = TransferTable.parse(
      text,
      TransferKind.memo,
      recordPath: 'groups.buckets.entries',
    );
    final repeated = TransferTable.parse(
      text,
      TransferKind.memo,
      recordPath: 'groups.buckets.entries',
    );

    expect(table.records.map((row) => row['title']), ['相同标题', '相同标题', '末条']);
    expect(table.lineNumbers, [1, 2, 3]);
    expect(repeated.records, table.records);
    expect(repeated.lineNumbers, table.lineNumbers);
    expect(
      table.recordPaths.where((path) => path == table.recordPath),
      hasLength(1),
    );
    expect(
      TransferTable.parse(
        text,
        TransferKind.memo,
        recordPath: 'archive',
      ).records.single['title'],
      '归档',
    );
  });
}
