import 'dart:convert';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/memo_delta.dart';
import 'package:sesame_notes/data/models/memo_fields.dart';
import 'package:sesame_notes/data/models/memo_json.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late MemoRepository repo;
  String? account;
  var generation = 0;
  const a = '11111111-1111-4111-8111-111111111111';
  const b = '22222222-2222-4222-8222-222222222222';
  const e = '33333333-3333-4333-8333-333333333333';
  final time = DateTime.parse('2026-09-08T12:34:56.789Z');
  MemoEntry entry(String book, {String id = e, bool card = false}) => MemoEntry(
    id: id,
    memoBookId: book,
    bookType: card ? 'credentials' : 'normal',
    title: card ? '原始凭据' : '',
    createdAt: time,
    updatedAt: time,
    bodyJson: card
        ? encodeMemoFields(const [
            MemoField(label: '账号', value: ' \u0000用户 '),
            MemoField(label: '密码', value: ' \u0000🔑\n '),
          ])
        : jsonEncode({
            'ops': [
              {'insert': '正文😀\n\n'},
            ],
          }),
    // 卡片顺序由仓储在保存时分配，普通笔记必须保持为 null。
    orderKey: null,
  );
  setUp(() {
    account = null;
    generation = 0;
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = MemoRepository(
      db,
      accountIdGetter: () => account,
      generationGetter: () => generation,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
    );
  });
  tearDown(() => db.close());

  final invalidCardBodies = <String, Object>{
    '缺少字段列表': <String, Object>{},
    '字段列表类型错误': {'fields': 1},
    '正文存在未知字段': {'fields': <Object>[], 'extra': true},
    '字段名称为空白': {
      'fields': [
        {'label': '  ', 'value': 'value'},
      ],
    },
    '字段名称超过上限': {
      'fields': [
        {'label': '名' * (memoLabelLimit + 1), 'value': 'value'},
      ],
    },
    '字段取值超过上限': {
      'fields': [
        {'label': '字段', 'value': 'x' * (memoValueLimit + 1)},
      ],
    },
    '字段数量超过上限': {
      'fields': List.generate(
        memoFieldLimit + 1,
        (index) => {'label': '字段$index', 'value': 'value'},
      ),
    },
    '字段取值包含孤立代理项': {
      'fields': [
        {'label': '字段', 'value': String.fromCharCode(0xd800)},
      ],
    },
  };

  /// 可见标题只能满足整卡内容要求，不能跳过字段协议及长度校验。
  test('可见标题的账号卡片仍逐项校验 fields_v1 正文', () {
    for (final invalid in invalidCardBodies.entries) {
      final value = MemoEntry(
        id: e,
        memoBookId: a,
        bookType: memoBookTypeCredentials,
        title: '可见卡片名称',
        createdAt: time,
        updatedAt: time,
        bodyJson: jsonEncode(invalid.value),
      );
      expect(value.validate, throwsFormatException, reason: invalid.key);
    }
    expect(
      MemoEntry(
        id: e,
        memoBookId: a,
        bookType: memoBookTypeCredentials,
        title: '只有名称的有效卡片',
        createdAt: time,
        updatedAt: time,
        bodyJson: '{"fields":[]}',
      ).validate,
      returnsNormally,
    );
  });

  for (final storage in ['local', 'cloud']) {
    /// 写入校验失败必须保持父本、正文和同步意图原样，云本也不能排入非法载荷。
    test('$storage 可见标题和非法字段零写入、父本不变、队列不变', () async {
      account = storage == 'cloud' ? 'owner' : null;
      await repo.createBook(
        id: a,
        name: '账号密码本',
        type: memoBookTypeCredentials,
        storageMode: storage,
      );
      final target = await repo.target(a);
      final beforeBook = await db.select(db.memoBooks).getSingle();
      final beforeChanges = await db.select(db.syncChanges).get();
      for (final invalid in invalidCardBodies.entries) {
        final value = MemoEntry(
          id: e,
          memoBookId: a,
          bookType: memoBookTypeCredentials,
          title: '可见卡片名称',
          createdAt: time,
          updatedAt: time,
          bodyJson: jsonEncode(invalid.value),
        );
        await expectLater(
          repo.saveEntry(value, target),
          throwsFormatException,
          reason: invalid.key,
        );
        expect(await db.select(db.memoEntries).get(), isEmpty);
        expect(await db.select(db.memoBooks).getSingle(), beforeBook);
        expect(await db.select(db.syncChanges).get(), beforeChanges);
      }
    });
  }

  test('创建、数据库、JSON 导入和备份快照拒绝日记本类型', () async {
    await expectLater(
      repo.createBook(id: a, name: '本', type: 'diary'),
      throwsA(anything),
    );
    await repo.createBook(id: a, name: '本', type: 'normal');
    await expectLater(
      db.customStatement('UPDATE memo_books SET type=? WHERE id=?', [
        'diary',
        a,
      ]),
      throwsA(anything),
    );
    final document = await repo.exportJson(a);
    final json =
        jsonDecode(utf8.decode(document.encode())) as Map<String, dynamic>;
    (json['books'] as List).single['type'] = 'diary';
    expect(
      () => MemoJsonDocument.decode(utf8.encode(jsonEncode(json))),
      throwsFormatException,
    );
    expect(
      () => MemoJsonDocument.validateSnapshotBook(
        MemoBook(
          id: a,
          name: '本',
          type: 'diary',
          createdAt: time,
          updatedAt: time,
        ),
        [],
      ),
      throwsFormatException,
    );
  });

  for (final type in ['normal', 'credentials']) {
    test('$type 普通笔记按编辑时间、卡片按手动顺序，日历保持编辑时间排序', () async {
      await repo.createBook(id: a, name: '排序测试', type: type);
      final target = await repo.target(a);
      final base = DateTime(2001, 1, 1);
      final ids = [b, e, '44444444-4444-4444-8444-444444444444'];
      final values = [
        for (var index = 0; index < ids.length; index++)
          MemoEntry(
            id: ids[index],
            memoBookId: a,
            bookType: type,
            title: '记录$index',
            createdAt: base.add(Duration(hours: index)).toUtc(),
            updatedAt: base.add(Duration(hours: index == 1 ? 1 : 3)).toUtc(),
            bodyJson: type == 'credentials'
                ? encodeMemoFields(const [
                    MemoField(label: '账号', value: 'demo'),
                    MemoField(label: '密码', value: 'demo-password'),
                  ])
                : '{"ops":[{"insert":"正文\\n"}]}',
            orderKey: type == 'credentials' ? index : null,
          ),
      ];
      for (final value in values) {
        await repo.saveEntry(value, target, preserveTimes: true);
      }
      final expected = [ids[0], ids[2], ids[1]];
      final listExpected = type == 'credentials' ? ids : expected;
      expect((await repo.getEntries(a)).map((entry) => entry.id), listExpected);
      expect(
        (await repo.watchEntries(a, limit: 2).first).map((entry) => entry.id),
        listExpected.take(2),
      );
      expect(
        (await repo.watchEntries(a, date: base).first).map((entry) => entry.id),
        expected,
      );
      await repo.saveEntry(values[1], target);
      expect(
        (await repo.watchEntries(a).first).first.id,
        type == 'credentials' ? ids[0] : ids[1],
      );
      expect(
        (await repo.watchEntries(a, date: base).first).map((entry) => entry.id),
        [ids[0], ids[2]],
      );
      expect(
        (await repo.getEntry(ids[1], target))!.createdAt,
        values[1].createdAt,
      );
    });
  }

  for (final type in ['normal', 'credentials']) {
    test('$type 日历按最后编辑日期计数，编辑后跨日跨月迁移', () async {
      await repo.createBook(id: a, name: '月历', type: type);
      await repo.createBook(id: b, name: '其他本', type: type);
      final target = await repo.target(a);
      final start = DateTime(2026, 9);
      final end = DateTime(2026, 10);
      final dates = [
        start.subtract(const Duration(milliseconds: 1)),
        start,
        end.subtract(const Duration(milliseconds: 1)),
        end,
        ...List.generate(101, (i) => DateTime(2026, 9, 9, 12, i)),
      ];
      String id(int index) =>
          '00000000-0000-4000-8000-${index.toString().padLeft(12, '0')}';
      MemoEntry value(int index, DateTime date, String bookId) => MemoEntry(
        id: id(index),
        memoBookId: bookId,
        bookType: type,
        title: '内容',
        createdAt: DateTime.utc(2001),
        updatedAt: date.toUtc(),
        bodyJson: type == 'credentials'
            ? encodeMemoFields(const [
                MemoField(label: '账号', value: 'demo'),
                MemoField(label: '密码', value: 'password'),
              ])
            : '{"ops":[{"insert":"正文\\n"}]}',
      );
      for (var i = 0; i < dates.length; i++) {
        await repo.saveEntry(
          value(i, dates[i], a),
          target,
          preserveTimes: true,
        );
      }
      await repo.saveEntry(
        value(1000, DateTime(2026, 9, 15), b),
        await repo.target(b),
        preserveTimes: true,
      );
      final stream = repo.watchCalendarCounts(a, start: start, until: end);
      expect(await stream.first, {
        start: 1,
        DateTime(2026, 9, 9): 101,
        DateTime(2026, 9, 30): 1,
      });
      expect(
        await repo
            .watchCalendarCounts(a, start: end, until: DateTime(2026, 11))
            .first,
        {end: 1},
      );
      expect(
        await repo
            .watchCalendarCounts(
              a,
              start: DateTime(2026, 9, 9),
              until: DateTime(2026, 9, 10),
            )
            .first,
        {DateTime(2026, 9, 9): 101},
      );
      expect(
        await repo
            .watchCalendarCounts(
              a,
              start: DateTime(2001),
              until: DateTime(2001, 2),
            )
            .first,
        isEmpty,
      );
      expect(await repo.watchEntries(a, date: DateTime(2001)).first, isEmpty);
      final removed = stream.firstWhere((counts) => !counts.containsKey(start));
      await repo.deleteEntry(id(1), target);
      expect(await removed, {
        DateTime(2026, 9, 9): 101,
        DateTime(2026, 9, 30): 1,
      });
      final added = stream.firstWhere(
        (counts) => counts.containsKey(DateTime(2026, 9, 20)),
      );
      await repo.saveEntry(
        value(2000, DateTime(2026, 9, 20), a),
        target,
        preserveTimes: true,
      );
      expect(await added, {
        DateTime(2026, 9, 9): 101,
        DateTime(2026, 9, 20): 1,
        DateTime(2026, 9, 30): 1,
      });
      final moved = stream.firstWhere(
        (counts) => !counts.containsKey(DateTime(2026, 9, 30)),
      );
      final nextDay = DateTime(2026, 10, 2);
      await repo.saveEntry(value(2, nextDay, a), target, preserveTimes: true);
      expect(await moved, {
        DateTime(2026, 9, 9): 101,
        DateTime(2026, 9, 20): 1,
      });
      expect(
        await repo.watchEntries(a, date: DateTime(2026, 9, 30)).first,
        isEmpty,
      );
      expect(
        (await repo.watchEntries(a, date: nextDay).first).single.id,
        id(2),
      );
      expect(
        await repo
            .watchCalendarCounts(a, start: end, until: DateTime(2026, 11))
            .first,
        {end: 1, nextDay: 1},
      );
      for (final date in (await stream.first).keys) {
        expect(await repo.watchEntries(a, date: date).first, isNotEmpty);
      }
      await (db.update(db.memoBooks)..where((book) => book.id.equals(a))).write(
        const MemoBooksCompanion(isHidden: d.Value(true)),
      );
      expect(await stream.first, isEmpty);
    });
  }

  test('云备忘录日历计数按账号隔离', () async {
    account = 'account-a';
    await repo.createBook(
      id: a,
      name: '云本',
      type: 'normal',
      storageMode: 'cloud',
    );
    await repo.saveEntry(entry(a), await repo.target(a), preserveTimes: true);
    final localTime = time.toLocal();
    final date = DateTime(localTime.year, localTime.month, localTime.day);
    final start = DateTime(localTime.year, localTime.month);
    final until = DateTime(localTime.year, localTime.month + 1);
    expect(
      await repo
          .watchCalendarCounts(
            a,
            start: start,
            until: until,
            accountId: account,
          )
          .first,
      {date: 1},
    );
    account = 'account-b';
    expect(
      await repo
          .watchCalendarCounts(
            a,
            start: start,
            until: until,
            accountId: account,
          )
          .first,
      isEmpty,
    );
    expect(
      await repo.watchCalendarCounts(a, start: start, until: until).first,
      isEmpty,
    );
  });

  test('JSON 单本原值往返、收据不复活删除条目与身份冲突', () async {
    await repo.createBook(id: a, name: '密码', type: 'credentials');
    await repo.createBook(id: b, name: '目标', type: 'credentials');
    await repo.saveEntry(
      entry(a, card: true),
      await repo.target(a),
      preserveTimes: true,
    );
    final file = MemoJsonDocument.decode((await repo.exportJson(a)).encode());
    const x = b;
    final target = await repo.target(x);
    final result = await repo.importJson(
      await repo.previewImport(file, target),
    );
    expect(result.imported, 1);
    final saved = (await repo.getEntries(x)).single;
    expect(saved.fields.map((field) => field.label).toList(), ['账号', '密码']);
    expect(saved.fields[0].value, ' \u0000用户 ');
    expect(saved.fields[1].value, ' \u0000🔑\n ');
    expect(saved.createdAt, time);
    await repo.deleteEntry(saved.id, await repo.target(x));
    final again = await repo.importJson(await repo.previewImport(file, target));
    expect(again.skipped, 1);
    expect(await repo.getEntries(x), isEmpty);
    expect((await repo.getBooks()).length, 2);
    final changed =
        jsonDecode(utf8.decode(file.encode())) as Map<String, dynamic>;
    // 正文变化后同一来源条目指纹不同，必须判为身份冲突而不能覆盖。
    changed['books'][0]['entries'][0]['body'] = {
      'fields': [
        {'label': '账号', 'value': 'different'},
      ],
    };
    final invalid = MemoJsonDocument.decode(utf8.encode(jsonEncode(changed)));
    await expectLater(
      repo.importJson(await repo.previewImport(invalid, target)),
      throwsStateError,
    );
    expect(await repo.getEntries(x), isEmpty);
  });

  // 未知字段不参与导入，已声明字段照常校验；重复键和深层嵌套等歧义仍然拒绝。
  test('JSON 未知字段被忽略，已声明字段照常导入', () async {
    await repo.createBook(id: a, name: '密码', type: 'credentials');
    await repo.createBook(id: b, name: '目标', type: 'credentials');
    await repo.saveEntry(
      entry(a, card: true),
      await repo.target(a),
      preserveTimes: true,
    );
    final raw =
        jsonDecode(utf8.decode((await repo.exportJson(a)).encode()))
            as Map<String, dynamic>;
    raw['future_header'] = 'v2';
    final book = (raw['books'] as List).first as Map<String, dynamic>;
    book['future_book_field'] = true;
    (book['entries'] as List).first['future_entry_field'] = 7;

    final file = MemoJsonDocument.decode(utf8.encode(jsonEncode(raw)));
    final result = await repo.importJson(
      await repo.previewImport(file, await repo.target(b)),
    );

    expect(result.imported, 1);
    final saved = (await repo.getEntries(b)).single;
    expect(saved.fields.map((field) => field.label).toList(), ['账号', '密码']);
    expect(saved.fields[0].value, ' \u0000用户 ');
    expect(saved.fields[1].value, ' \u0000🔑\n ');
    expect(saved.createdAt, time);
  });

  test('JSON 重复键、深层结构、关系错误拒绝；预览后变化与换号零写入', () async {
    expect(
      () =>
          MemoJsonDocument.decode(utf8.encode('{"format":1,"for\\u006dat":2}')),
      throwsFormatException,
    );
    expect(
      () => MemoJsonDocument.decode(utf8.encode('${'[' * 33}${']' * 33}')),
      throwsFormatException,
    );
    await repo.createBook(id: a, name: '原本', type: 'normal');
    await repo.createBook(id: b, name: '目标', type: 'normal');
    await repo.saveEntry(entry(a), await repo.target(a));
    final file = await repo.exportJson(a);
    final target = await repo.target(b);
    var preview = await repo.previewImport(file, target);
    await repo.renameBook(await repo.target(b), '变化');
    await expectLater(repo.importJson(preview), throwsStateError);
    expect(await repo.getEntries(b), isEmpty);
    preview = await repo.previewImport(file, target);
    generation++;
    await expectLater(repo.importJson(preview), throwsStateError);
    expect(await repo.getEntries(b), isEmpty);
  });

  test('多本文件拒绝；单本导入中途失败时内容、回执及云队列全部回滚', () async {
    account = 'owner';
    await repo.createBook(id: a, name: '来源', type: 'normal');
    await repo.createBook(
      id: b,
      name: '目标',
      type: 'normal',
      storageMode: 'cloud',
    );
    await repo.saveEntry(entry(a), await repo.target(a));
    await repo.saveEntry(
      entry(a, id: '44444444-4444-4444-8444-444444444444'),
      await repo.target(a),
    );
    final file = await repo.exportJson(a);
    final multiple = {
      ...file.json,
      'books': [
        ...file.books.map((book) => book.json),
        ...file.books.map((book) => book.json),
      ],
    };
    expect(
      () => MemoJsonDocument.decode(utf8.encode(jsonEncode(multiple))),
      throwsFormatException,
    );
    final preview = await repo.previewImport(file, await repo.target(b));
    final pending = await db.select(db.syncChanges).get();
    await db.customStatement(
      "CREATE TRIGGER memo_import_failure BEFORE INSERT ON memo_entries WHEN NEW.memo_book_id = '$b' AND EXISTS (SELECT 1 FROM memo_entries WHERE memo_book_id = '$b') BEGIN SELECT RAISE(ABORT, 'injected'); END",
    );
    await expectLater(repo.importJson(preview), throwsA(anything));
    expect(await repo.getEntries(b, accountId: account), isEmpty);
    expect(await db.select(db.memoImportReceipts).get(), isEmpty);
    expect(await db.select(db.syncChanges).get(), pending);
    expect((await repo.getEntries(a)).length, 2);
  });

  test('毫秒时间、正文空白与原始凭据无损保存，卡片墓碑不占活动顺序', () async {
    await repo.createBook(id: a, name: '同名', type: 'normal');
    await repo.createBook(id: b, name: '同名', type: 'credentials');
    final noteTarget = await repo.target(a), cardTarget = await repo.target(b);
    await repo.saveEntry(entry(a), noteTarget, preserveTimes: true);
    final note = (await repo.getEntries(a)).single;
    expect(note.createdAt, time);
    expect(note.bodyJson, entry(a).bodyJson);
    // 普通笔记：正文必须是 delta，顺序键必须为空。
    expect(note.orderKey, isNull);
    expect(
      () => validateMemoDelta(jsonDecode(note.bodyJson!)),
      returnsNormally,
    );
    await repo.saveEntry(
      entry(b, id: a, card: true),
      cardTarget,
      preserveTimes: true,
    );
    final card = (await repo.getEntries(b)).single;
    expect(card.fields.map((field) => field.label).toList(), ['账号', '密码']);
    expect(card.fields[0].value, ' \u0000用户 ');
    expect(card.fields[1].value, ' \u0000🔑\n ');
    expect(card.orderKey, 0);
    await repo.deleteEntry(a, cardTarget);
    await repo.saveEntry(entry(b, id: b, card: true), cardTarget);
    expect((await repo.getEntries(b)).single.orderKey, 0);
    final deleted = await (db.select(
      db.memoEntries,
    )..where((entry) => entry.id.equals(a))).getSingle();
    expect(deleted.deletedAt, isNotNull);
    expect(deleted.body, card.bodyJson);
    expect((await repo.getBook(b))!.entryCount, 1);
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });
  test('账号密码列表搜索：命中字段名称与任意字段取值，普通笔记不参与', () async {
    await repo.createBook(id: a, name: '账号本', type: 'credentials');
    final target = await repo.target(a);
    const cards = <String, List<MemoField>>{
      '44444444-4444-4444-8444-444444444444': [
        MemoField(label: '邮箱', value: 'someone@example.com'),
        MemoField(label: '密码', value: 'first'),
      ],
      '55555555-5555-4555-8555-555555555555': [
        MemoField(label: '账号', value: 'demo'),
        MemoField(label: '密码', value: 'second'),
      ],
      '66666666-6666-4666-8666-666666666666': [
        MemoField(label: '账号', value: 'demo'),
        MemoField(label: '提示', value: '家里那只猫'),
      ],
    };
    var index = 0;
    for (final card in cards.entries) {
      await repo.saveEntry(
        MemoEntry(
          id: card.key,
          memoBookId: a,
          bookType: 'credentials',
          title: '卡片$index',
          createdAt: time,
          updatedAt: time,
          bodyJson: encodeMemoFields(card.value),
        ),
        target,
      );
      index++;
    }
    Future<List<String>> find(String keyword) => repo
        .watchCredentialEntries(bookId: a, search: keyword)
        .first
        .then((entries) => entries.map((entry) => entry.id).toList());

    expect(await find('邮箱'), [
      '44444444-4444-4444-8444-444444444444',
    ], reason: '字段名称参与搜索');
    expect(await find('example.com'), [
      '44444444-4444-4444-8444-444444444444',
    ], reason: '字段取值参与搜索');
    expect((await find('demo')).toSet(), {
      '55555555-5555-4555-8555-555555555555',
      '66666666-6666-4666-8666-666666666666',
    }, reason: '第一个字段之外的同名字段取值同样命中');
    expect(await find('家里那只猫'), [
      '66666666-6666-4666-8666-666666666666',
    ], reason: '预览之外的第三个字段仍可搜索');
    expect(await find('card'), isEmpty, reason: '名称由界面显示，搜索只按字段名称与取值匹配');
    expect(await find(''), hasLength(3), reason: '空关键词保持全量口径');
    expect(await find('%'), isEmpty, reason: '通配符按字面匹配，不放大结果集');
    // 名称只用于显示：卡片名称与字段内容都不含关键词时不得命中。
    expect(await find('卡片0'), isEmpty, reason: '标题不参与搜索');
    expect(await find('EXAMPLE'), [
      '44444444-4444-4444-8444-444444444444',
    ], reason: '取值匹配大小写不敏感，避免英文内容必须记忆大小写');
  });

  test('账号密码列表搜索只返回当前账号域的内容', () async {
    account = 'owner';
    await repo.createBook(
      id: a,
      name: '云本',
      type: 'credentials',
      storageMode: 'cloud',
    );
    final target = await repo.target(a);
    await repo.saveEntry(
      MemoEntry(
        id: e,
        memoBookId: a,
        bookType: 'credentials',
        title: '邮箱',
        createdAt: time,
        updatedAt: time,
        bodyJson: encodeMemoFields(const [
          MemoField(label: '邮箱', value: 'owner@example.com'),
        ]),
      ),
      target,
    );
    expect(
      (await repo
              .watchCredentialEntries(
                bookId: a,
                accountId: account,
                search: '邮箱',
              )
              .first)
          .map((entry) => entry.id),
      [e],
      reason: '关键词过滤不能挤掉账号域绑定，参数顺序必须与占位符一致',
    );
    expect(
      await repo
          .watchCredentialEntries(
            bookId: a,
            accountId: 'stranger',
            search: '邮箱',
          )
          .first,
      isEmpty,
    );
  });

  test('父本过滤、不可变父子身份、同账号重新登录均守住固定目标', () async {
    account = 'owner';
    await repo.createBook(
      id: a,
      name: '云本',
      type: 'normal',
      storageMode: 'cloud',
    );
    final target = await repo.target(a);
    await repo.saveEntry(entry(a), target);
    final changes = await db.select(db.syncChanges).get();
    expect(changes.map((c) => c.entityType), ['memo_book', 'memo_entry']);
    expect(
      changes.every((c) => c.memoBookId == a && c.accountId == 'owner'),
      isTrue,
    );
    expect(await repo.getBooks(accountId: 'stranger'), isEmpty);
    expect(await repo.getEntries(a, accountId: 'stranger'), isEmpty);
    generation++;
    await expectLater(repo.saveEntry(entry(a), target), throwsStateError);
    account = 'stranger';
    await expectLater(repo.target(a), throwsStateError);
    await expectLater(
      db.customStatement('UPDATE memo_books SET type=? WHERE id=?', [
        'credentials',
        a,
      ]),
      throwsA(anything),
    );
    await expectLater(
      db.customStatement('UPDATE memo_entries SET memo_book_id=? WHERE id=?', [
        b,
        e,
      ]),
      throwsA(anything),
    );
    expect(await db.select(db.syncChanges).get(), hasLength(2));
  });
  test('日期按本地午夜区间查询且列表不加载正文，删除预览变化拒绝执行', () async {
    await repo.createBook(id: a, name: '本', type: 'normal');
    final target = await repo.target(a);
    await repo.saveEntry(entry(a), target, preserveTimes: true);
    final rows = await repo.watchEntries(a, date: time.toLocal()).first;
    expect(rows.single.id, e);
    expect(rows.single.bodyJson, isNull);
    expect(rows.single.orderKey, isNull, reason: '普通笔记不带顺序键');
    expect(rows.single.previewText, '正文😀\n\n');
    await expectLater(
      repo.deleteBook(target, expectedCount: 0),
      throwsStateError,
    );
    await repo.deleteBook(target, expectedCount: 1);
    expect(await db.select(db.memoEntries).get(), isEmpty);
  });
  test('数据库约束拒绝形状错误，保存失败不触及父本或产生队列', () async {
    await repo.createBook(id: a, name: '本', type: 'normal', createdAt: time);
    final target = await repo.target(a);
    await expectLater(
      repo.saveEntry(entry(a, card: true), target),
      throwsStateError,
    );
    // 卡片形状挂在普通本下：父子类型外键必须拒绝。
    await expectLater(
      db
          .into(db.memoEntries)
          .insert(
            MemoEntriesCompanion.insert(
              id: e,
              memoBookId: a,
              bookType: 'credentials',
              title: '错挂',
              bodyFormat: const d.Value('fields_v1'),
              body: d.Value(
                encodeMemoFields(const [MemoField(label: '账号', value: 'x')]),
              ),
              orderKey: const d.Value(0),
              createdAt: time,
              updatedAt: time,
            ),
          ),
      throwsA(anything),
    );
    // 普通笔记带顺序键：正文与顺序键的互斥 CHECK 必须拒绝。
    await expectLater(
      db
          .into(db.memoEntries)
          .insert(
            MemoEntriesCompanion.insert(
              id: e,
              memoBookId: a,
              bookType: 'normal',
              title: '普通笔记',
              bodyFormat: const d.Value('delta_v1'),
              body: const d.Value('{"ops":[{"insert":"正文\\n"}]}'),
              orderKey: const d.Value(0),
              createdAt: time,
              updatedAt: time,
            ),
          ),
      throwsA(anything),
    );
    expect((await repo.getBook(a))!.updatedAt, time);
    expect(await db.select(db.memoEntries).get(), isEmpty);
  });
}
