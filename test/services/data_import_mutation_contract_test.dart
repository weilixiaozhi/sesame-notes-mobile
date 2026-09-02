import 'package:decimal/decimal.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/sync/change_recorder_impl.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/settings/infrastructure/data_import_service.dart';

import '../helpers/test_isolation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SesameDatabase db;
  late LocalRepository repo;
  late DataImportService service;
  late String cloudLedgerId;

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.forTesting(NativeDatabase.memory());
    repo = LocalRepository(db, changeTracker: ChangeRecorderImpl(db));
    service = DataImportService();
    cloudLedgerId = await repo.createLedger(name: '导入目标', storageMode: 'cloud');
    await db.delete(db.syncChanges).go();
  });

  tearDown(() async {
    await db.close();
  });

  /// 构造同时覆盖分类创建与交易批量落库的最小导入数据。
  ImportData importData(String suffix) => ImportData(
    categories: [
      ImportCategory(name: '餐饮-$suffix', kind: 'expense'),
      ImportCategory(
        name: '早餐-$suffix',
        kind: 'expense',
        level: 2,
        parentName: '餐饮-$suffix',
      ),
    ],
    transactions: [
      ImportTransaction(
        type: 'expense',
        amount: Decimal.parse('12.34'),
        categoryName: '早餐-$suffix',
        categoryParentName: '餐饮-$suffix',
        categoryKind: 'expense',
        happenedAt: DateTime.utc(2026, 8, 24),
        syncId: 'tx-$suffix',
      ),
    ],
  );

  /// 返回当前待推送变更的实体类型，忽略 mutationId 等随机字段。
  Future<List<String>> pendingEntityTypes() async {
    final rows = await db.select(db.syncChanges).get();
    return rows.map((row) => row.entityType).toList();
  }

  test('普通导入云账本：新分类与新交易均登记 mutation', () async {
    final result = await service.importData(
      repo,
      cloudLedgerId,
      importData('normal'),
    );

    expect(result.inserted, 1);
    expect(result.failed, 0);
    expect(
      pendingEntityTypes(),
      completion(unorderedEquals(['category', 'category', 'transaction'])),
    );
  });

  test('恢复导入 recordChanges=false：新分类与新交易均不反向登记 mutation', () async {
    final result = await service.importData(
      repo,
      cloudLedgerId,
      importData('restore'),
      recordChanges: false,
    );

    expect(result.inserted, 1);
    expect(result.failed, 0);
    expect(
      pendingEntityTypes(),
      completion(isEmpty),
      reason: '恢复只回填本地快照，分类和交易都不能被当成新编辑重新推云',
    );
  });
}
