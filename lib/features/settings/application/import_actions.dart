/// 账单导入用例编排：确认页与仓储之间的唯一入口。
///
/// 导入需要「取成员 → 落库 → 统计待同步条数」三步，且落库服务要求传入仓储
/// 实例。过去确认页直接 read 仓储大门面，既让页面承担装配职责，也让页面测试
/// 必须 mock 整个仓储。收敛到本类后，页面只负责组装 ImportData 与进度反馈。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/mappers/ledger_member_display_mapper.dart';
import 'package:sesame_notes/data/models/ledger_member_display.dart';
import 'package:sesame_notes/data/models/import_models.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/features/settings/infrastructure/data_import_service.dart'
    hide ImportCancelledException;
import 'package:sesame_notes/features/settings/infrastructure/file_reader.dart';
import 'package:sesame_notes/features/settings/infrastructure/parsers/csv_parser.dart';
import 'package:sesame_notes/features/settings/infrastructure/parsers/generic_parser.dart';
import 'package:sesame_notes/features/settings/infrastructure/parsers/xlsx_reader.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';

/// 账单导入用例编排。
class ImportActions {
  ImportActions(this.ref);

  /// 持有 Ref 是为了与 [LedgerStorageActions] 保持一致的入口形态。
  final Ref ref;

  LocalRepository get _repo => ref.read(repositoryProvider);

  final GenericBillParser _billParser = GenericBillParser();

  /// 定位账单表头行。
  int findHeaderRow(List<List<String>> rows) => _billParser.findHeaderRow(rows);

  /// 把账单表头映射为导入字段列号。
  Map<String, int> mapColumns(List<String> headerRow) =>
      _billParser.mapColumns(headerRow);

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
        xlsxConverter: (bytes) {
          try {
            return XlsxReader.convertXlsxToCSV(bytes);
          } on XlsxFormulaException catch (e) {
            throw ImportFileFormulaException(e.formula);
          }
        },
      );
    } on FileReadCancelledException {
      throw const ImportFileReadCancelled();
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
    required String ledgerId,
    required ImportData data,
    String? authorMemberId,
    bool allowCategoryCreation = true,
    Set<String>? allowedCategoryIds,
    void Function(int done, int total)? onProgress,
    void Function(String phase)? onPhase,
  }) => dataImportService.importData(
    _repo,
    ledgerId,
    data,
    authorMemberId: authorMemberId,
    allowCategoryCreation: allowCategoryCreation,
    allowedCategoryIds: allowedCategoryIds,
    onProgress: onProgress,
    onPhase: onPhase,
  );
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

/// 导入在批次间隙被用户取消。
class ImportCancelledException implements Exception {
  const ImportCancelledException();
}

/// 在后台 isolate 中解析 CSV 文本。
List<List<String>> parseImportRows(String input) => CsvParser.parse(input);

/// 生成 CSV 行的确定性幂等标识。
String buildCsvImportSyncId({
  required String targetLedgerId,
  required String fileHash,
  required int rowIndex,
}) => csvImportSyncId(
  targetLedgerId: targetLedgerId,
  fileHash: fileHash,
  rowIndex: rowIndex,
);

/// 校验页面组装完成的导入交易。
List<String> validateImportTransactionInput(ImportTransaction transaction) =>
    validateImportTransaction(transaction);
