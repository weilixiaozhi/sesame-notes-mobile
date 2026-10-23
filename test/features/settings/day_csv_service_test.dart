import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/local/day_repository.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/features/settings/application/day_file_actions.dart';
import 'package:sesame_notes/features/settings/application/import_target.dart';
import 'package:sesame_notes/features/settings/application/transfer_actions.dart';
import 'package:sesame_notes/features/settings/infrastructure/day_csv_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/transfer_table.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';

import '../../helpers/test_isolation.dart';

const _bookId = '11111111-1111-4111-8111-111111111111';
final _time = DateTime.utc(2026, 9, 7);
final _book = DayBook(
  id: _bookId,
  name: '家人,"生日"\n纪念\t日😀',
  createdAt: _time,
  updatedAt: _time,
);

/// 构造四类独立记录，包含两个不同历法的阶段端点。
List<DayEvent> _entries({String? name, int count = 4}) =>
    List.generate(count, (index) {
      final day = OriginalDate.solar(DateOnly(2023, 3, 22));
      final category = DayCategory.values[index % 4];
      final definition = DayEventDefinition(
        category: category,
        name: name ?? '家庭,"节日"\n换行\t😀',
        repeatType: index % 4 < 2 ? DayRepeatType.yearly : DayRepeatType.none,
        statisticType: DayStatisticType.day,
        countdownMode: category == DayCategory.countdown
            ? DayCountdownMode.intervalDays
            : null,
        intervalDays: category == DayCategory.countdown ? 5 : null,
        event: index % 4 < 2 ? day : null,
        start: index % 4 >= 2 ? day : null,
        end: category == DayCategory.stage
            ? const OriginalDate(
                calendarType: DayCalendarType.lunar,
                originalYear: 2023,
                originalMonth: 2,
                originalDay: 29,
                isLeapMonth: true,
              )
            : null,
      );
      return DayEvent(
        id: '33333333-3333-4333-8333-${index.toString().padLeft(12, '0')}',
        dayBookId: _bookId,
        definition: definition,
        createdAt: _time,
        updatedAt: _time,
      );
    });

/// 独立修改已解码的 CSV 单元格，用于验证外部损坏边界。
List<int> _mutate(
  List<int> bytes,
  void Function(List<List<dynamic>> rows) mutation,
) {
  final rows = const CsvDecoder(
    fieldDelimiter: ',',
    dynamicTyping: false,
    skipEmptyLines: false,
  ).convert(utf8.decode(bytes));
  mutation(rows);
  return utf8.encode(
    const CsvEncoder(lineDelimiter: '\n', addBom: true).convert(rows),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('四类原始定义、空格、引号、换行、tab与Unicode完整往返', () {
    final bytes = DayCsvService.encode(book: _book, entries: _entries()).single;
    expect(bytes.take(3), [239, 187, 191]);
    final rows = const CsvDecoder(
      fieldDelimiter: ',',
      dynamicTyping: false,
      skipEmptyLines: false,
    ).convert(utf8.decode(bytes));
    expect(rows.first, DayCsvService.headers);
    expect(rows.first, isNot(contains('schema_version')));
    expect(rows, hasLength(5));
    final parsed = DayCsvService.decode(bytes);
    expect(
      parsed.entries.map((entry) => entry.definition.category),
      DayCategory.values,
    );
    expect(parsed.entries.first.definition.name, '家庭,"节日"\n换行\t😀');
    expect(
      parsed.entries.last.definition.end!.calendarType,
      DayCalendarType.lunar,
    );
    expect(parsed.entries.last.definition.end!.isLeapMonth, isTrue);
    expect(
      parsed.entries.last.definition.end!.solarDate!.iso8601,
      '2023-04-19',
    );
    expect(parsed.entries.first.createdAt, _time);
    final retried = DayCsvService.decode(bytes);
    expect(retried.exportId, parsed.exportId, reason: '同一文件重试使用原导入去重身份');
    expect(
      retried.entries.map((entry) => entry.id),
      parsed.entries.map((entry) => entry.id),
      reason: '同一文件重试保持来源条目身份',
    );
  });

  test('空本只有表头且不产生伪记录，接受无BOM和CRLF', () {
    final bytes = DayCsvService.encode(book: _book, entries: []).single;
    final parsed = DayCsvService.decode(bytes);
    expect(parsed.entries, isEmpty);
    expect(DayCsvService.decode(bytes.skip(3).toList()).entries, isEmpty);
    final simpleBook = DayBook(
      id: _bookId,
      name: '本',
      createdAt: _time,
      updatedAt: _time,
    );
    final simple = DayCsvService.encode(book: simpleBook, entries: []).single;
    expect(
      DayCsvService.decode(
        utf8.encode(utf8.decode(simple).replaceAll('\n', '\r\n')),
      ).entries,
      isEmpty,
    );
  });

  test('1001条拆成独立1000与1条分包，来源身份稳定', () {
    final parts = DayCsvService.encode(
      book: _book,
      entries: _entries(count: 1001),
    ).map(DayCsvService.decode).toList();
    expect(parts.map((part) => part.entries.length), [1000, 1]);
    expect(parts.map((part) => part.exportId).toSet(), hasLength(2));
  });

  test('没有来源标识的普通文件只按业务内容生成指纹，空标识不改变重导身份', () {
    const text = '名称,日期\n生日,2026/9/14';
    const withEmptyId = '名称,日期,id\n生日,2026/9/14,';
    final expected = <String, Object?>{
      'name': '生日',
      'category': 'anniversary',
      'date': '2026/9/14',
      'calendar': 'solar',
      'is_leap_month': 'false',
      'repeat_type': null,
      'statistic_type': 'day',
      'start_date': null,
      'start_calendar': 'solar',
      'start_is_leap_month': 'false',
      'end_date': null,
      'end_calendar': 'solar',
      'end_is_leap_month': 'false',
      'countdown_mode': null,
      'interval_days': null,
      'created_at': null,
      'updated_at': null,
    };
    final expectedExportId = transferId([
      TransferKind.days.name,
      [expected],
    ]);
    for (final csv in [text, withEmptyId]) {
      final table = TransferTable.parse(csv, TransferKind.days);
      final row = table.mapped(
        0,
        TransferKind.days,
        table.detect(TransferKind.days),
      );
      expect(row, expected);
      expect(row.containsKey('id'), isFalse);
      final decoded = DayCsvService.decode(utf8.encode(csv));
      expect(decoded.exportId, expectedExportId);
      expect(
        decoded.entries.single.id,
        transferId([
          expectedExportId,
          [0],
        ]),
      );
    }
  });

  test('2000条独立记录即使两包业务内容完全相同，也全部导入且原文件重导幂等', () async {
    resetGlobalTestState();
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    final repo = DayRepository(
      db,
      validateAndProject: validateAndProject,
      accountIdGetter: () => null,
      generationGetter: () => 0,
    );
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        dayRepositoryProvider.overrideWithValue(repo),
        currentAccountIdProvider.overrideWithValue(null),
        authIdentityGenerationProvider.overrideWithValue(0),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    const targetId = '22222222-2222-4222-8222-222222222222';
    await repo.createBook(id: targetId, name: '分包导入目标');
    final target = DataImportTarget(
      dayTarget: await container.read(dayFileActionsProvider).target(targetId),
    );
    final entries = _entries(count: 2000);
    expect(entries.map((entry) => entry.id).toSet(), hasLength(2000));
    final parts = DayCsvService.encode(book: _book, entries: entries);
    expect(parts, hasLength(2));
    final decoded = parts.map(DayCsvService.decode).toList();
    expect(decoded.map((part) => part.exportId).toSet(), hasLength(2));
    expect(
      decoded.expand((part) => part.entries).map((entry) => entry.id).toSet(),
      hasLength(2000),
    );
    final exports = <String>[];
    var imported = 0;
    for (final bytes in parts) {
      final table = TransferTable.parse(utf8.decode(bytes), TransferKind.days);
      final session = TransferActions(
        container.read,
        target,
        table,
        TransferKind.days,
      );
      await session.prepare();
      session.map(table.detect(TransferKind.days));
      expect(
        session.mappedRows.map((row) => row['id']).toSet(),
        hasLength(1000),
        reason: '来源记录身份由正式字段映射保留并参与分包指纹',
      );
      await session.buildPreview();
      expect(session.preview.every((row) => row.error == null), isTrue);
      exports.add(session.exportId);
      if (session.preview.any((row) => !row.duplicate)) {
        imported += (await session.import((_, _) {}, (_) {})).imported;
      }
    }
    expect(imported, 2000, reason: '每个来源记录都有独立身份，后一个合法分包不能被当成前一包重试');
    expect(exports.toSet(), hasLength(2));
    final stored = await repo.getEvents(targetId);
    expect(stored, hasLength(2000));
    expect(stored.map((entry) => entry.id).toSet(), hasLength(2000));
    expect(await db.select(db.dayImportReceipts).get(), hasLength(2000));

    // 重新创建导入会话，重复识别必须来自持久回执，不能依赖原会话内存。
    for (final bytes in parts) {
      final table = TransferTable.parse(utf8.decode(bytes), TransferKind.days);
      final session = TransferActions(
        container.read,
        target,
        table,
        TransferKind.days,
      );
      await session.prepare();
      session.map(table.detect(TransferKind.days));
      await session.buildPreview();
      expect(session.preview, hasLength(1000));
      expect(
        session.preview.every((row) => row.duplicate && !row.selected),
        isTrue,
      );
    }
    expect(await repo.getEvents(targetId), hasLength(2000));
    expect(await db.select(db.dayImportReceipts).get(), hasLength(2000));
  });

  test('拆包使用含BOM转义和封装的实际UTF8字节，单条过大拒绝', () {
    final entries = _entries(name: '😀,"' * 20, count: 10);
    final parts = DayCsvService.encode(
      book: _book,
      entries: entries,
      maxBytes: 1800,
    );
    expect(parts.length, greaterThan(1));
    expect(parts.every((part) => part.length <= 1800), isTrue);
    expect(
      parts.expand((part) => DayCsvService.decode(part).entries),
      hasLength(10),
    );
    expect(
      () => DayCsvService.encode(book: _book, entries: entries, maxBytes: 100),
      throwsA(isA<FormatException>()),
    );
  });

  test('接受外部表头与缺省字段，拒绝无效日期和不一致业务定义', () {
    final simple = DayCsvService.decode(utf8.encode('名称,日期\n生日,2026/9/14'));
    expect(
      simple.entries.single.definition.event!.solarDate!.iso8601,
      '2026-09-14',
    );
    expect(simple.entries.single.definition.repeatType, 'yearly');
    final bytes = DayCsvService.encode(book: _book, entries: _entries()).single;
    for (final change in <(String, String)>[
      ('date', '2026-02-30'),
      ('calendar', 'unknown'),
      ('name', ''),
      ('repeat_type', 'none'),
      ('created_at', '2026-02-30T00:00:00Z'),
      ('is_leap_month', 'true'),
    ]) {
      expect(
        () => DayCsvService.decode(
          _mutate(bytes, (rows) {
            rows[1][DayCsvService.headers.indexOf(change.$1)] = change.$2;
          }),
        ),
        throwsA(isA<Exception>()),
      );
    }
  });
  test('拒绝非法UTF8、财务CSV、未闭合引号与超字节文件', () {
    expect(() => DayCsvService.decode([0xff]), throwsA(isA<FormatException>()));
    expect(
      () => DayCsvService.decode(utf8.encode('类型,金额\n支出,10')),
      throwsA(isA<FormatException>()),
    );
    expect(
      () => DayCsvService.decode(utf8.encode('"bad')),
      throwsA(isA<FormatException>()),
    );
    expect(
      () =>
          DayCsvService.decode(List.filled(DayCsvService.maxFileBytes + 1, 0)),
      throwsA(isA<FormatException>()),
    );
  });
}
