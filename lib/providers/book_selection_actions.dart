/// 选本动作（顶层聚合模块）。
///
/// 记账、日子与备忘录管理页选本后，统一切回所属模式与首页签。
/// 健身空间由自己的选择入口管理。
/// 归属与 app_init_providers 一致：顶层聚合模块单向依赖各 feature 的
/// application 层与 shared/providers 基础装配。
library;

// ProviderListenable 由 riverpod 的 misc 入口提供，与 database_providers 同源。
import 'package:flutter_riverpod/misc.dart';

import 'package:sesame_notes/data/models/app_mode.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/memos/application/memo_providers.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/ledger_selection_providers.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';

/// 选中 [bookId] 作为当前本，并把界面切回该本所属模式与首页签。
///
/// [read] 由调用方注入（页面传 ref.read，测试传 container.read），
/// 使本动作不绑定 Widget 生命周期。
///
/// 私有本（日子 / 备忘录）的选中同时写回偏好，跨模式切换后仍然生效；
/// 记账账本的选中由 [currentLedgerIdProvider] 承担，持久化走启动监听。
Future<void> selectBook(
  T Function<T>(ProviderListenable<T>) read, {
  required AppMode mode,
  required String bookId,
}) async {
  // 先取好模式与页签 notifier：选中私有本是异步的，等待期间页面可能已卸载，
  // 这里提前持有 notifier，避免等待后再次读取调用方的 ref。
  final modeNotifier = read(currentModeProvider.notifier);
  final tabNotifier = read(bottomTabIndexProvider.notifier);
  switch (mode) {
    case AppMode.bookkeeping:
      await selectPublishedLedger(read, bookId);
    case AppMode.days:
      await read(currentDayBookIdProvider.notifier).select(bookId);
    case AppMode.memos:
      // 备忘录下并存两类本子：账号密码本落到自己的当前本，不抢备忘录本的选中。
      final book = await read(
        memoRepositoryProvider,
      ).getBook(bookId, accountId: read(currentAccountIdProvider));
      await (book?.type == memoBookTypeCredentials
              ? read(currentCredentialBookIdProvider.notifier)
              : read(currentMemoBookIdProvider.notifier))
          .select(bookId);
    case AppMode.fitness:
      // 健身空间使用独立的选择入口。
      throw StateError('请通过健身空间入口选择');
  }
  modeNotifier.set(mode);
  tabNotifier.set(0);
}
