import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/repositories/local/fitness_space_repository.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_signals.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_sync_status_provider.dart';
import '../helpers/fitness_space_fixture.dart';

/// 真实数据库证明本地资源不依赖云游标，云端缺失和失效标记仍保留完整性保护。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final scenario in [
    'local',
    'cloudMissing',
    'cloudComplete',
    'localStale',
    'noSpace',
  ]) {
    test('完整性事实区分当前空间场景：$scenario', () async {
      final db = SesameDatabase.withExecutor(NativeDatabase.memory());
      final cloud = scenario.startsWith('cloud');
      final account = cloud ? 'account' : null;
      String? id;
      if (scenario != 'noSpace') {
        id = await seedFitnessTestSpace(db, account: account);
        if (scenario == 'cloudMissing') {
          await (db.update(db.fitnessSpaces)
                ..where((row) => row.id.equals(id!)))
              .write(const FitnessSpacesCompanion(fullCursor: d.Value(null)));
        }
        if (scenario == 'localStale') {
          await (db.update(db.fitnessSpaces)
                ..where((row) => row.id.equals(id!)))
              .write(const FitnessSpacesCompanion(isStale: d.Value(true)));
        }
      }
      final container = ProviderContainer(
        overrides: [
          currentAccountIdProvider.overrideWithValue(account),
          currentFitnessSpaceIdProvider.overrideWithBuild((ref, _) => id),
          fitnessSpaceRepositoryProvider.overrideWithValue(
            FitnessSpaceRepository(db, accountIdGetter: () => account),
          ),
          dataChangeSignalProvider.overrideWith((ref) => const Stream.empty()),
        ],
      );
      try {
        final status = await container.read(fitnessSyncStatusProvider.future);
        expect(
          status.isComplete,
          ['local', 'cloudComplete'].contains(scenario),
        );
        if (scenario == 'local') {
          final row = await db.select(db.fitnessSpaces).getSingle();
          expect(row.fullCursor, isNull);
          expect(row.syncId, isNull);
          expect(status.isComplete, isTrue);
        }
      } finally {
        container.dispose();
        await db.close();
      }
    });
  }
}
