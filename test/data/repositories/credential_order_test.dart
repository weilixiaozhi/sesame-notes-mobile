import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/memo_order.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

/// 卡片排序通过真实数据库验证默认展示、跨端载荷和事务边界。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const bookId = '11111111-1111-4111-8111-111111111111';
  const ids = [
    '22222222-2222-4222-8222-222222222222',
    '33333333-3333-4333-8333-333333333333',
    '44444444-4444-4444-8444-444444444444',
    '55555555-5555-4555-8555-555555555555',
  ];
  late SesameDatabase db;
  late MemoRepository repository;
  String? account;
  var generation = 0;
  final time = DateTime.utc(2026, 1, 1);
  const newId = '66666666-6666-4666-8666-666666666666';

  /// 新建卡片由仓储分配顺序，导入卡片可以明确携带交换文件中的顺序键。
  MemoEntry newCard({String id = newId, int? orderKey}) => MemoEntry(
    id: id,
    memoBookId: bookId,
    bookType: memoBookTypeCredentials,
    title: '新卡片',
    bodyJson: '{"fields":[]}',
    createdAt: time,
    updatedAt: time,
    orderKey: orderKey,
  );

  setUp(() {
    account = 'owner';
    generation = 0;
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repository = MemoRepository(
      db,
      accountIdGetter: () => account,
      generationGetter: () => generation,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => account),
    );
  });
  tearDown(() => db.close());

  /// 乱序的更新时间用于证明默认展示依赖同步顺序，正文保持独立可核对。
  Future<void> create() async {
    await repository.createBook(
      id: bookId,
      name: '账号密码',
      type: memoBookTypeCredentials,
      storageMode: 'cloud',
    );
    final target = await repository.target(bookId);
    for (var index = 0; index < ids.length; index++) {
      await repository.saveEntry(
        MemoEntry(
          id: ids[index],
          memoBookId: bookId,
          bookType: memoBookTypeCredentials,
          title: '卡片$index',
          bodyJson: jsonEncode({
            'fields': [
              {'label': '密码', 'value': '内容$index'},
            ],
          }),
          createdAt: time,
          updatedAt: time.add(Duration(days: index)),
          orderKey: index,
        ),
        target,
        preserveTimes: true,
      );
    }
    await db.delete(db.syncChanges).go();
  }

  /// 列表查询只读摘要，排序结果由业务顺序决定。
  Future<List<MemoEntry>> list({CredentialSort sort = CredentialSort.manual}) =>
      repository
          .watchCredentialEntries(
            bookId: bookId,
            accountId: account,
            sort: sort,
          )
          .first;

  test('默认按同步顺序，最近编辑作为独立视图，编辑不会改变手动顺序', () async {
    await create();
    expect((await list()).map((entry) => entry.id), ids);
    expect(
      (await list(sort: CredentialSort.updated)).map((entry) => entry.id),
      ids.reversed,
    );
    final target = await repository.target(bookId);
    await repository.saveEntry(
      (await repository.getEntry(ids[1], target))!,
      target,
    );
    expect((await list()).map((entry) => entry.id), ids);
    expect((await list(sort: CredentialSort.updated)).first.id, ids[1]);
  });

  test('搜索及分页子集重排保留隐藏卡片位置，生成完整可同步载荷', () async {
    await create();
    final before = await repository.getEntries(bookId, accountId: account);
    final visible = (await list())
        .where((entry) => entry.id == ids[0] || entry.id == ids[2])
        .toList();
    await repository.reorderCredentials(
      await repository.target(bookId),
      visible,
      [ids[2], ids[0]],
    );
    expect((await list()).map((entry) => entry.id), [
      ids[2],
      ids[1],
      ids[0],
      ids[3],
    ]);
    final after = {
      for (final entry in await repository.getEntries(
        bookId,
        accountId: account,
      ))
        entry.id: entry,
    };
    for (final entry in before) {
      expect(after[entry.id]!.bodyJson, entry.bodyJson);
      expect(after[entry.id]!.createdAt, entry.createdAt);
    }
    final changes = await db.select(db.syncChanges).get();
    expect(changes.length, 2);
    for (final change in changes) {
      final payload = jsonDecode(change.payload) as Map<String, dynamic>;
      expect(payload['order_key'], after[change.entityId]!.orderKey.toString());
      expect(payload['body'], after[change.entityId]!.body);
    }
  });

  test('从最近编辑视图拖动时整段采用用户看到的顺序', () async {
    await create();
    final visible = await list(sort: CredentialSort.updated);
    await repository.reorderCredentials(
      await repository.target(bookId),
      visible,
      [ids[2], ids[3], ids[1], ids[0]],
    );
    expect((await list()).map((entry) => entry.id), [
      ids[2],
      ids[3],
      ids[1],
      ids[0],
    ]);
  });

  test('过期快照、重复身份和会话切换均不能修改顺序', () async {
    await create();
    final target = await repository.target(bookId);
    final snapshot = await list();
    await repository.saveEntry(
      (await repository.getEntry(ids[0], target))!,
      target,
    );
    final before = await db.select(db.memoEntries).get();
    final queueBefore = await db.select(db.syncChanges).get();
    await expectLater(
      repository.reorderCredentials(target, snapshot, ids.reversed.toList()),
      throwsStateError,
    );
    await expectLater(
      repository.reorderCredentials(target, await list(), [
        ids[0],
        ids[0],
        ids[2],
        ids[3],
      ]),
      throwsStateError,
    );
    generation++;
    await expectLater(
      repository.reorderCredentials(
        target,
        await list(),
        ids.reversed.toList(),
      ),
      throwsStateError,
    );
    expect(await db.select(db.memoEntries).get(), before);
    expect(await db.select(db.syncChanges).get(), queueBefore);
  });

  test('中途写入失败时全部顺序和同步意图一起回滚', () async {
    await create();
    final target = await repository.target(bookId);
    final snapshot = await list();
    final before = await db.select(db.memoEntries).get();
    await db.customStatement(
      "CREATE TRIGGER fail_reorder BEFORE UPDATE OF order_key ON memo_entries WHEN NEW.id='${ids[2]}' BEGIN SELECT RAISE(ABORT, 'TEST_REORDER_FAILURE'); END",
    );
    await expectLater(
      repository.reorderCredentials(target, snapshot, ids.reversed.toList()),
      throwsStateError,
    );
    expect(await db.select(db.memoEntries).get(), before);
    expect(await db.select(db.syncChanges).get(), isEmpty);
  });

  test('大于双精度安全范围的顺序键以整数精确比较并重编连续顺序', () async {
    await create();
    await db.customStatement(
      'UPDATE memo_entries SET order_key=9007199254740992 + order_key',
    );
    final snapshot = await list();
    expect(snapshot.map((entry) => entry.id), ids);
    await repository.reorderCredentials(
      await repository.target(bookId),
      snapshot,
      ids.reversed.toList(),
    );
    expect((await list()).map((entry) => entry.orderKey), [0, 1, 2, 3]);
  });

  test('新建卡片精确追加在大整数顺序末尾，不依赖当前设备时间', () async {
    await create();
    await db.customStatement(
      'UPDATE memo_entries SET order_key=9007199254740992 + order_key',
    );
    await repository.saveEntry(newCard(), await repository.target(bookId));
    final entries = await list();
    expect(entries.last.id, newId);
    expect(entries.last.orderKey, 9007199254740996);
  });

  test('最大64位顺序拒绝新增且不产生部分写入，重排后可恢复追加', () async {
    await create();
    await db.customStatement(
      "UPDATE memo_entries SET order_key=9223372036854775807 WHERE id='${ids.last}'",
    );
    final target = await repository.target(bookId);
    final snapshot = await list();
    await expectLater(
      repository.saveEntry(newCard(), target),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          '错误码',
          'MEMO_ORDER_CAPACITY',
        ),
      ),
    );
    expect(await repository.getEntry(newId, target), isNull);
    expect(await db.select(db.syncChanges).get(), isEmpty);
    await repository.reorderCredentials(
      target,
      snapshot,
      ids.reversed.toList(),
    );
    await repository.saveEntry(newCard(), target);
    expect((await list()).last.id, newId);
    expect((await list()).last.orderKey, 4);
  });

  test('最大顺序的已删除卡片不占用活动列表的追加位置', () async {
    await create();
    await db.customStatement(
      "UPDATE memo_entries SET order_key=9223372036854775807 WHERE id='${ids.last}'",
    );
    final target = await repository.target(bookId);
    await repository.deleteEntry(ids.last, target);
    await repository.saveEntry(newCard(), target);
    expect((await list()).last.id, newId);
    expect((await list()).last.orderKey, 3);
  });

  test('导入明确顺序键时保留文件顺序，不参与新建编号分配', () async {
    await create();
    await db.customStatement(
      "UPDATE memo_entries SET order_key=9223372036854775807 WHERE id='${ids.last}'",
    );
    final target = await repository.target(bookId);
    await repository.saveEntry(
      newCard(orderKey: 8),
      target,
      preserveTimes: true,
    );
    expect((await repository.getEntry(newId, target))!.orderKey, 8);
  });

  test('单卡达到最大顺序时新增受阻，原卡身份与正文完整保留', () async {
    await repository.createBook(
      id: bookId,
      name: '账号密码',
      type: memoBookTypeCredentials,
      storageMode: 'cloud',
    );
    final target = await repository.target(bookId);
    final original = newCard(orderKey: 9223372036854775807);
    await repository.saveEntry(original, target, preserveTimes: true);
    final queueBefore = await db.select(db.syncChanges).get();
    await expectLater(
      repository.saveEntry(newCard(id: ids.first), target),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          '错误码',
          'MEMO_ORDER_CAPACITY',
        ),
      ),
    );
    final entries = await repository.getEntries(bookId, accountId: account);
    expect(entries, hasLength(1));
    expect(entries.single.id, original.id);
    expect(entries.single.bodyJson, original.bodyJson);
    expect(entries.single.orderKey, 9223372036854775807);
    expect(await db.select(db.syncChanges).get(), queueBefore);
  });
}
