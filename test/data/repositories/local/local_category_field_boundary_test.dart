import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/local_category_repository.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import '../../../helpers/test_isolation.dart';

/// 为数据库准备和断言保留场景、错误及原始堆栈，便于定位随机顺序失败。
Future<T> _diagnose<T>(String context, Future<T> Function() action) async {
  try {
    return await action();
  } catch (error, stackTrace) {
    debugPrint('$context失败：$error\n$stackTrace');
    rethrow;
  }
}

/// 分类字段在写库和同步载荷边界必须使用相同的存储限制。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const accountId = 'category-boundary-account';
  const operations = ['createCategory', 'createSubCategory', 'upsertCategory'];
  // 补充平面图标占两个 UTF-16 单元，组合字符占两个码点，不能按字形计长。
  final validIcon = '${'🧾' * 253}e\u0301';
  final invalidFields = <({String label, String? icon, int sortOrder})>[
    (label: '真实 NUL', icon: '图\u0000标', sortOrder: 0),
    (label: '256 码点', icon: '${validIcon}a', sortOrder: 0),
    (label: '低于 int32', icon: '图标', sortOrder: -2147483649),
    (label: '高于 int32', icon: '图标', sortOrder: 2147483648),
    (label: '孤立高 surrogate', icon: '\ud800', sortOrder: 0),
    (label: '孤立低 surrogate', icon: '\udc00', sortOrder: 0),
  ];

  late SesameDatabase db;
  late LocalCategoryRepository repo;
  late String parentId;

  setUp(
    () => _diagnose('初始化分类边界测试', () async {
      resetGlobalTestState();
      db = SesameDatabase.withExecutor(NativeDatabase.memory());
      final recorder = ChangeRecorderImpl(db, accountIdGetter: () => accountId);
      repo = LocalCategoryRepository(
        db,
        trackerGetter: () => recorder,
        accountIdGetter: () => accountId,
      );
      parentId = await repo.createCategory(name: '父分类', kind: 'expense');
    }),
  );

  tearDown(() => _diagnose('关闭分类边界测试数据库', db.close));

  /// 三个入口使用相同字段，二级分类保留真实父节点和既有待推变更。
  Future<String> create(
    String operation, {
    String? icon,
    int? sortOrder,
    bool recordChanges = true,
  }) => _diagnose('调用 $operation', () async {
    switch (operation) {
      case 'createCategory':
        return repo.createCategory(
          name: '边界分类',
          kind: 'expense',
          icon: icon,
          sortOrder: sortOrder,
          recordChanges: recordChanges,
        );
      case 'createSubCategory':
        return repo.createSubCategory(
          parentId: parentId,
          name: '边界分类',
          kind: 'expense',
          icon: icon,
          sortOrder: sortOrder,
          recordChanges: recordChanges,
        );
      case 'upsertCategory':
        final result = await repo.upsertCategory(
          name: '边界分类',
          kind: 'expense',
          icon: icon,
          sortOrder: sortOrder,
        );
        expect(result.created, isTrue);
        return result.id;
      default:
        throw StateError('未知分类创建入口：$operation');
    }
  });

  for (final operation in operations) {
    for (final sortOrder in [-2147483648, 2147483647]) {
      test('$operation 保留 255 码点图标和排序 $sortOrder 并生成待推 mutation', () {
        return _diagnose('$operation 合法边界', () async {
          expect(validIcon.runes.length, 255);
          final id = await create(
            operation,
            icon: validIcon,
            sortOrder: sortOrder,
          );
          final row = await (db.select(
            db.categories,
          )..where((category) => category.id.equals(id))).getSingle();
          expect(row.icon, validIcon);
          expect(row.sortOrder, sortOrder);
          expect(row.scopeAccountId, accountId);

          final change = await (db.select(
            db.syncChanges,
          )..where((change) => change.entityId.equals(id))).getSingle();
          expect(change.entityType, 'category');
          expect(change.action, 'upsert');
          expect(change.accountId, accountId);
          expect(change.pushedAt, isNull);
          final payload = jsonDecode(change.payload) as Map<String, dynamic>;
          expect(payload['icon'], validIcon);
          expect(payload['sort_order'], sortOrder);
        });
      });
    }

    for (final fields in invalidFields) {
      test('$operation 拒绝${fields.label}且不留下半写或待推 mutation', () {
        return _diagnose('$operation 拒绝${fields.label}', () async {
          final beforeCategories = await db.select(db.categories).get();
          final beforeChanges = await db.select(db.syncChanges).get();

          await expectLater(
            create(operation, icon: fields.icon, sortOrder: fields.sortOrder),
            throwsA(isA<FormatException>()),
          );

          expect(await db.select(db.categories).get(), beforeCategories);
          expect(await db.select(db.syncChanges).get(), beforeChanges);
        });
      });
    }
  }

  for (final operation in operations.take(2)) {
    test('$operation 关闭变更登记时仍拒绝真实 NUL', () {
      return _diagnose('$operation 本地写入边界', () async {
        final beforeCategories = await db.select(db.categories).get();
        final beforeChanges = await db.select(db.syncChanges).get();

        await expectLater(
          create(operation, icon: '图\u0000标', recordChanges: false),
          throwsA(isA<FormatException>()),
        );

        expect(await db.select(db.categories).get(), beforeCategories);
        expect(await db.select(db.syncChanges).get(), beforeChanges);
      });
    });
  }

  for (final fields in invalidFields) {
    test('categorySyncPayload 拒绝${fields.label}', () {
      return _diagnose('同步载荷拒绝${fields.label}', () async {
        final category = Category(
          cloudRegistered: false,
          id: 'category-boundary',
          name: '边界分类',
          kind: 'expense',
          level: 1,
          sortOrder: fields.sortOrder,
          icon: fields.icon,
          updatedAt: DateTime.utc(2026, 9, 29),
        );

        expect(
          () => categorySyncPayload(category),
          throwsA(isA<FormatException>()),
        );
      });
    });
  }
}
