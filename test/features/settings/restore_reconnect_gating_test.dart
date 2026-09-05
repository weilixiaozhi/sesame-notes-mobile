/// 恢复页「登录原账号获取最新」的账号身份拦截测试。
///
/// 需求锚点：
/// - 未登录：该选项不可用，提示登录原账号；
/// - 已登录但当前账号 ≠ 备份记录的原账号：不可用，提示账号不符；
/// - 备份缺少原账号信息：不可用（无从校验身份）；
/// - 账号匹配：可用，且应用恢复后触发 Reconnect v1 下载云端最新。
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/core/api/api_client_provider.dart';
import 'package:sesame_notes/core/api/auth_session.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/settings/application/backup_restore_providers.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/presentation/restore_backup_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

/// 返回固定会话的认证桩。
class _StubAuthNotifier extends AuthSessionNotifier {
  _StubAuthNotifier(this.session);
  final AuthSession? session;
  @override
  AuthSession? build() => session;
}

RestoreLedgerItem _cloudItem({String? accountId}) => RestoreLedgerItem(
  ledgerBackupId: 'ledger-1',
  name: '家庭账本',
  storageOrigin: LedgerStorageOrigin.cloud,
  accountId: accountId,
  accountName: 'Alice',
  memberCount: 2,
  transactionCount: 10,
  pendingCount: 0,
  conflictCount: 0,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('reconnectBlockerOf 纯函数', () {
    test('未登录 → needLogin', () {
      expect(
        reconnectBlockerOf(itemAccountId: 'acc-1', currentAccountId: null),
        ReconnectBlocker.needLogin,
      );
    });

    test('账号不匹配 → accountMismatch', () {
      expect(
        reconnectBlockerOf(itemAccountId: 'acc-1', currentAccountId: 'acc-2'),
        ReconnectBlocker.accountMismatch,
      );
    });

    test('备份缺少原账号 → noAccount', () {
      expect(
        reconnectBlockerOf(itemAccountId: null, currentAccountId: 'acc-1'),
        ReconnectBlocker.noAccount,
      );
    });

    test('账号匹配 → none(可用)', () {
      expect(
        reconnectBlockerOf(itemAccountId: 'acc-1', currentAccountId: 'acc-1'),
        ReconnectBlocker.none,
      );
    });
  });

  group('shouldReconnectAfterApply 纯函数', () {
    test('有匹配账号的 reconnect 决策 → true', () {
      final item = _cloudItem(accountId: 'acc-1');
      expect(
        shouldReconnectAfterApply(
          items: [item],
          decisions: const {'ledger-1': RestoreDecision.reconnect},
          currentAccountId: 'acc-1',
        ),
        isTrue,
      );
    });

    test('未登录或账号不匹配 → false', () {
      final item = _cloudItem(accountId: 'acc-1');
      expect(
        shouldReconnectAfterApply(
          items: [item],
          decisions: const {'ledger-1': RestoreDecision.reconnect},
          currentAccountId: null,
        ),
        isFalse,
      );
      expect(
        shouldReconnectAfterApply(
          items: [item],
          decisions: const {'ledger-1': RestoreDecision.reconnect},
          currentAccountId: 'acc-2',
        ),
        isFalse,
      );
    });
  });

  testWidgets('Step 3：未登录时「登录原账号」不可选并提示登录', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        authSessionProvider.overrideWith(() => _StubAuthNotifier(null)),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(backupRestoreFlowProvider.notifier);
    notifier.state = BackupRestoreFlowState(
      step: 3,
      items: [_cloudItem(accountId: 'acc-1')],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RestoreBackupPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('未登录，登录原账号后可用'), findsOneWidget);
    // reconnect 单选项处于禁用态。
    final radios = tester
        .widgetList<RadioListTile<RestoreDecision>>(
          find.byType(RadioListTile<RestoreDecision>),
        )
        .toList();
    final reconnect = radios.firstWhere(
      (r) => r.value == RestoreDecision.reconnect,
    );
    expect(reconnect.enabled, isFalse, reason: '未登录时该选项必须禁用');
  });

  testWidgets('Step 3：账号不匹配时提示账号不符并禁用', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        authSessionProvider.overrideWith(
          () => _StubAuthNotifier(
            const AuthSession(accessToken: 't', userId: 'acc-2', deviceId: 'd'),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(backupRestoreFlowProvider.notifier);
    notifier.state = BackupRestoreFlowState(
      step: 3,
      items: [_cloudItem(accountId: 'acc-1')],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RestoreBackupPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前账号不是该账本的原账号'), findsOneWidget);
    final radios = tester
        .widgetList<RadioListTile<RestoreDecision>>(
          find.byType(RadioListTile<RestoreDecision>),
        )
        .toList();
    final reconnect = radios.firstWhere(
      (r) => r.value == RestoreDecision.reconnect,
    );
    expect(reconnect.enabled, isFalse);
  });

  testWidgets('Step 3：账号匹配时「登录原账号」可选且无拦截提示', (tester) async {
    final db = SesameDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        authSessionProvider.overrideWith(
          () => _StubAuthNotifier(
            const AuthSession(accessToken: 't', userId: 'acc-1', deviceId: 'd'),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(backupRestoreFlowProvider.notifier);
    notifier.state = BackupRestoreFlowState(
      step: 3,
      items: [_cloudItem(accountId: 'acc-1')],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RestoreBackupPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('未登录，登录原账号后可用'), findsNothing);
    expect(find.text('当前账号不是该账本的原账号'), findsNothing);
    final radios = tester
        .widgetList<RadioListTile<RestoreDecision>>(
          find.byType(RadioListTile<RestoreDecision>),
        )
        .toList();
    final reconnect = radios.firstWhere(
      (r) => r.value == RestoreDecision.reconnect,
    );
    expect(reconnect.enabled, isTrue, reason: '账号匹配时选项必须可用');
  });
}
