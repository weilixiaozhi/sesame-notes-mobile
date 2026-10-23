import 'package:sesame_notes/shared/providers/fitness_builtin_catalog_provider.dart';
import '../../../data/models/private_book.dart';
import '../../../shared/providers/fitness_repository_provider.dart';
import '../../../data/models/fitness_catalog.dart';
import 'package:sesame_notes/domain/fitness/fitness_custom_transfer.dart';
import '../../../shared/providers/fitness_space_provider.dart';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import '../../../shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/sync/storage/change_recorder_impl.dart';
import '../infrastructure/export_file_name.dart';
import 'package:sesame_notes/domain/fitness/fitness_transfer_format.dart';
import 'package:sesame_notes/data/services/fitness_data_transfer.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

export 'package:sesame_notes/domain/fitness/fitness_transfer_format.dart'
    show FitnessTransferDocument;

typedef FitnessFileTarget = PrivateBookTarget;

/// 文件读写与会话绑定；本机和当前账号是实际目标，不创建训练本。
class FitnessFileActions {
  final Ref ref;
  FitnessFileActions(this.ref);

  Future<FitnessFileTarget> target(String id) =>
      ref.read(fitnessSpaceQueryRepositoryProvider).target(id);
  Future<void> validateTarget(FitnessFileTarget target) async {
    await ref.read(fitnessSpaceQueryRepositoryProvider).requireTarget(target);
  }

  /// 按入口选定的目标读取动作，不能借用首页当前健身空间的自定义目录。
  Future<List<FitnessExerciseDefinition>> catalog(
    FitnessFileTarget target,
  ) async {
    await validateTarget(target);
    final preferences = await ref
        .read(fitnessTargetQueryRepositoryProvider(target))
        .getPreferences();
    final builtin = await ref.read(fitnessBuiltinCatalogProvider.future);
    await validateTarget(target);
    return [...builtin, ...transferCustomCatalog(preferences.toJson())];
  }

  /// 固定目标校验与内容写入共用事务，提交前再次确认目标仍可用。
  Future<({int imported, int skipped})> import(
    FitnessFileTarget target,
    FitnessTransferDocument document, {
    void Function(int, int)? onProgress,
  }) async {
    final db = ref.read(databaseProvider);
    try {
      return await db.transaction(() async {
        await validateTarget(target);
        final result = await FitnessDataTransfer.importDocument(
          db: db,
          document: document,
          fitnessSpaceId: target.bookId,
          accountId: target.accountId,
          onProgress: onProgress,
          validateContext: () {
            if (ref.read(currentAccountIdProvider) != target.accountId ||
                ref.read(authIdentityGenerationProvider) != target.generation) {
              throw StateError('FITNESS_SESSION_CHANGED');
            }
          },
          changeRecorder: ChangeRecorderImpl(
            db,
            accountIdGetter: () => ref.read(currentAccountIdProvider),
          ),
        );
        // 本子删除、隐藏或重新绑定后，预览对应的导入授权随即失效。
        await validateTarget(target);
        return (imported: result.imported, skipped: result.skipped);
      });
    } catch (error, stackTrace) {
      logger.error('FitnessFileActions', '健身文件导入失败，已回滚', error, stackTrace);
      rethrow;
    }
  }

  /// [business] 为当前语言的业务名，用于让导出文件名自描述内容来源。
  Future<String> export(
    FitnessFileTarget target, {
    required String business,
    required Directory outputDirectory,
  }) async {
    final db = ref.read(databaseProvider);
    final document = await db.transaction(() async {
      await validateTarget(target);
      final records = await FitnessDataTransfer.snapshot(
        db,
        accountId: target.accountId,
        fitnessSpaceId: target.bookId,
      );
      await validateTarget(target);
      return FitnessTransferDocument(
        const Uuid().v4(),
        DateTime.now().toUtc(),
        records,
        space: await ref
            .read(fitnessSpaceQueryRepositoryProvider)
            .requireTarget(target),
      );
    });
    final bytes = FitnessTransferFormat.encode(document);
    final file = File(
      path.join(
        outputDirectory.path,
        exportFileName(
          business: business,
          content: document.space.name,
          extension: 'json',
          exportedAt: document.exportedAt,
        ),
      ),
    );
    try {
      await file.writeAsBytes(bytes, flush: true);
      await validateTarget(target);
      return file.path;
    } catch (_) {
      if (await file.exists()) await file.delete();
      rethrow;
    }
  }
}

final fitnessFileActionsProvider = Provider<FitnessFileActions>(
  FitnessFileActions.new,
);
