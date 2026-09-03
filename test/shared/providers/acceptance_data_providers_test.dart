// 验收数据动作门面（acceptance_data_providers）接线测试。
//
// 锁定 UI 触发的三条关键链路：
//  - 未登录点击「新建云账本」→ 动作返回 null（跳过）且不落库；
//  - 已登录 → 创建 storageMode=cloud 账本；
//  - 新建本地账本 → 空账本场景自动切换为当前账本。
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/shared/providers/acceptance_data_providers.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/local_self_id_providers.dart';

/// 已登录会话桩：user-1 账号域。
class _AuthedSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSession? build() => const AuthSession(
    accessToken: 'token',
    userId: 'user-1',
    deviceId: 'device-1',
  );
}

/// 渲染一个带按钮的 Consumer，点击后执行 [action] 并把结果与当前账本
/// id 回写，供断言读取。
Widget _harness({
  required ProviderContainer container,
  required Future<String?> Function(WidgetRef ref) action,
  required void Function(String? result, String currentLedgerId) onDone,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: Consumer(
        builder: (context, ref, _) => ElevatedButton(
          onPressed: () async {
            final result = await action(ref);
            onDone(result, ref.read(currentLedgerIdProvider));
          },
          child: const Text('go'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('未登录：云账本动作跳过且不落库', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer();
    addTearDown(container.dispose);

    String? result = 'sentinel';
    String currentLedgerId = 'sentinel';
    await tester.pumpWidget(
      _harness(
        container: container,
        action: seedAcceptanceCloudLedger,
        onDone: (r, c) {
          result = r;
          currentLedgerId = c;
        },
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(result, isNull);
    expect(currentLedgerId, '');
    expect(await db.select(db.ledgers).get(), isEmpty);
  });

  testWidgets('已登录：创建云端账本成功并切换为当前账本', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWith((ref) => db),
        authSessionProvider.overrideWith(_AuthedSessionNotifier.new),
      ],
    );
    addTearDown(container.dispose);

    String? result = 'sentinel';
    String currentLedgerId = 'sentinel';
    await tester.pumpWidget(
      _harness(
        container: container,
        action: seedAcceptanceCloudLedger,
        onDone: (r, c) {
          result = r;
          currentLedgerId = c;
        },
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    final ledgers = await db.select(db.ledgers).get();
    expect(ledgers.single.storageMode, 'cloud');
    expect(ledgers.single.scopeAccountId, 'user-1');
    expect(currentLedgerId, ledgers.single.id);
  });

  testWidgets('新建本地账本：落库并切换为当前账本', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWith((ref) => db),
        localSelfIdProvider.overrideWith((ref) async => 'self-test'),
      ],
    );
    addTearDown(container.dispose);

    String? result = 'sentinel';
    String currentLedgerId = 'sentinel';
    await tester.pumpWidget(
      _harness(
        container: container,
        action: seedAcceptanceLocalLedger,
        onDone: (r, c) {
          result = r;
          currentLedgerId = c;
        },
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    final ledgers = await db.select(db.ledgers).get();
    expect(ledgers.single.storageMode, 'local');
    expect(currentLedgerId, ledgers.single.id);
  });
}
