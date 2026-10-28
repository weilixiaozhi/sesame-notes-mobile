import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/auth/application/security_providers.dart';

/// 控制安全存储完成时刻，验证清除 PIN 后的安全状态。
class _PendingPinService extends AppLockServiceFacade {
  final completion = Completer<void>();

  /// 清除操作复用同一受控完成边界。
  @override
  Future<void> clearPin() => completion.future;
}

/// PIN 清除落盘后共同更新应用锁和生物识别状态。
void main() {
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
