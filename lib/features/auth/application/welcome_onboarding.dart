/// 欢迎流程「完成」的用例编排：首次启动的偏好落盘与默认分类初始化。
///
/// 默认本子不在这里创建：用户在各业务域新建第一条数据时按需懒创建，
/// 避免登录已有账号的新装应用凭空多出一本与云端同名的默认本子。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/app_bootstrap_providers.dart';
import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/shared/providers/seed_providers.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';

/// 首次启动初始化的唯一入口，分类和币种就绪后才放行主应用。
class WelcomeOnboarding {
  WelcomeOnboarding(this.ref);

  final Ref ref;

  /// 首次默认币种固定人民币，仅保存偏好并准备分类，不修改已有账本。
  Future<bool> complete({AppLocalizations? l10n}) async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      if (!await prefs.setString('selected_currency', 'CNY')) {
        throw StateError('币种保存失败');
      }
      // 默认分类模板与首条记录的懒创建共用确定性分类身份。
      await ref.read(ensureSeedProvider)(l10n: l10n);
      await _preload();
      await _completeWelcome(prefs);
      return true;
    } catch (error, stackTrace) {
      logger.error('Welcome', '初始化欢迎流程失败', error, stackTrace);
      rethrow;
    }
  }

  /// 可降级预加载允许按需补齐，必需初始化失败时保留欢迎流程未完成状态。
  Future<void> _preload() async {
    try {
      await ref.read(splashPreloadRunnerProvider)();
    } catch (error, stackTrace) {
      if (ref.read(appInitStateProvider) == AppInitState.failed) {
        logger.error('Welcome', '必需初始化未完成，保留欢迎入口', error, stackTrace);
        rethrow;
      }
      logger.error('Welcome', '首页预加载失败，将按需加载', error, stackTrace);
    }
  }

  /// 欢迎标记成功写入后进入记账页，四个业务入口同时可用。
  Future<void> _completeWelcome(SharedPreferences prefs) async {
    if (!await prefs.setBool('welcome_shown', true)) {
      throw StateError('欢迎完成标记保存失败');
    }
    ref.read(currentModeProvider.notifier).set(AppMode.bookkeeping);
    ref.read(bottomTabIndexProvider.notifier).set(0);
    ref.read(shouldShowWelcomeProvider.notifier).set(false);
  }
}

/// 欢迎流程初始化装配。
final welcomeOnboardingProvider = Provider<WelcomeOnboarding>(
  WelcomeOnboarding.new,
);
