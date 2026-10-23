import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';

/// 拒绝第一笔币种偏好写入，并允许确认后续请求仍按顺序执行。
class _Preferences extends InMemorySharedPreferencesStore {
  /// 使用真实插件缓存和平台存储分离的行为，测试 false 后必须重新读取。
  _Preferences()
    : super.withData({'flutter.visibleCurrencies._none': 'CNY,USD,JPY'});
  final started = Completer<void>();
  final release = Completer<void>();
  final writes = <String>[];

  /// 首次写入等待测试释放后返回 false，之后正常保存。
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    if (key == 'flutter.visibleCurrencies._none') {
      writes.add(value as String);
      if (writes.length == 1) {
        started.complete();
        await release.future;
        return false;
      }
    }
    return super.setValue(type, key, value);
  }
}

/// 失败选择不能假装保存，也不能通过后续并发请求把失败快照写回磁盘。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferencesStorePlatform previous;
  late _Preferences preferences;
  late ProviderContainer container;
  setUp(() {
    previous = SharedPreferencesStorePlatform.instance;
    preferences = _Preferences();
    SharedPreferences.resetStatic();
    SharedPreferencesStorePlatform.instance = preferences;
    container = ProviderContainer(
      overrides: [
        currentLedgerProvider.overrideWith((ref) => Stream.value(null)),
        currentLedgerCurrencyProvider.overrideWithValue('CNY'),
      ],
    );
    container.read(visibleCurrenciesProvider.notifier).set({
      'CNY',
      'USD',
      'JPY',
    });
  });
  tearDown(() {
    if (!preferences.release.isCompleted) preferences.release.complete();
    container.dispose();
    SharedPreferencesStorePlatform.instance = previous;
    SharedPreferences.resetStatic();
  });

  test('平台返回 false 时抛出失败，内存选择与磁盘都保留旧值', () async {
    final pending = toggleCurrencyVisibility(container.read, 'JPY');
    final rejected = expectLater(pending, throwsStateError);
    await preferences.started.future;
    preferences.release.complete();
    await rejected;
    expect(container.read(visibleCurrenciesProvider), {'CNY', 'USD', 'JPY'});
    expect(
      (await SharedPreferences.getInstance()).getString(
        'visibleCurrencies._none',
      ),
      'CNY,USD,JPY',
    );
  });

  test('第一笔失败后第二笔串行读取磁盘，不继承失败选择或被旧回滚覆盖', () async {
    final first = toggleCurrencyVisibility(container.read, 'JPY');
    final rejected = expectLater(first, throwsStateError);
    await preferences.started.future;
    final second = toggleCurrencyVisibility(container.read, 'USD');
    expect(preferences.writes, hasLength(1));
    preferences.release.complete();
    await rejected;
    await second;
    expect(container.read(visibleCurrenciesProvider), {'CNY', 'JPY'});
    expect(
      (await SharedPreferences.getInstance()).getString(
        'visibleCurrencies._none',
      ),
      'CNY,JPY',
    );
    expect(preferences.writes, ['CNY,USD', 'CNY,JPY']);
  });

  test('已提交的本位币补入偏好失败返回 false，仍保持真实本位币可见', () async {
    final pending = ensureCurrencyVisibleForCurrentLedger(
      container.read,
      'EUR',
    );
    await preferences.started.future;
    preferences.release.complete();
    expect(await pending, isFalse);
    expect(container.read(visibleCurrenciesProvider), contains('EUR'));
    expect(
      (await SharedPreferences.getInstance()).getString(
        'visibleCurrencies._none',
      ),
      'CNY,USD,JPY',
    );
  });
}
