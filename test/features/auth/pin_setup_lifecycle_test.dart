import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/auth/application/security_providers.dart';
import 'package:sesame_notes/features/auth/presentation/pin_setup_page.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';

/// 控制安全存储完成时刻，验证设置结果不依赖页面是否仍然存在。
class _PendingPinService extends AppLockServiceFacade {
  final completion = Completer<void>();

  /// 暂缓 PIN 保存直到页面完成销毁。
  @override
  Future<void> setPin(String pin) => completion.future;

  /// 清除操作复用同一受控完成边界。
  @override
  Future<void> clearPin() => completion.future;
}

/// PIN 已落盘后的安全状态必须同步，销毁页面不得访问失效的 WidgetRef。
void main() {
  testWidgets('关闭 PIN 设置页后保存完成仍发布启用状态', (tester) async {
    final service = _PendingPinService();
    final container = ProviderContainer(
      overrides: [appLockServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PinSetupPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final pad = tester.widget<NumberPad>(find.byType(NumberPad));
    for (var submission = 0; submission < 2; submission++) {
      for (final digit in ['1', '2', '3', '4']) {
        pad.onNumberTap(digit);
      }
      await tester.pump();
    }
    expect(container.read(appLockEnabledProvider), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    service.completion.complete();
    await tester.pump();
    expect(container.read(appLockEnabledProvider), isTrue);
    expect(tester.takeException(), isNull);
  });

  test('清除 PIN 成功后共同更新应用锁与生物识别状态', () async {
    final service = _PendingPinService();
    final container = ProviderContainer(
      overrides: [appLockServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
    final enabled = container.read(appLockEnabledProvider.notifier);
    enabled.load(true);
    container.read(appLockBiometricEnabledProvider.notifier).load(true);
    final clearing = enabled.clearPin();
    expect(container.read(appLockEnabledProvider), isTrue);
    service.completion.complete();
    await clearing;
    expect(container.read(appLockEnabledProvider), isFalse);
    expect(container.read(appLockBiometricEnabledProvider), isFalse);
  });
}
