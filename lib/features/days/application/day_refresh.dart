import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

/// 日子刷新结果：区分本机与云端的成功、失败，页面据此选择提示文案。
///
/// [null] 表示结果已经过期（刷新期间账号变化），不发布任何提示。
enum DayRefreshOutcome {
  localSuccess,
  localFailed,
  cloudSuccess,

  /// 云端失败但本地重查成功，仍然向用户报告本地可用。
  cloudFailedButLocalOk,

  /// 云端本连本地快照都读不到，不能谎报刷新成功。
  cloudFailed,
}

/// 刷新结果对应的用户文案。
String dayRefreshMessage(AppLocalizations l10n, DayRefreshOutcome outcome) =>
    switch (outcome) {
      DayRefreshOutcome.localSuccess => l10n.dayPullLocalSuccess,
      DayRefreshOutcome.localFailed => l10n.dayPullLocalFailed,
      DayRefreshOutcome.cloudSuccess => l10n.dayPullCloudSuccess,
      DayRefreshOutcome.cloudFailedButLocalOk =>
        l10n.dayPullCloudFailedButLocalOk,
      DayRefreshOutcome.cloudFailed => l10n.dayPullCloudFailed,
    };

/// 失败结果需要额外的错误提示，成功结果只保留刷新文案。
bool dayRefreshFailed(DayRefreshOutcome outcome) => switch (outcome) {
  DayRefreshOutcome.localSuccess || DayRefreshOutcome.cloudSuccess => false,
  _ => true,
};

/// 日子刷新编排：决定是否触发云端同步，并统一重查本地快照。
///
/// 规则：
/// - 只有当前账号下的云端本（或未指定目标本但已登录）才调用同步协调器，
///   本机本只重读自己的数据库流，不发起网络；
/// - 实际只刷新本地时使用本地文案，云同步完成才使用云端成功文案；
/// - 云端失败仍重查本地，按实际执行结果与本地读取结果共同反馈；
/// - 刷新期间账号变化时丢弃结果，不发布迟到的成功或失败提示。
class DayRefreshAction {
  const DayRefreshAction(this.ref);

  final Ref ref;

  /// 身份与本子只决定是否请求同步，反馈按实际执行结果选择。
  Future<DayRefreshOutcome?> run({DayBook? book}) async {
    final accountId = ref.read(currentAccountIdProvider);
    final generation = ref.read(authIdentityGenerationProvider);

    /// 成功与失败都只属于原身份，同账号重新登录也不接收旧会话的结果。
    bool current() =>
        ref.mounted &&
        ref.read(currentAccountIdProvider) == accountId &&
        ref.read(authIdentityGenerationProvider) == generation;

    // 未显式给出目标本时，已登录就按账号级刷新处理，以便发现其他设备的本子。
    final isCloud = accountId != null && (book?.isCloud ?? true);
    var outcome = DataRefreshOutcome.localOnly;
    try {
      if (isCloud) {
        outcome = DataRefreshOutcome.failed;
        final result = await ref.read(syncCoordinatorProvider).refreshData();
        outcome = result.refreshOutcome;
        if (outcome == DataRefreshOutcome.failed) {
          logger.warning('DaysRefresh', '云端刷新未完成', result.error);
        }
      }
    } catch (error, stackTrace) {
      logger.error('DaysRefresh', '云端刷新失败，继续读取本地数据', error, stackTrace);
    }
    if (!current()) return null;
    try {
      // 与记账刷新一样重查本地快照；数据库流继续订阅，避免切回骨架屏。
      final repository = ref.read(dayQueryRepositoryProvider);
      await repository.getBooks(accountId: accountId);
      if (book != null) {
        await repository.getEvents(book.id, accountId: accountId);
      }
      // 上一次失败的流保持错误态时重新订阅，成功后展示真实数据。
      if (ref.read(dayBooksProvider).hasError) ref.invalidate(dayBooksProvider);
      if (book != null && ref.read(dayEventsProvider(book.id)).hasError) {
        ref.invalidate(dayEventsProvider(book.id));
      }
      if (!current()) return null;
      return switch (outcome) {
        DataRefreshOutcome.localOnly => DayRefreshOutcome.localSuccess,
        DataRefreshOutcome.cloudSynced => DayRefreshOutcome.cloudSuccess,
        DataRefreshOutcome.failed => DayRefreshOutcome.cloudFailedButLocalOk,
      };
    } catch (error, stackTrace) {
      logger.error('DaysRefresh', '刷新日子未完成，保留现有内容', error, stackTrace);
      if (!current()) return null;
      return outcome == DataRefreshOutcome.localOnly
          ? DayRefreshOutcome.localFailed
          : DayRefreshOutcome.cloudFailed;
    }
  }
}

/// 页面通过该入口执行一次刷新，本机与云端分支共用同一编排。
final dayRefreshProvider = Provider<DayRefreshAction>(DayRefreshAction.new);
