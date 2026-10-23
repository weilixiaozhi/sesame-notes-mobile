import 'dart:async';

import 'package:drift/drift.dart' as d;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/features/transactions/application/currency_providers.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';

/// 让 A 账本首次保存悬停，B 的既有偏好可直接读取。
class _DelayedPreferences extends InMemorySharedPreferencesStore {
  /// B 的偏好故意缺少当前本位币，验证加载时会补齐它。
  _DelayedPreferences()
    : super.withData({'flutter.visibleCurrencies.b': 'EUR'});
  final started = Completer<void>();
  final complete = Completer<void>();

  /// 仅拦截 A 的初始化写入，其他平台写入正常完成。
  @override
  Future<bool> setValue(String type, String key, Object value) async {
    if (key == 'flutter.visibleCurrencies.a') {
      if (!started.isCompleted) started.complete();
      await complete.future;
    }
    return super.setValue(type, key, value);
  }
}

/// 展示集合只能由当前本发布，并且任何已保存集合都必须含本位币。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('切本后旧初始化结束不能覆盖新本偏好，自动补齐新本位币', () async {
    final previous = SharedPreferencesStorePlatform.instance;
    final preferences = _DelayedPreferences();
    SharedPreferences.resetStatic();
    SharedPreferencesStorePlatform.instance = preferences;
    final db = SesameDatabase.withExecutor(NativeDatabase.memory());
    final subscribed = Completer<void>();
    final ledgers = StreamController<Ledger?>.broadcast(
      onListen: () {
        if (!subscribed.isCompleted) subscribed.complete();
      },
    );
    final container = ProviderContainer(
      overrides: [currentLedgerProvider.overrideWith((ref) => ledgers.stream)],
    );
    // 与应用壳一致保持真实订阅，避免无人监听的 Riverpod 流被自动暂停。
    final ledgerSubscription = container.listen(
      currentLedgerProvider,
      (_, _) {},
    );
    final initializationSubscription = container.listen(
      visibleCurrenciesInitProvider,
      (_, _) {},
    );
    try {
      for (final id in ['a', 'b']) {
        await db
            .into(db.ledgers)
            .insert(
              LedgersCompanion.insert(
                id: id,
                name: id,
                currency: d.Value(id == 'a' ? 'CNY' : 'USD'),
                updatedAt: DateTime.utc(2026),
              ),
            );
      }
      final rows = await db.select(db.ledgers).get();
      final initializing = container.read(visibleCurrenciesInitProvider.future);
      await subscribed.future.timeout(const Duration(seconds: 3));
      ledgers.add(rows.firstWhere((row) => row.id == 'a'));
      await preferences.started.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw StateError('测试夹具未进入 A 初始化写入'),
      );
      ledgers.add(rows.firstWhere((row) => row.id == 'b'));
      await Future<void>.delayed(Duration.zero);
      preferences.complete.complete();
      await initializing.timeout(const Duration(seconds: 3));
      await container
          .read(visibleCurrenciesInitProvider.future)
          .timeout(const Duration(seconds: 3));
      expect(container.read(visibleCurrenciesProvider), {'EUR', 'USD'});
    } finally {
      if (!preferences.complete.isCompleted) preferences.complete.complete();
      initializationSubscription.close();
      ledgerSubscription.close();
      container.dispose();
      await ledgers.close();
      await db.close();
      SharedPreferencesStorePlatform.instance = previous;
      SharedPreferences.resetStatic();
    }
  });
}
