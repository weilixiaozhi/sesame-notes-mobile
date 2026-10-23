import 'package:sesame_notes/shared/providers/fitness_builtin_catalog_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/memo_repository.dart';
import 'package:sesame_notes/features/settings/application/day_file_actions.dart';
import 'package:sesame_notes/features/settings/application/fitness_file_actions.dart';
import 'package:sesame_notes/features/days/domain/day_date_rules.dart';
import 'package:sesame_notes/features/settings/application/transfer_actions.dart';
import 'package:sesame_notes/features/settings/infrastructure/transfer_table.dart';
import 'package:sesame_notes/features/settings/presentation/widgets/data_import_target_dialog.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import '../../helpers/fitness_space_fixture.dart';
import '../../helpers/test_isolation.dart';

void main() {
  for (final kind in [TransferKind.days, TransferKind.fitness]) {
    testWidgets('$kind 共用预览、写入进度与去重，字段无需版本和内部标识', (tester) async {
      resetGlobalTestState();
      final db = SesameDatabase.withExecutor(NativeDatabase.memory());
      addTearDown(db.close);
      late WidgetRef widgetRef;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            currentAccountIdProvider.overrideWithValue(null),
            dayDefinitionValidatorProvider.overrideWithValue(
              validateAndProject,
            ),
            fitnessBuiltinCatalogProvider.overrideWith((_) async => []),
          ],
          child: Consumer(
            builder: (_, ref, _) {
              widgetRef = ref;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.runAsync(() async {
        final id = transferId(kind.name);
        late DataImportTarget target;
        if (kind == TransferKind.days) {
          await widgetRef
              .read(dayRepositoryProvider)
              .createBook(id: id, name: '目标');
          target = DataImportTarget(
            dayTarget: await widgetRef.read(dayFileActionsProvider).target(id),
          );
        } else {
          await seedFitnessTestSpace(db, id: id);
          target = DataImportTarget(
            fitnessTarget: await widgetRef
                .read(fitnessFileActionsProvider)
                .target(id),
          );
        }
        final table = TransferTable.parse(
          kind == TransferKind.days
              ? '名称,日期\n纪念,2026-09-14'
              : '计划名称,动作,次数,组数\n健身,0025,8,3',
          kind,
        );
        final session = TransferActions(widgetRef.read, target, table, kind);
        await session.prepare();
        session.map(table.detect(kind));
        await session.buildPreview();
        expect(session.preview.single.error, isNull);
        final progress = <(int, int)>[];
        expect(
          (await session.import(
            (d, t) => progress.add((d, t)),
            (_) {},
          )).imported,
          1,
        );
        expect(progress, [(0, 1), (1, 1)]);
        await session.buildPreview();
        expect(session.preview.single.duplicate, isTrue);
        expect(session.preview.single.selected, isFalse);
        if (kind == TransferKind.days) {
          expect(
            (await widgetRef.read(dayRepositoryProvider).getEvents(id))
                .single
                .definition
                .name,
            '纪念',
          );
        } else {
          expect(await db.select(db.fitnessEntities).get(), hasLength(1));
        }
      });
    });
  }
  testWidgets('普通文件映射、分次勾选、进度、重复识别、换号拒绝均复用仓储', (tester) async {
    resetGlobalTestState();
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    addTearDown(db.close);
    var generation = 0;
    final repo = MemoRepository(db, generationGetter: () => generation);
    late WidgetRef widgetRef;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          memoRepositoryProvider.overrideWithValue(repo),
          currentAccountIdProvider.overrideWithValue(null),
        ],
        child: Consumer(
          builder: (_, ref, _) {
            widgetRef = ref;
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.runAsync(() async {
      final book = await repo.createBook(
        id: transferId('memo-target'),
        name: '目标',
        type: 'normal',
      );
      final fixed = await repo.target(book.id);
      final table = TransferTable.parse(
        '[{"title":"一","body":"正文一"},{"title":"二","body":"正文二"},{"title":"错误"}]',
        TransferKind.memo,
      );
      final session = TransferActions(
        widgetRef.read,
        DataImportTarget(memoTarget: fixed),
        table,
        TransferKind.memo,
      );
      await session.prepare();
      session.map(table.detect(TransferKind.memo));
      await session.buildPreview();
      expect(session.preview.map((r) => r.error == null), [true, true, false]);
      session.preview[1].selected = false;
      final progress = <(int, int)>[];
      final first = await session.import(
        (done, total) => progress.add((done, total)),
        (_) {},
      );
      expect(first.imported, 1);
      expect(progress, [(0, 1), (1, 1)]);
      expect((await repo.getEntries(book.id)).single.title, '一');
      await session.buildPreview();
      expect(session.preview[0].duplicate, isTrue);
      expect(session.preview[0].selected, isFalse);
      expect((await session.import((_, _) {}, (_) {})).imported, 1);
      expect((await repo.getEntries(book.id)).map((e) => e.title).toSet(), {
        '一',
        '二',
      });
      await session.buildPreview();
      expect(session.preview.where((r) => r.duplicate), hasLength(2));
      final newTable = TransferTable.parse(
        'title,body\n三,正文三',
        TransferKind.memo,
      );
      final stale = TransferActions(
        widgetRef.read,
        DataImportTarget(memoTarget: fixed),
        newTable,
        TransferKind.memo,
      );
      await stale.prepare();
      stale.map(newTable.detect(TransferKind.memo));
      await stale.buildPreview();
      generation++;
      await expectLater(stale.import((_, _) {}, (_) {}), throwsStateError);
      expect((await repo.getEntries(book.id)).length, 2);
    });
  });
}
