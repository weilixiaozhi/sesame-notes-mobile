import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/support/category_scope.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// 异常日志保留当前结构约束断言的堆栈，便于区分实现失败和夹具失败。
  Future<void> verifyOwnership(Future<void> Function() work) async {
    try {
      await work();
    } catch (error, stack) {
      logger.error(
        'CategorySchemaTest',
        '分类归属回归失败',
        safeErrorSummary(error),
        stack,
      );
      rethrow;
    }
  }

  test(
    '同一分类编号按账号与本地分别保存，SQL账号键不允许空值且本地只保留一份',
    () => verifyOwnership(() async {
      final db = SesameDatabase.withExecutor(NativeDatabase.memory());
      try {
        for (final scope in <String?>[null, 'A', 'B']) {
          await db
              .into(db.categories)
              .insert(
                CategoriesCompanion.insert(
                  id: 'template-id',
                  name: '${scope ?? '本地'}类别',
                  kind: 'expense',
                  level: 1,
                  updatedAt: DateTime.utc(2026, 10, 11, 0, 0, 0, 950),
                  scopeAccountId: d.Value(scope),
                ),
              );
        }
        expect(await db.select(db.categories).get(), hasLength(3));
        for (final scope in <String?>[null, 'A', 'B']) {
          final row = await (db.select(
            db.categories,
          )..where((c) => categoryScopePredicate(c, scope))).getSingle();
          expect(row.scopeAccountId, scope);
          expect(row.name, '${scope ?? '本地'}类别');
          expect(row.updatedAt, DateTime.utc(2026, 10, 11, 0, 0, 0, 950));
        }
        await expectLater(
          db
              .into(db.categories)
              .insert(
                CategoriesCompanion.insert(
                  id: 'template-id',
                  name: '重复本地',
                  kind: 'expense',
                  level: 1,
                  updatedAt: DateTime.utc(2026, 10, 11),
                ),
              ),
          throwsA(isA<SqliteException>()),
        );
        await expectLater(
          db.customStatement(
            "INSERT INTO categories(id,name,kind,level,updated_at,scope_account_id) VALUES('invalid','错误','expense',1,1000,NULL)",
          ),
          throwsA(isA<SqliteException>()),
        );
      } finally {
        await db.close();
      }
    }),
  );

  test(
    '共享分类镜像保留版本时间与墓碑的毫秒精度',
    () => verifyOwnership(() async {
      final db = SesameDatabase.withExecutor(NativeDatabase.memory());
      final updated = DateTime.utc(2026, 10, 11, 0, 0, 0, 950);
      final deleted = updated.add(const Duration(milliseconds: 20));
      try {
        await db
            .into(db.sharedLedgerCategories)
            .insert(
              SharedLedgerCategoriesCompanion.insert(
                ledgerId: 'shared-book',
                categoryId: 'mirror',
                name: '共享分类',
                kind: 'expense',
                updatedAt: updated,
                deletedAt: d.Value(deleted),
              ),
            );
        final mirror = await db.select(db.sharedLedgerCategories).getSingle();
        expect(mirror.updatedAt, updated);
        expect(mirror.deletedAt, deleted);
      } finally {
        await db.close();
      }
    }),
  );
}
