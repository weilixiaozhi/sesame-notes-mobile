import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/features/settings/application/import_target.dart';
import 'package:sesame_notes/features/settings/application/transfer_actions.dart';
import 'package:sesame_notes/features/settings/infrastructure/transfer_table.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';

import '../../helpers/test_isolation.dart';

/// 账号密码本与普通本同一加密级别：导入导出全程明文，账号与密码不做脱敏。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const bookId = '11111111-1111-4111-8111-111111111111';
  late SesameDatabase db;
  late MemoRepository repo;

  setUp(() async {
    resetGlobalTestState();
    db = SesameDatabase.withExecutor(NativeDatabase.memory());
    repo = MemoRepository(
      db,
      accountIdGetter: () => 'account',
      generationGetter: () => 0,
      changeRecorder: ChangeRecorderImpl(db, accountIdGetter: () => 'account'),
    );
    await repo.createBook(id: bookId, name: '账号本', type: 'credentials');
  });

  tearDown(() async => db.close());

  testWidgets('账号密码本导入的预览与落库都是明文账号密码', (tester) async {
    late WidgetRef ref;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // 预览的重复判定与写入结果必须落在同一个内存库上。
          databaseProvider.overrideWithValue(db),
          currentAccountIdProvider.overrideWithValue('account'),
          memoRepositoryProvider.overrideWithValue(repo),
        ],
        child: Consumer(
          builder: (_, value, _) {
            ref = value;
            return const SizedBox();
          },
        ),
      ),
    );

    await tester.runAsync(() async {
      final table = TransferTable.parse(
        '标题,账号,密码\n邮箱,user@example.com,secret123\n',
        TransferKind.credentials,
      );
      final session = TransferActions(
        ref.read,
        DataImportTarget(memoTarget: await repo.target(bookId)),
        table,
        TransferKind.credentials,
      );
      await session.prepare();
      final detected = table.detect(TransferKind.credentials);
      // 映射页把标题与时间之外的每一列都默认当作卡片字段。
      final meta = {
        detected['title'],
        detected['created_at'],
        detected['updated_at'],
      };
      session.map(detected, const {}, [
        for (final header in table.headers)
          if (!meta.contains(header))
            (header: header, label: credentialFieldName(header)),
      ]);
      await session.buildPreview();

      final row = session.preview.single;
      expect(row.error, isNull);
      final entry = row.value as MemoEntry;
      expect(entry.title, '邮箱');
      // 明文保真：预览数据即原文，字段名按常见表头识别，不脱敏、不隐藏。
      expect(entry.fields.map((field) => field.label).toList(), ['账号', '密码']);
      expect(entry.fields[0].value, 'user@example.com');
      expect(entry.fields[1].value, 'secret123');
      expect(entry.orderKey, isNotNull, reason: '卡片必须带顺序键');

      final outcome = await session.import((_, _) {}, (_) {});
      expect(outcome.imported, 1);
      expect(outcome.failed, 0);

      // 落库后仍是明文原文，导入不引入任何改写。
      final stored = (await repo.getEntries(bookId)).single;
      expect(stored.fields[0].value, 'user@example.com');
      expect(stored.fields[1].value, 'secret123');
    });
  });

  testWidgets('自定义列写进卡片：改名生效、关闭的列不导入、一行可有多个账号', (tester) async {
    late WidgetRef ref;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          currentAccountIdProvider.overrideWithValue('account'),
          memoRepositoryProvider.overrideWithValue(repo),
        ],
        child: Consumer(
          builder: (_, value, _) {
            ref = value;
            return const SizedBox();
          },
        ),
      ),
    );

    await tester.runAsync(() async {
      final table = TransferTable.parse(
        '标题,登录用户名,登录邮箱,支付密码,无关列\n招商银行,user001,user@example.com,pay-pass,不要导入\n',
        TransferKind.credentials,
      );
      final session = TransferActions(
        ref.read,
        DataImportTarget(memoTarget: await repo.target(bookId)),
        table,
        TransferKind.credentials,
      );
      await session.prepare();
      // 映射页给出的初始建议：命中别名的用规范名，其余保留表头原文。
      expect(table.headers.map(credentialFieldName).toList(), [
        '标题',
        '登录用户名',
        '登录邮箱',
        '支付密码',
        '无关列',
      ]);
      session.map(table.detect(TransferKind.credentials), const {}, [
        (header: '登录用户名', label: '登录账号'),
        (header: '登录邮箱', label: '登录邮箱'),
        (header: '支付密码', label: '支付密码'),
        (header: '无关列', label: null),
      ]);
      await session.buildPreview();

      final entry = session.preview.single.value as MemoEntry;
      expect(entry.title, '招商银行');
      expect(
        entry.fields.map((field) => '${field.label}=${field.value}').toList(),
        ['登录账号=user001', '登录邮箱=user@example.com', '支付密码=pay-pass'],
      );

      final outcome = await session.import((_, _) {}, (_) {});
      expect(outcome.imported, 1);
      expect(outcome.failed, 0);
      final stored = (await repo.getEntries(bookId)).single;
      expect(stored.fields.map((field) => field.label).toList(), [
        '登录账号',
        '登录邮箱',
        '支付密码',
      ]);
    });
  });
}
