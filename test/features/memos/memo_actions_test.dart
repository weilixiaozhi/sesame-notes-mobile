import 'dart:convert';
import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/mappers/memo_mapper.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/features/memos/application/memo_actions.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';

/// 本组不执行删除，用例仍显式接收生命周期能力。
class _Lifecycle extends Mock implements DataLifecycleActions {}

/// 在完整条目读取返回时切换身份，验证迟到结果不会进入新会话。
class _ReadBoundaryRepository extends MemoRepository {
  /// 保留真实数据库与权限实现，仅注入一次可控的身份变化。
  _ReadBoundaryRepository(
    super.db, {
    required super.accountIdGetter,
    required super.generationGetter,
  });
  void Function()? afterEntryRead;

  /// 首次读取完成后触发钩子，旧目标的读取仍完全经过生产校验。
  @override
  Future<MemoEntry?> getEntry(String id, PrivateBookTarget target) async {
    try {
      final result = await super.getEntry(id, target);
      final callback = afterEntryRead;
      afterEntryRead = null;
      callback?.call();
      return result;
    } catch (error, stackTrace) {
      logger.error(
        'MemoActionsTest',
        '条目身份边界夹具失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }
}

/// 验证编辑快照与原目标绑定，错误目标不会被转交给当前账号。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SesameDatabase db;
  late _ReadBoundaryRepository repository;
  late MemoActions actions;
  String? account;
  var generation = 0;
  const firstId = '11111111-1111-4111-8111-111111111111';
  const secondId = '22222222-2222-4222-8222-222222222222';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    account = null;
    generation = 0;
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repository = _ReadBoundaryRepository(
      db,
      accountIdGetter: () => account,
      generationGetter: () => generation,
    );
    actions = MemoActions(repository, _Lifecycle());
  });
  tearDown(() => db.close());

  /// 创建普通笔记的合法正文，测试只改变父本或会话身份。
  MemoEntry entry(String bookId) => MemoEntry(
    id: '33333333-3333-4333-8333-333333333333',
    memoBookId: bookId,
    bookType: 'normal',
    title: '原始笔记',
    bodyJson: jsonEncode({
      'ops': [
        {'insert': '正文\n'},
      ],
    }),
    createdAt: DateTime.utc(2026, 9, 19),
    updatedAt: DateTime.utc(2026, 9, 19),
  );

  test('账号切换后旧编辑快照不能再保存原条目', () async {
    await repository.createBook(id: firstId, name: '原本', type: 'normal');
    final snapshot = await actions.prepareEditor(firstId);
    final value = entry(firstId);
    await actions.saveEntry(value, snapshot.target);
    account = 'another-account';
    await expectLater(
      actions.saveEntry(value, snapshot.target),
      throwsStateError,
    );
    expect((await db.select(db.memoEntries).getSingle()).title, '原始笔记');
  });

  test('一个本子的固定目标不能打开或保存另一个本子的条目', () async {
    await repository.createBook(id: firstId, name: '本子一', type: 'normal');
    await repository.createBook(id: secondId, name: '本子二', type: 'normal');
    final target = await actions.target(firstId);
    await expectLater(
      actions.prepareEditor(secondId, fixedTarget: target),
      throwsStateError,
    );
    await expectLater(
      actions.saveEntry(entry(secondId), target),
      throwsStateError,
    );
    expect(await db.select(db.memoEntries).get(), isEmpty);
  });

  test('按条目标识定位有效本，无关失效本不阻断查找且缺失返回空', () async {
    try {
      await repository.createBook(id: firstId, name: '失效本', type: 'normal');
      await repository.createBook(id: secondId, name: '有效本', type: 'normal');
      final value = entry(secondId);
      await repository.saveEntry(value, await repository.target(secondId));
      await (db.update(
        db.memoBooks,
      )..where((row) => row.id.equals(firstId))).write(
        MemoBooksCompanion(
          isStale: const d.Value(true),
          updatedAt: d.Value(DateTime.utc(2100)),
        ),
      );
      final found = await actions.findEntry(value.id);
      expect(found!.memoBookId, secondId);
      expect(found.bodyJson, value.bodyJson);
      expect(await actions.findEntry('missing'), isNull);
    } catch (error, stackTrace) {
      logger.error('MemoActionsTest', '按条目定位业务验证失败', error, stackTrace);
      rethrow;
    }
  });

  /// 准备已经完整下载的云端笔记，身份与可见性检查使用真实表事实。
  Future<MemoEntry> cloudEntry() async {
    try {
      final stamp = DateTime.utc(2026);
      await db
          .into(db.memoBooks)
          .insert(
            MemoBooksCompanion.insert(
              id: firstId,
              name: '云端本',
              type: 'normal',
              createdAt: stamp,
              updatedAt: stamp,
              storageMode: const d.Value('cloud'),
              scopeAccountId: const d.Value('account-a'),
              syncId: const d.Value('44444444-4444-4444-8444-444444444444'),
              serverRevision: const d.Value(1),
              fullCursor: const d.Value('1'),
            ),
          );
      final value = entry(firstId);
      await db.into(db.memoEntries).insert(memoEntryToCompanion(value));
      return value;
    } catch (error, stackTrace) {
      logger.error('MemoActionsTest', '准备云端条目夹具失败', error, stackTrace);
      rethrow;
    }
  }

  test('条目查找遵守云账号、父本可见性及条目删除边界', () async {
    try {
      final value = await cloudEntry();
      expect(await actions.findEntry(value.id), isNull);
      account = 'account-b';
      expect(await actions.findEntry(value.id), isNull);
      account = 'account-a';
      expect((await actions.findEntry(value.id))!.bodyJson, value.bodyJson);

      await (db.update(db.memoBooks)..where((row) => row.id.equals(firstId)))
          .write(const MemoBooksCompanion(isHidden: d.Value(true)));
      expect(await actions.findEntry(value.id), isNull);
      await (db.update(
        db.memoBooks,
      )..where((row) => row.id.equals(firstId))).write(
        const MemoBooksCompanion(
          isHidden: d.Value(false),
          pendingLocalDelete: d.Value(true),
        ),
      );
      expect(await actions.findEntry(value.id), isNull);
      await (db.update(
        db.memoBooks,
      )..where((row) => row.id.equals(firstId))).write(
        MemoBooksCompanion(
          pendingLocalDelete: const d.Value(false),
          deletedAt: d.Value(DateTime.utc(2026)),
        ),
      );
      expect(await actions.findEntry(value.id), isNull);
      await (db.update(db.memoBooks)..where((row) => row.id.equals(firstId)))
          .write(const MemoBooksCompanion(deletedAt: d.Value(null)));
      await (db.update(db.memoEntries)..where((row) => row.id.equals(value.id)))
          .write(MemoEntriesCompanion(deletedAt: d.Value(DateTime.utc(2026))));
      expect(await actions.findEntry(value.id), isNull);
    } catch (error, stackTrace) {
      logger.error('MemoActionsTest', '条目查找账号及可见性验证失败', error, stackTrace);
      rethrow;
    }
  });

  for (final incomplete in [false, true]) {
    test('命中的父本${incomplete ? '未完成下载' : '失效'}时拒绝读取正文', () async {
      try {
        account = 'account-a';
        final value = await cloudEntry();
        await (db.update(
          db.memoBooks,
        )..where((row) => row.id.equals(firstId))).write(
          incomplete
              ? const MemoBooksCompanion(fullCursor: d.Value(null))
              : const MemoBooksCompanion(isStale: d.Value(true)),
        );
        await expectLater(actions.findEntry(value.id), throwsStateError);
      } catch (error, stackTrace) {
        logger.error('MemoActionsTest', '条目目标完整性验证失败', error, stackTrace);
        rethrow;
      }
    });
  }

  for (final changeAccount in [false, true]) {
    test('读取条目期间${changeAccount ? '切换账号' : '会话代次改变'}时拒绝迟到正文', () async {
      try {
        await repository.createBook(id: firstId, name: '本机本', type: 'normal');
        final value = entry(firstId);
        await repository.saveEntry(value, await repository.target(firstId));
        repository.afterEntryRead = () {
          if (changeAccount) {
            account = 'new-account';
          } else {
            generation++;
          }
        };
        await expectLater(actions.findEntry(value.id), throwsStateError);
      } catch (error, stackTrace) {
        logger.error('MemoActionsTest', '条目迟到结果隔离验证失败', error, stackTrace);
        rethrow;
      }
    });
  }
}
