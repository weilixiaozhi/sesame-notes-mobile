import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

import '../../../core/logging/logger_service.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import '../../../data/models.dart';
import '../../../shared/providers/account_state_provider.dart';
import '../../../shared/providers/day_repository_provider.dart';
import '../infrastructure/day_csv_service.dart';
import '../infrastructure/export_file_name.dart';

export '../infrastructure/day_csv_service.dart' show DayCsvDocument;

/// 文件操作开始时固定本子和账号，后续页面选择不会改写目标或来源。
class DayImportTarget {
  final DayBook book;
  final String? accountId;
  final int generation;

  /// 保存预览时的本级同步身份。
  const DayImportTarget(this.book, this.accountId, this.generation);
}

/// 日子文件的读写编排，不创建第二条同步链路。
class DayFileActions {
  final Ref ref;

  /// 复用应用的本仓储和账号上下文。
  DayFileActions(this.ref);

  /// 选择确认时验证写权限并捕获绑定。
  Future<DayImportTarget> target(String id) async {
    final accountId = ref.read(currentAccountIdProvider);
    final generation = ref.read(authIdentityGenerationProvider);
    final book = await ref
        .read(dayTransferRepositoryProvider)
        .requireWritable(id, accountId: accountId);
    final result = DayImportTarget(book, accountId, generation);
    await validateTarget(result);
    return result;
  }

  /// 写前再验证固定身份，由仓储在单事务中重新去重。
  Future<({int imported, int skipped})> import(
    DayImportTarget target,
    DayCsvDocument document, {
    void Function(int, int)? onProgress,
  }) async {
    try {
      await validateTarget(target);
      return await ref
          .read(dayTransferRepositoryProvider)
          .importIntoBook(
            targetDayBookId: target.book.id,
            exportId: document.exportId,
            entries: document.entries,
            accountId: target.accountId,
            expectedSyncId: target.book.syncId,
            expectedBook: target.book,
            validateContext: () => _checkAccount(target),
            onProgress: onProgress,
          );
    } catch (error, stackTrace) {
      logger.error('DayFile', '导入日子失败', safeErrorSummary(error), stackTrace);
      rethrow;
    }
  }

  /// 从同一本地读事务取得父子快照，全部文件生成成功后再交给分享入口。
  ///
  /// [business] 为当前语言的业务名，用于让导出文件名自描述内容来源。
  Future<List<String>> export(
    DayImportTarget target, {
    required String business,
    required Directory outputDirectory,
  }) async {
    final written = <String>[];
    try {
      final repo = ref.read(dayTransferRepositoryProvider);
      final snapshot = await repo.runInTransaction(() async {
        await validateTarget(target);
        final book = await repo.getBook(
          target.book.id,
          accountId: target.accountId,
        );
        if (book == null || book.isStale) throw StateError('日子本不可访问');
        if (book.isCloud && book.syncId != null && book.fullCursor == null) {
          throw StateError('请完成此日子本的首次下载后导出');
        }
        return (
          book: book,
          entries: await repo.getEvents(
            target.book.id,
            accountId: target.accountId,
          ),
        );
      });
      final parts = DayCsvService.encode(
        book: snapshot.book,
        entries: snapshot.entries,
      );
      for (var index = 0; index < parts.length; index++) {
        final file = File(
          path.join(
            outputDirectory.path,
            exportFileName(
              business: business,
              content: snapshot.book.name,
              extension: 'csv',
              exportedAt: DateTime.now(),
              part: parts.length > 1 ? index : null,
            ),
          ),
        );
        written.add(file.path);
        await file.writeAsBytes(parts[index], flush: true);
      }
      await validateTarget(target);
      return written;
    } catch (error, stackTrace) {
      logger.error(
        'DayFile',
        '生成日子导出文件失败',
        safeErrorSummary(error),
        stackTrace,
      );
      for (final filename in written) {
        try {
          final file = File(filename);
          if (await file.exists()) await file.delete();
        } catch (cleanupError, cleanupStack) {
          logger.error(
            'DayFile',
            '清理未完成导出失败',
            safeErrorSummary(cleanupError),
            cleanupStack,
          );
        }
      }
      rethrow;
    }
  }

  /// 已完整下载的云本发生同步失败或尚有本地修改时，允许用户选择导出缓存。
  Future<bool> needsCachedExportConfirmation(DayImportTarget target) async {
    await validateTarget(target);
    final repo = ref.read(dayTransferRepositoryProvider);
    final book = await repo.getBook(
      target.book.id,
      accountId: target.accountId,
    );
    if (book == null || !book.isCloud) return false;
    return repo.hasUnsettledChanges(target.book.id);
  }

  /// 导入提交及导出交付共用身份校验，账号、父本或绑定变化时保留输入并拒绝操作。
  Future<void> validateTarget(DayImportTarget target) async {
    _checkAccount(target);
    final book = await ref
        .read(dayTransferRepositoryProvider)
        .requireWritable(
          target.book.id,
          accountId: target.accountId,
          expectedSyncId: target.book.syncId,
        );
    _checkAccount(target);
    if (book.storageMode != target.book.storageMode ||
        book.scopeAccountId != target.book.scopeAccountId ||
        book.syncId != target.book.syncId) {
      throw StateError('目标日子本绑定已改变，请重新选择');
    }
  }

  /// 仓储事务每个写阶段检查会话，账号变化会回滚整笔导入。
  void _checkAccount(DayImportTarget target) {
    if (ref.read(currentAccountIdProvider) != target.accountId ||
        ref.read(authIdentityGenerationProvider) != target.generation) {
      throw StateError('账号已改变，请重新选择目标');
    }
  }
}

/// 设置页面经应用层调用日子文件能力。
final dayFileActionsProvider = Provider<DayFileActions>(DayFileActions.new);
