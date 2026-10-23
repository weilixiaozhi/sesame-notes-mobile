import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/application/fitness_file_actions.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';

import '../../helpers/fitness_transfer_fixture.dart';
import '../../helpers/test_isolation.dart';

/// 导入提交前目标失效时，内容和导入回执必须一起回滚。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(resetGlobalTestState);

  test('导入写入过程中目标隐藏时撤销整笔导入', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        currentAccountIdProvider.overrideWithValue(null),
        authIdentityGenerationProvider.overrideWithValue(0),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    final space = await container
        .read(fitnessSpaceBookRepositoryProvider)
        .createBook(id: fitnessId(900), name: '导入目标');
    final actions = container.read(fitnessFileActionsProvider);
    final target = await actions.target(space.id);
    Future<int>? hiding;
    final importing = actions.import(
      target,
      fitnessDocument(records: [fitnessFixture().first]),
      onProgress: (_, _) {
        // 模拟写入回调触发目标生命周期变化，提交前必须重新核实可访问性。
        hiding =
            (db.update(db.fitnessSpaces)
                  ..where((row) => row.id.equals(space.id)))
                .write(const FitnessSpacesCompanion(isHidden: d.Value(true)));
      },
    );
    await expectLater(importing, throwsStateError);
    await hiding;
    expect(await db.select(db.fitnessEntities).get(), isEmpty);
    expect(await db.select(db.fitnessImportReceipts).get(), isEmpty);
    expect((await db.select(db.fitnessSpaces).getSingle()).isHidden, isFalse);
  });
}
