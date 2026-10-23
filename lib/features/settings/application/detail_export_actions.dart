import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/logging/logger_service.dart';
import '../../../infrastructure/api/api_client_provider.dart';
import '../../../shared/providers/account_state_provider.dart';
import '../../ledgers/application/ledger_actions.dart';
import '../infrastructure/detail_export_service.dart';
import 'day_file_actions.dart';
import 'fitness_file_actions.dart';
import '../../../shared/providers/accounting_repositories.dart';
import 'memo_file_actions.dart';

/// 导出用例由应用容器装配，不与页面生命周期绑定。
final detailExportActionsProvider = Provider<DetailExportActions>(
  (ref) => DetailExportActions(ref.read),
);

/// 页面选中的导出来源；字段为 null 表示该业务本次未勾选。
typedef DetailExportSelection = ({
  String? ledgerId,
  String? dayBookId,
  String? memoBookId,
  String? fitnessSpaceId,
});

/// 导出交付所需文案：业务名、备忘录本子类型名与账本 CSV 表头。
///
/// 由页面按当前语言组装，动作层不依赖 Flutter 本地化实现。
typedef DetailExportCopy = ({
  String ledgerBusiness,
  String dayBusiness,
  String memoBusiness,
  String fitnessBusiness,
  String memoTypeNormal,
  String memoTypeCredentials,
  DetailExportLabels ledgerLabels,
  String Function(String?) categoryLabel,
});

/// 导出账本在提交前已不可用：归档与删除由页面给出不同提示。
class DetailExportLedgerUnavailable implements Exception {
  const DetailExportLedgerUnavailable({required this.archived});

  /// true = 账本已归档（提示恢复使用），false = 账本已不存在。
  final bool archived;
}

/// 明细导出用例：先固定来源，全部文件生成且身份复核成功后再一次性交付。
///
/// 来源固定、整批原子交付与临时文件清理由用例控制，依赖由应用容器注入。
class DetailExportActions {
  /// 绑定依赖解析器，导出操作不持有界面对象。
  DetailExportActions(this.read);

  /// 只解析导出依赖，不提供界面状态或导航能力。
  final ProviderReader read;

  /// 生成并交付一次；返回 null 表示本次未交付（用户取消或页面已离开）。
  ///
  /// [isPageActive] 供页面传入 mounted 判定：导出期间页面退出后不再交付，
  /// 页面退出后保留取消语义并回收已经生成的文件。
  Future<ShareResult?> export(
    DetailExportSelection selection, {
    required DetailExportCopy copy,
    required bool Function() isPageActive,
    Future<bool> Function()? confirmCachedDayExport,
    void Function(int generated)? onProgress,
  }) async {
    final paths = <String>[];
    Directory? outputDirectory;
    try {
      final account = read(currentAccountIdProvider);
      final generation = read(authIdentityGenerationProvider);

      /// 所有导出来源共用开始时的身份，财务单独导出也不能跨账号交付文件。
      void validateSession() {
        if (read(currentAccountIdProvider) != account ||
            read(authIdentityGenerationProvider) != generation) {
          throw StateError('账号已变化，请重新导出');
        }
      }

      final dayActions = read(dayFileActionsProvider);
      final fitnessActions = read(fitnessFileActionsProvider);
      final fitnessTarget = selection.fitnessSpaceId == null
          ? null
          : await fitnessActions.target(selection.fitnessSpaceId!);
      // 在任何文件生成前固定本子及会话，界面列表回落不能改变这次导出的来源。
      final dayTarget = selection.dayBookId == null
          ? null
          : await dayActions.target(selection.dayBookId!);
      if (dayTarget != null &&
          dayTarget.book.isCloud &&
          await dayActions.needsCachedExportConfirmation(dayTarget)) {
        if (!isPageActive()) return null;
        final confirmed = await confirmCachedDayExport?.call();
        if (confirmed != true) return null;
      }
      final memoSnapshot = selection.memoBookId == null
          ? null
          : await prepareMemoExport(read, selection.memoBookId!);
      // 每次导出独占目录，同名文件和失败清理只影响本次操作。
      outputDirectory = await (await getTemporaryDirectory()).createTemp(
        'detail-export-',
      );
      if (selection.ledgerId case final ledgerId?) {
        // 导出页可长时间停留，提交前核对最新状态，禁止从缓存入口查阅归档记录。
        final ledger = await read(ledgerActionsProvider).getById(ledgerId);
        if (!isPageActive()) return null;
        if (ledger == null || ledger.isArchived) {
          throw DetailExportLedgerUnavailable(archived: ledger != null);
        }
        paths.add(
          (await exportDetailCsv(
            repo: read(transferDataAccessProvider),
            categoryQueries: read(categoryQueriesProvider),
            ledgerId: ledgerId,
            business: copy.ledgerBusiness,
            ledgerName: ledger.name,
            labels: copy.ledgerLabels,
            categoryLabel: copy.categoryLabel,
            onProgress: (_) {},
            outputDirectory: outputDirectory,
          )).path,
        );
        onProgress?.call(paths.length);
      }
      if (dayTarget != null) {
        paths.addAll(
          await dayActions.export(
            dayTarget,
            business: copy.dayBusiness,
            outputDirectory: outputDirectory,
          ),
        );
        onProgress?.call(paths.length);
      }
      if (memoSnapshot != null) {
        final book = memoSnapshot.document.books.single.book;
        paths.add(
          await writeMemoExport(
            read,
            memoSnapshot,
            business: copy.memoBusiness,
            outputDirectory: outputDirectory,
            typeLabel: book.type == 'credentials'
                ? copy.memoTypeCredentials
                : copy.memoTypeNormal,
          ),
        );
        onProgress?.call(paths.length);
      }
      if (fitnessTarget != null) {
        paths.add(
          await fitnessActions.export(
            fitnessTarget,
            business: copy.fitnessBusiness,
            outputDirectory: outputDirectory,
          ),
        );
        onProgress?.call(paths.length);
      }
      if (!isPageActive() || paths.isEmpty) return null;
      // 所有文件先完整落盘，再一次性交给系统；任一生成失败都不分享残缺集合。
      if (dayTarget != null) await dayActions.validateTarget(dayTarget);
      if (memoSnapshot != null) await validateMemoExport(read, memoSnapshot);
      if (fitnessTarget != null) {
        await fitnessActions.validateTarget(fitnessTarget);
      }
      validateSession();
      if (!isPageActive()) return null;
      return await SharePlus.instance.share(
        ShareParams(files: [for (final filename in paths) XFile(filename)]),
      );
    } catch (error, stackTrace) {
      logger.error(
        'DetailExportActions',
        '生成或交付导出文件失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    } finally {
      // 整个目录包含已登记文件和写入失败的残片，交付结束后统一回收。
      try {
        if (outputDirectory != null && await outputDirectory.exists()) {
          await outputDirectory.delete(recursive: true);
        }
      } catch (error, stackTrace) {
        logger.error(
          'DetailExportActions',
          '清理临时导出目录失败',
          safeErrorSummary(error),
          stackTrace,
        );
      }
    }
  }
}
