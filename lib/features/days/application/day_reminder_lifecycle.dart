import 'dart:async';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/clock/local_clock.dart';
import '../../../core/logging/logger_service.dart';
import '../../../data/models/day_event.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/providers/account_reminder_invalidation_provider.dart';
import '../../../shared/providers/account_state_provider.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../shared/services/notification/notification_factory.dart';
import 'package:sesame_notes/shared/providers/reminder_settings_provider.dart';
import 'day_providers.dart';
import 'day_reminder.dart';

/// 汇集所有可见本，不跟随首页当前选择；加载期间不使用旧账号的缓存。
final dayReminderEventsProvider = Provider<AsyncValue<List<DayEvent>>>((ref) {
  final settings = ref.watch(reminderSettingsProvider);
  // 配置尚未读出时保持未知状态，系统已接受的提醒继续等待原定时间。
  if (!settings.isLoaded) return const AsyncLoading();
  if (!settings.daysActive) {
    return const AsyncData([]);
  }
  ref.watch(currentAccountIdProvider);
  final books = ref.watch(dayBooksProvider);
  if (books.isLoading) return const AsyncLoading();
  if (books.hasError) return AsyncError(books.error!, books.stackTrace!);
  final result = <DayEvent>[];
  var loading = false;
  for (final book in books.requireValue) {
    if (book.isStale) continue;
    final events = ref.watch(dayEventsProvider(book.id));
    if (events.hasError) return AsyncError(events.error!, events.stackTrace!);
    loading |= events.isLoading;
    if (!events.isLoading) result.addAll(events.requireValue);
  }
  return loading ? const AsyncLoading() : AsyncData(result);
});

/// 常驻应用壳，增删改、同步、切账号、跨日和前台恢复均重新核对通知。
final dayReminderLifecycleProvider = Provider<Future<void> Function()>((ref) {
  DayReminderScheduler? scheduler;
  var disposed = false;
  var observedAccountId = ref.read(currentAccountIdProvider);
  var identityNeedsReset = false;
  var submittedUpdate = 0;

  /// 身份变化先使旧任务失效，同一身份的数据暂不可读则保留系统排期。
  Future<void> update({bool force = false}) async {
    if (disposed) return;
    final accountId = ref.read(currentAccountIdProvider);
    if (observedAccountId != accountId) {
      observedAccountId = accountId;
      identityNeedsReset = true;
    }
    final invalidation = ref.read(accountReminderInvalidationProvider);
    final invalidationPending = invalidation.isPending(
      AccountReminderKind.days,
    );
    final settings = ref.read(reminderSettingsProvider);
    final events = ref.read(dayReminderEventsProvider);
    final eventsReady = !events.isLoading && !events.hasError;
    // 冷启动和同账号的暂时读取失败保留既有排期；已确认的身份变化必须
    // 进入调度队列，即使新数据尚未就绪，也不能继续投递旧账号的内容。
    if (!eventsReady && !identityNeedsReset && !invalidationPending) {
      if (events.hasError) {
        logger.warning('DayReminder', '纪念日数据读取失败，保留既有提醒排队', events.error);
      }
      return;
    }
    final locale =
        ref.read(languageProvider) ?? PlatformDispatcher.instance.locale;
    try {
      scheduler ??= DayReminderScheduler(
        NotificationFactory.getDaysInstance(),
        clock: ref.read(localClockNowProvider),
      );
      // 启动前失效的原账号未进入此调度器，先清空旧排期再接纳当前身份的计划，
      // 避免同日期通知标识重合时把旧账号的通知误当成可沿用的当前提醒。
      final plan = eventsReady && !invalidationPending
          ? planDayReminders(
              events.requireValue,
              settings,
              ref.read(localClockNowProvider)(),
              registeredDates: scheduler!.registeredDates,
            )
          : <int, DayReminder>{};
      // 空计划只清理旧身份的任务，不修改用户的提醒开关；新数据到达后正常排期。
      // 调度器同步递增代次，旧账号仍在等待的原生登记回执也会失效。
      final updateId = ++submittedUpdate;
      await scheduler!.synchronize(
        plan,
        lookupAppLocalizations(locale).reminderDaysTitle,
        force: force,
        accountId: accountId,
      );
      // 只确认最新提交已完成。失败或被后续身份覆盖时继续保留待清理状态，
      // 以便数据通知或前台恢复重试，避免一次平台故障永久留下旧任务。
      if (!disposed &&
          updateId == submittedUpdate &&
          observedAccountId == accountId &&
          ref.read(accountReminderInvalidationProvider).generation ==
              invalidation.generation) {
        identityNeedsReset = false;
        if (invalidationPending) {
          ref
              .read(accountReminderInvalidationProvider.notifier)
              .acknowledge(AccountReminderKind.days, invalidation.generation);
          // 取消成功后才确认事件；当前数据已完整时继续恢复有效提醒。
          if (eventsReady) await update(force: true);
        }
      }
    } on UnsupportedError {
      // 非 Android 平台暂不提供系统提醒，记录与设置仍可使用。
    } catch (error, stack) {
      logger.error('DayReminder', '纪念日提醒更新失败，恢复前台时重试', error, stack);
    }
  }

  ref.listen(dayReminderEventsProvider, (_, _) => unawaited(update()));
  // 设置变动按实际排期内容核对；其他分类的时间与开关不会重复登记纪念日。
  ref.listen(reminderSettingsProvider, (_, _) => unawaited(update()));
  ref.listen(
    currentAccountIdProvider,
    (_, _) => unawaited(update(force: true)),
  );
  ref.listen(
    accountReminderInvalidationProvider.select((state) => state.generation),
    (_, _) => unawaited(update(force: true)),
  );
  ref.listen(languageProvider, (_, _) => unawaited(update(force: true)));
  ref.listen(localTodayProvider, (_, _) => unawaited(update(force: true)));
  ref.onDispose(() => disposed = true);
  unawaited(update());
  return () => update(force: true);
});
