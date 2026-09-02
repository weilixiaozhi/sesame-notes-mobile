// 同步冲突展示模型测试。
//
// 需求锚点：UI 不得依赖 Drift 生成的 Row 类型（SyncConflict），只能消费
// data 层暴露的纯展示模型 SyncConflictView；Row → View 的映射由 Provider
// 承担，schema 变更不得上浮到页面。
library;

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import '../../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => resetGlobalTestState());

  late SesameDatabase db;
  late LocalRepository repo;

  setUp(() async {
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  /// 插入一条 OPEN 冲突行（Drift Row 写入，用于验证 Provider 的映射结果）。
  Future<void> insertConflict(String ledgerId) => db
      .into(db.syncConflicts)
      .insert(
        SyncConflictsCompanion.insert(
          id: 'conflict-1',
          ledgerId: ledgerId,
          entityType: 'transaction',
          entityId: 'tx-abcdef123456',
          localPayload: '{"amount":"10"}',
          remotePayload: '{"amount":"20"}',
          baseRevision: 3,
          remoteRevision: 9,
          localMutationId: 'mutation-1',
        ),
      );

  /// 构造测试容器并保持 [currentLedgerProvider] 订阅。
  ///
  /// 冲突 Provider 读的是 `currentLedgerProvider.value`：Stream 首帧未落地时
  /// 该值为 null，会让「本地账本」「已解决冲突」两个用例假通过。这里显式
  /// 订阅并等首帧，保证断言走的是归属判定而非空值短路。
  Future<ProviderContainer> containerFor(String ledgerId) async {
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        repositoryProvider.overrideWithValue(repo),
        currentLedgerIdProvider.overrideWithBuild((ref, notifier) => ledgerId),
      ],
    );
    final sub = container.listen(currentLedgerProvider, (_, _) {});
    addTearDown(sub.close);
    await container.read(currentLedgerProvider.future);
    return container;
  }

  test('云端账本 OPEN 冲突 → 映射为 SyncConflictView，字段与 Row 一致', () async {
    final ledgerId = await repo.createLedger(
      name: '云端账本',
      storageMode: 'cloud',
    );
    await insertConflict(ledgerId);

    final container = await containerFor(ledgerId);
    addTearDown(container.dispose);

    final views = await container.read(ledgerOpenConflictsProvider.future);

    expect(views, hasLength(1));
    final view = views.single;
    expect(view, isA<SyncConflictView>());
    expect(view.id, 'conflict-1');
    expect(view.entityId, 'tx-abcdef123456');
    expect(view.baseRevision, 3);
    expect(view.remoteRevision, 9);
  });

  test('本地账本 → 不产生冲突列表', () async {
    final ledgerId = await repo.createLedger(
      name: '本地账本',
      storageMode: 'local',
    );
    await insertConflict(ledgerId);

    final container = await containerFor(ledgerId);
    addTearDown(container.dispose);

    expect(await container.read(ledgerOpenConflictsProvider.future), isEmpty);
  });

  test('已解决的冲突（非 OPEN）不进入列表', () async {
    final ledgerId = await repo.createLedger(
      name: '云端账本',
      storageMode: 'cloud',
    );
    await insertConflict(ledgerId);
    await (db.update(db.syncConflicts)..where((c) => c.id.equals('conflict-1')))
        .write(SyncConflictsCompanion(status: d.Value('RESOLVED_LOCAL')));

    final container = await containerFor(ledgerId);
    addTearDown(container.dispose);

    expect(await container.read(ledgerOpenConflictsProvider.future), isEmpty);
  });
}
