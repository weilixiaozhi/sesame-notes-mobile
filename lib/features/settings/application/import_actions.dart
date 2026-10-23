library;

import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart';

/// 账单导入用例编排：确认页与仓储之间的唯一入口。
///
/// 用例负责读取成员、调用仓储落库与统计待同步条数；
/// 确认页只组装 ImportData 并显示进度反馈。

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/sync_providers.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import '../../../data/models/private_book.dart';
import '../../../shared/providers/account_state_provider.dart';
import 'package:file_picker/file_picker.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/mappers/ledger_member_display_mapper.dart';
import 'package:sesame_notes/data/models/ledger_member_display.dart';
import 'package:sesame_notes/data/models/import_models.dart';
import 'package:sesame_notes/features/settings/infrastructure/data_import_service.dart';
import 'package:sesame_notes/features/settings/infrastructure/file_reader.dart';
import 'package:sesame_notes/features/settings/infrastructure/parsers/xlsx_reader.dart';

/// 账单导入用例编排。
class ImportActions {
  ImportActions(this.ref);

  Future<PrivateBookTarget> target(String id) async {
    final account = ref.read(currentAccountIdProvider);
    final generation = ref.read(authIdentityGenerationProvider);
    final book = await _repo.getLedgerById(id);
    if (book == null) throw StateError('导入账本不可用');
    final fixed = (
      bookId: id,
      accountId: account,
      generation: generation,
      syncId: book.syncId,
    );
    await validateTarget(fixed);
    return fixed;
  }

  Future<void> validateTarget(PrivateBookTarget fixed) async {
    if (ref.read(currentAccountIdProvider) != fixed.accountId ||
        ref.read(authIdentityGenerationProvider) != fixed.generation) {
      throw StateError('导入身份已变化');
    }
    final book = await _repo.getLedgerById(fixed.bookId);
    if (book == null ||
        book.deletedAt != null ||
        (book.storageMode == 'cloud' &&
            book.scopeAccountId != fixed.accountId) ||
        !matchesPrivateBookTarget(fixed, (
          bookId: book.id,
          syncId: book.syncId,
          accountId: ref.read(currentAccountIdProvider),
          generation: ref.read(authIdentityGenerationProvider),
        ))) {
      throw StateError('导入账本身份已变化');
    }
    await _repo.requireActiveLedger(fixed.bookId);
    if (ref.read(currentAccountIdProvider) != fixed.accountId ||
        ref.read(authIdentityGenerationProvider) != fixed.generation) {
      throw StateError('导入身份已变化');
    }
  }

  /// 每次读取当前账号的传输仓储与同步串行边界。
  final Ref ref;

  AccountingTransferRepository get _repo =>
      ref.read(transferDataAccessProvider);

  /// 读取 CSV/XLSX 文件并统一转换成 CSV 文本。
  Future<String> readFile(
    PlatformFile file, {
    required bool Function() isCancelled,
    required void Function(double progress) onProgress,
  }) async {
    try {
      return await FileReaderService.readFile(
        file,
        isCancelled: isCancelled,
        onProgress: onProgress,
        xlsxConverter: XlsxReader.convertXlsxToCSVAsync,
      );
    } on FileReadCancelledException {
      throw const ImportFileReadCancelled();
    } on XlsxFormulaException catch (error) {
      throw ImportFileFormulaException(error.formula);
    } catch (e, st) {
      logger.error('ImportActions', '读取导入文件失败', e, st);
      rethrow;
    }
  }

  /// 取成员（本地账本用它校验 self member 是否真的落在目标账本上）。
  Future<LedgerMemberDisplay?> getMember(String id) async =>
      (await _repo.getMemberById(id))?.toDisplay();

  /// 统计该账本尚未推送的变更条数（导入完成提示用）。
  Future<int> countPendingChanges(String ledgerId) =>
      _repo.countPendingSyncChanges(ledgerId);

  /// 执行导入；[allowedCategoryIds] 非 null 时只允许目标账本 Owner 分类镜像，
  /// 共享非 Owner 场景禁止新建个人分类。
  Future<ImportResult> import({
    required PrivateBookTarget target,
    required ImportData data,
    String? authorMemberId,
    bool allowCategoryCreation = true,
    Set<String>? allowedCategoryIds,
    void Function(int done, int total)? onProgress,
    void Function(String phase)? onPhase,
  }) async {
    final ledgerId = target.bookId;
    try {
      final repository = _repo;
      return await ref
          .read(syncCoordinatorProvider)
          .runDataMutation(
            () => repository.runInTransaction(() async {
              await validateTarget(target);
              final categoryQueries = ref.read(categoryQueriesProvider);
              var currentAllowedCategoryIds = allowedCategoryIds;
              if (data.transactions.any((row) => row.categoryId != null)) {
                // 预览中的分类映射可能已被删除或移出当前账本，写入事务重新读取目录。
                final currentIds =
                    (await categoryQueries.getAllCategoriesIncludingShared(
                      ledgerId: ledgerId,
                    )).map((row) => row.id).toSet();
                currentAllowedCategoryIds = allowedCategoryIds == null
                    ? currentIds
                    : currentIds.intersection(allowedCategoryIds);
              }
              final result = await dataImportService.importData(
                repository,
                ledgerId,
                data,
                categoryQueries: categoryQueries,
                authorMemberId: authorMemberId,
                allowCategoryCreation: allowCategoryCreation,
                allowedCategoryIds: currentAllowedCategoryIds,
                onProgress: onProgress,
                onPhase: onPhase,
              );
              await validateTarget(target);
              return result;
            }),
          );
    } catch (error, stackTrace) {
      logger.error('ImportActions', '导入账本失败: $ledgerId', error, stackTrace);
      rethrow;
    }
  }
}

/// 账单导入用例 provider。
final importActionsProvider = Provider<ImportActions>(
  (ref) => ImportActions(ref),
);

/// 文件读取被用户取消。
class ImportFileReadCancelled implements Exception {
  const ImportFileReadCancelled();
}

/// XLSX 公式缺少缓存计算结果。
class ImportFileFormulaException implements Exception {
  const ImportFileFormulaException(this.formula);

  final String formula;
}
