import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_api_client/sesame_api_client.dart'
    hide Category, Transaction, RecurringTransaction, ExchangeRateOverride;
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/sync_operation_failure.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';
import 'package:sesame_notes/sync/internal/projection_handler.dart';
import 'package:sesame_notes/sync/internal/sync_runtime.dart';

import '../helpers/test_isolation.dart';

const _viewer = '10000000-0000-4000-8000-000000000001';
const _owner = '10000000-0000-4000-8000-000000000002';
const _otherOwner = '10000000-0000-4000-8000-000000000003';
const _category = '20000000-0000-4000-8000-000000000001';
const _sharedBook = '30000000-0000-4000-8000-000000000001';
const _otherBook = '30000000-0000-4000-8000-000000000002';

/// 构造真实分类事件正文，版本时间保留同秒中的毫秒差异。
Map<String, dynamic> _payload(String owner, String name, int millis) => {
  'id': _category,
  'owner_id': owner,
  'name': name,
  'kind': 'expense',
  'level': 1,
  'sort_order': 0,
  'icon': null,
  'parent_id': null,
  'updated_at': DateTime.utc(2026, 10, 11, 1, 2, 3, millis).toIso8601String(),
  'deleted_at': null,
};

/// 验证私有目录、共享账本镜像和实体时钟通过真实 SQLite 投影保持隔离。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late SesameApiClient client;
  late AccountingProjection projection;

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    client = SesameApiClient();
    projection = AccountingProjection(
      SyncRuntime(
        client: client,
        db: db,
        deviceId: 'ownership-device',
        currentAccountIdGetter: () => _viewer,
        sessionGenerationGetter: null,
        generation: null,
      ),
      AccountingProjectionPorts(
        accountingBlockedLedgerIds: (_) async => <String>{},
        operationsQuarantineLedger:
            (
              _,
              _, {
              bool stale = false,
              bool deleted = false,
              DateTime? remoteDeletedAt,
            }) async {},
        payloadCategoryLevel: (value) => value as int,
        payloadDeleteTime: (payload) =>
            DateTime.parse(payload['deleted_at'] as String),
      ),
    );
    for (final (scope, name) in [
      (_viewer, '本人餐饮'),
      (_owner, '另一账号离线草稿'),
      (null, '纯本地餐饮'),
    ]) {
      await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: _category,
              name: name,
              kind: 'expense',
              level: 1,
              scopeAccountId: d.Value(scope),
              updatedAt: DateTime.utc(2026),
            ),
          );
    }
    for (final (id, owner) in [
      (_sharedBook, _owner),
      (_otherBook, _otherOwner),
    ]) {
      await db
          .into(db.ledgers)
          .insert(
            LedgersCompanion.insert(
              id: id,
              name: '共享账本',
              storageMode: const d.Value('cloud'),
              scopeAccountId: const d.Value(_viewer),
              ownerAccountId: d.Value(owner),
              role: const d.Value('editor'),
              updatedAt: DateTime.utc(2026),
            ),
          );
    }
  });
  tearDown(() async {
    client.dio.close(force: true);
    await db.close();
  });

  /// 读取明确目录，不能使用 UUID 单独定位同账号以外的行。
  Future<Category> privateCategory(String? scope) =>
      (db.select(db.categories)..where(
            (c) => c.id.equals(_category) & categoryScopePredicate(c, scope),
          ))
          .getSingle();

  test('共享分类同UUID只写所属账本镜像，私有、本地和另一共享所有者保持原样', () async {
    final before = await db.select(db.categories).get();
    await projection.applyCategory(
      _category,
      'upsert',
      _payload(_owner, '共享餐饮', 920),
    );
    expect(await db.select(db.categories).get(), before);
    final mirror = await db.select(db.sharedLedgerCategories).getSingle();
    expect((mirror.ledgerId, mirror.name), (_sharedBook, '共享餐饮'));
    expect(mirror.updatedAt.millisecond, 920);
    expect(mirror.deletedAt, isNull);
  });

  test('缺少所有者的旧服务器分类事件拒绝落库，不能猜成本人分类', () async {
    final before = await db.select(db.categories).get();
    final payload = _payload(_owner, '归属缺失', 950)..remove('owner_id');
    await expectLater(
      projection.applyCategory(_category, 'upsert', payload),
      throwsA(
        isA<SyncOperationFailure>().having(
          (error) => error.code,
          '归属原因',
          'CLOUD_OWNERSHIP_MISSING',
        ),
      ),
    );
    expect(await db.select(db.categories).get(), before);
    expect(await db.select(db.sharedLedgerCategories).get(), isEmpty);
  });

  test('共享墓碑950ms阻止旧920ms复活，更晚980ms明确恢复可以生效', () async {
    await projection.applyCategory(
      _category,
      'upsert',
      _payload(_owner, '原共享分类', 920),
    );
    final tomb = _payload(_owner, '删除的共享分类', 950);
    tomb['deleted_at'] = tomb['updated_at'];
    await projection.applyCategory(_category, 'delete', tomb);
    await projection.applyCategory(
      _category,
      'upsert',
      _payload(_owner, '过期恢复', 920),
    );
    var mirror = await db.select(db.sharedLedgerCategories).getSingle();
    expect(mirror.name, '删除的共享分类');
    expect(mirror.deletedAt?.millisecond, 950);
    expect(mirror.updatedAt.millisecond, 950);
    await projection.applyCategory(
      _category,
      'upsert',
      _payload(_owner, '明确恢复', 980),
    );
    await projection.applyCategory(_category, 'delete', tomb);
    mirror = await db.select(db.sharedLedgerCategories).getSingle();
    expect(mirror.name, '明确恢复');
    expect(mirror.deletedAt, isNull);
    expect(mirror.updatedAt.millisecond, 980);
    expect((await privateCategory(_viewer)).deletedAt, isNull);
  });

  test('本人完整分类状态精确更新本人目录并登记事实，不写其他缓存或共享镜像', () async {
    await projection.applyCategory(
      _category,
      'upsert',
      _payload(_viewer, '本人更新', 980),
    );
    final own = await privateCategory(_viewer);
    expect((own.name, own.cloudRegistered), ('本人更新', true));
    expect(own.updatedAt.millisecond, 980);
    expect((await privateCategory(_owner)).name, '另一账号离线草稿');
    expect((await privateCategory(null)).name, '纯本地餐饮');
    expect(await db.select(db.sharedLedgerCategories).get(), isEmpty);
  });
}
