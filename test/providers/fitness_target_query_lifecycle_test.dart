import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/fitness_repository_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';

/// 固定目标查询由操作持有，等待期间保持有效，身份代次改变后仍拒绝旧操作。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('操作期查询跨异步等待有效且不借用下一会话', () async {
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        currentAccountIdProvider.overrideWithValue(null),
        authIdentityGenerationProvider.overrideWithValue(0),
      ],
    );
    try {
      final spaces = container.read(fitnessSpaceBookRepositoryProvider);
      final space = await spaces.createBook(
        id: 'b71d54e2-d9c1-4f63-bc39-a57f5ecccf84',
        name: '测试空间',
      );
      final target = await container
          .read(fitnessSpaceQueryRepositoryProvider)
          .target(space.id);
      final query = container.read(fitnessTargetQueryRepositoryFactoryProvider)(
        target,
      );
      // 查询未由页面订阅，异步等待也不能让它持有的身份读取入口提前失效。
      await container.pump();
      expect((await query.getPreferences()).defaultRestSeconds, greaterThan(0));
      container.updateOverrides([
        databaseProvider.overrideWithValue(db),
        currentAccountIdProvider.overrideWithValue(null),
        authIdentityGenerationProvider.overrideWithValue(1),
      ]);
      await container.pump();
      await expectLater(
        query.getPreferences(),
        throwsA(isA<FitnessValidationException>()),
      );
    } catch (error, stack) {
      debugPrint('固定目标查询生命周期检查失败：$error\n$stack');
      rethrow;
    } finally {
      container.dispose();
      await db.close();
    }
  });
}
