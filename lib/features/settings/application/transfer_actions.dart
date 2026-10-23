import 'package:sesame_notes/shared/application/ledger_identity_actions.dart';
import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/shared/providers/accounting_repositories.dart';
import 'dart:convert';
import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/data/models/memo.dart';

import 'package:crypto/crypto.dart';
import 'package:sesame_notes/data/models.dart' as models;
import 'package:sesame_notes/data/models/fitness_catalog.dart';
import 'package:sesame_notes/data/models/memo_json.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/features/ledgers/application/ledger_actions.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';

import '../infrastructure/content_transfer.dart';
import 'package:sesame_notes/domain/fitness/fitness_custom_transfer.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/domain/fitness/fitness_transfer_format.dart';
import '../infrastructure/fitness_table_transfer.dart';
import '../infrastructure/ledger_transfer.dart';
import '../infrastructure/transfer_table.dart';
import 'import_target.dart';
import 'day_file_actions.dart';
import 'fitness_file_actions.dart';
import 'import_actions.dart';

/// 应用容器负责创建导入会话，页面只提交已选目标和文件内容。
final transferActionsFactoryProvider =
    Provider<
      TransferActions Function(DataImportTarget, TransferTable, TransferKind)
    >(
      (ref) =>
          (target, table, kind) =>
              TransferActions(ref.read, target, table, kind),
    );

class TransferPreviewRow {
  final List<int> lines;
  final String title;
  final Object? value;
  final String? error;
  bool duplicate;
  bool selected;
  TransferPreviewRow(
    this.lines,
    this.title,
    this.value, {
    this.error,
    this.duplicate = false,
  }) : selected = error == null && !duplicate;
}

typedef TransferResult = ({
  int imported,
  int skipped,
  int failed,
  bool pendingSync,
});

/// 页面共用一个会话，区别仅在业务转换和已有仓储的写入入口。
class TransferActions {
  final ProviderReader read;
  final DataImportTarget target;
  final TransferTable table;
  final TransferKind kind;
  final DateTime now = DateTime.now().toUtc();
  late String exportId;
  late String sourceBookId;
  MemoBook? memoBook;
  List<models.CategoryDisplay> categories = [];
  List<FitnessExerciseDefinition> catalog = [];
  List<FitnessExerciseDefinition> _targetCatalog = [];
  final categoryMapping = <models.ImportCategoryPath, String?>{};
  final exerciseMapping = <String, String?>{};
  bool requiresExistingCategories = false;
  String targetName = '';
  List<Map<String, Object?>> mappedRows = [];
  List<TransferPreviewRow> preview = [];

  /// 账号密码卡片字段：文件列 → 字段名；null 表示该列不写进卡片。
  List<({String header, String? label})> credentialFields = const [];

  /// 固定目标与表格，依赖解析器由应用容器提供。
  TransferActions(this.read, this.target, this.table, this.kind);

  Future<void> prepare() async {
    target.checkSession(read);
    if (target.ledgerId case final id?) {
      await read(importActionsProvider).validateTarget(target.ledgerTarget!);
      final ledger = await read(ledgerActionsProvider).getById(id);
      if (ledger == null || ledger.isArchived) throw StateError('导入目标不可用');
      targetName = ledger.name;
      requiresExistingCategories =
          ledger.memberCount > 1 && ledger.myRole != 'owner';
      categories = await read(
        categoryActionsProvider,
      ).filterForPicker(ledgerId: id, kind: 'expense', topLevelOnly: false);
    } else if (target.memoTarget case final fixed?) {
      memoBook = await read(
        memoTransferRepositoryProvider,
      ).requireTarget(fixed);
      targetName = memoBook!.name;
    } else if (target.dayTarget case final fixed?) {
      await read(dayFileActionsProvider).validateTarget(fixed);
      targetName = fixed.book.name;
    } else if (target.fitnessTarget case final fixed?) {
      targetName = (await read(
        fitnessSpaceQueryRepositoryProvider,
      ).requireTarget(fixed)).name;
      catalog = await read(fitnessFileActionsProvider).catalog(fixed);
      _targetCatalog = catalog;
    }
  }

  /// 自动匹配与用户改选共享同一张映射表，重新预览不会覆盖人工选择。
  void map(
    Map<String, String?> mapping, [
    Map<String, String> defaults = const {},
    List<({String header, String? label})> cardFields = const [],
  ]) {
    credentialFields = cardFields;
    mappedRows = [
      for (var i = 0; i < table.records.length; i++)
        table.mapped(i, kind, mapping, defaults),
    ];
    // 字段名参与指纹：改名后重导同一个文件不能被当成重复导出跳过。
    exportId = transferId([
      kind.name,
      mappedRows,
      [
        for (final (:header, :label) in cardFields) [header, label],
      ],
    ]);
    sourceBookId = transferId([exportId, 'book']);
    if (kind == TransferKind.ledger) {
      final paths = <models.ImportCategoryPath>{};
      for (final row in mappedRows) {
        final parent = transferText(row, 'category').trim();
        final child = transferText(row, 'sub_category').trim();
        if (parent.isEmpty) continue;
        paths.add((
          kind: 'expense',
          parentName: child.isEmpty ? null : parent,
          name: child.isEmpty ? parent : child,
        ));
      }
      categoryMapping.removeWhere((key, _) => !paths.contains(key));
      for (final path in paths) {
        categoryMapping.putIfAbsent(path, () {
          final found = categories
              .where(
                (c) =>
                    c.kind == path.kind &&
                    c.name == path.name &&
                    (path.parentName == null
                        ? c.parentId == null
                        : categories.any(
                            (p) =>
                                p.id == c.parentId && p.name == path.parentName,
                          )),
              )
              .toList();
          return found.length == 1 ? found.single.id : null;
        });
      }
    }
    if (kind == TransferKind.fitness) {
      final combined = {for (final item in _targetCatalog) item.id: item};
      for (final row in mappedRows) {
        if (row['preferences'] case final Map preferences) {
          // 坏定义仍交给逐条预览报告，不能让一个错误偏好阻断整个映射页面。
          try {
            for (final item in transferCustomCatalog(
              Map<String, dynamic>.from(preferences),
            )) {
              combined[item.id] = item;
            }
          } on Object {
            /* 预览阶段保留该记录的业务错误。 */
          }
        }
      }
      catalog = combined.values.toList();
      final converter = FitnessTableConverter(
        catalog,
        exerciseMapping,
        now,
        sourceBookId,
      );
      final sources = <String>{};
      void collect(Object? node) {
        if (node is List) {
          for (final item in node) {
            collect(item);
          }
        }
        if (node is Map) {
          final exercise =
              node['exercise'] ??
              (node.containsKey('set_id') ? null : node['exercise_id']);
          if (exercise != null) {
            final value = exercise.toString();
            sources.add(value);
            exerciseMapping.putIfAbsent(
              value,
              () => converter.detectExercise(value),
            );
          }
          for (final entry in node.entries) {
            if (entry.key != 'exercise' && entry.key != 'exercise_id') {
              collect(entry.value);
            }
          }
        }
      }

      collect(mappedRows);
      exerciseMapping.removeWhere((key, _) => !sources.contains(key));
    }
  }

  Future<void> buildPreview() async {
    final result = <TransferPreviewRow>[];
    final ledgerHash = kind == TransferKind.ledger
        ? sha256.convert(utf8.encode(jsonEncode(mappedRows))).toString()
        : '';
    final groups = <String, List<int>>{};
    for (var i = 0; i < mappedRows.length; i++) {
      final group = kind == TransferKind.fitness
          ? fitnessTransferGroup(mappedRows[i], i)
          : '$i';
      groups.putIfAbsent(group, () => []).add(i);
    }
    for (final indices in groups.values) {
      if (result.length % 100 == 0) await Future<void>.delayed(Duration.zero);
      final i = indices.first;
      final row = mappedRows[i];
      final id = transferId([exportId, indices]);
      final title = transferText(
        row,
        kind == TransferKind.memo || kind == TransferKind.credentials
            ? 'title'
            : 'name',
        fallback: transferText(
          row,
          'note',
          fallback: transferText(row, 'category'),
        ),
      );
      Object? value;
      String? error;
      try {
        for (final index in indices) {
          for (final field in transferFields[kind]!.where((f) => f.required)) {
            // 偏好记录没有名称；其余类型的名称仍在领域层校验。
            if (kind == TransferKind.fitness &&
                fitnessTransferType(mappedRows[index]['entity_type']) ==
                    'fitness_preferences') {
              continue;
            }
            final cell = mappedRows[index][field.key];
            if (cell == null || cell is String && cell.isEmpty) {
              throw FormatException('${field.label}：必填');
            }
          }
        }
        switch (kind) {
          case TransferKind.ledger:
            // 复用原记账转换器，保持分类路径、金额精度、币种及写入权限规则一致。
            final keys = transferFields[kind]!.map((f) => f.key).toList();
            final bad = <String, int>{}, skipped = <String, int>{};
            final data = buildLedgerImportData(
              rows: [keys.map((k) => row[k]?.toString() ?? '').toList()],
              dataStart: 0,
              targetLedgerId: target.ledgerId!,
              mapping: {for (var c = 0; c < keys.length; c++) keys[c]: c},
              categoryMapping: categoryMapping,
              skippedTypes: skipped,
              badRows: bad,
              sourceHash: ledgerHash,
              sourceIndices: [i],
            );
            if (skipped.isNotEmpty) throw const FormatException('类型：仅支持支出');
            if (bad.isNotEmpty || data.transactions.isEmpty) {
              throw FormatException(
                bad.keys
                    .map(
                      (key) => switch (key) {
                        'amount' => '金额：必须是合法正数',
                        'date' => '日期：无效',
                        _ => key,
                      },
                    )
                    .join('；'),
              );
            }
            if (requiresExistingCategories &&
                data.transactions.single.categoryId == null) {
              throw const FormatException('分类：请选择目标账本已有分类');
            }
            value = data;
          case TransferKind.days:
            value = transferDay(row, id, sourceBookId, now);
          case TransferKind.memo || TransferKind.credentials:
            value = transferMemo(
              row,
              id,
              memoBook!,
              now,
              i,
              record: table.records[i],
              cardFields: kind == TransferKind.credentials
                  ? credentialFields
                  : const [],
            );
          case TransferKind.fitness:
            final record = FitnessTableConverter(
              catalog,
              exerciseMapping,
              now,
              sourceBookId,
            ).convert(indices.map((n) => mappedRows[n]).toList(), id);
            value = FitnessTransferRecord(
              id: record.id,
              entityType: record.entityType,
              fitnessSpaceId: record.fitnessSpaceId,
              payload: normalizeFitnessNames(record.payload),
              deletedAt: record.deletedAt,
            );
        }
      } on models.DayDateException catch (e) {
        error = switch (e.code) {
          'invalid_name' => '名称：不能为空或超过长度限制',
          'stage_end_before_start' => '结束日期：不能早于开始日期',
          'invalid_definition' => '类别、重复规则、日期和倒数设置不一致',
          _ => '日期或历法：日期不存在、闰月无效或超出支持范围',
        };
      } on FitnessValidationException catch (e) {
        error = switch (e.code) {
          'FITNESS_WEIGHT' => '重量：必须是非负数，最多 10 位小数',
          'FITNESS_REPS' || 'FITNESS_SET_INCOMPLETE' => '次数：必须为正整数，已完成组不能缺少次数',
          'FITNESS_EXERCISE_ID' => '动作：请选择目录中的动作',
          'FITNESS_NAME' => '名称：不能为空或超过长度限制',
          'FITNESS_SOURCE' || 'FITNESS_OCCURRENCE' => '关联计划、模板或训练发生标识不一致',
          'FITNESS_TIMESTAMP' || 'FITNESS_DATE' => '日期或时间：无效或修改时间早于创建时间',
          'FITNESS_RUN_SEGMENTS' || 'FITNESS_REST_TIMER' => '训练状态、执行时段或计时状态不一致',
          _ => '训练日、动作、组或状态不符合业务规则，请检查记录内容',
        };
      } on FormatException catch (e) {
        error =
            e.message.startsWith('MEMO_') || e.message == 'INVALID_MEMO_DELTA'
            ? '正文或账号字段：内容格式无效'
            : e.message;
      } catch (_) {
        error = '字段类型或嵌套结构无效，请检查映射';
      }
      result.add(
        TransferPreviewRow(
          indices.map((n) => table.lineNumbers[n]).toList(),
          title,
          value,
          error: error,
        ),
      );
    }
    preview = result;
    await refreshDuplicates();
  }

  Future<void> refreshDuplicates() async {
    final ids = <String>{};
    if (target.ledgerId case final id?) {
      ids.addAll(
        (await read(
          transferDataAccessProvider,
        ).getTransactionsByLedger(id)).map((t) => t.id),
      );
    } else if (target.dayTarget case final fixed?) {
      ids.addAll(
        await read(dayTransferRepositoryProvider).getImportReceipts(
          fixed.book.id,
          exportId,
          accountId: fixed.accountId,
        ),
      );
    } else if (target.memoTarget case final fixed?) {
      final db = read(databaseProvider);
      final receipts =
          await (db.select(db.memoImportReceipts)..where(
                (r) =>
                    r.targetMemoBookId.equals(fixed.bookId) &
                    r.exportId.equals(exportId),
              ))
              .get();
      ids.addAll(receipts.map((r) => r.sourceEntryId));
    } else if (target.fitnessTarget case final fixed?) {
      final db = read(databaseProvider);
      final receipts =
          await (db.select(db.fitnessImportReceipts)..where(
                (r) =>
                    r.fitnessSpaceId.equals(fixed.bookId) &
                    r.exportId.equals(exportId),
              ))
              .get();
      ids.addAll(receipts.map((r) => r.sourceId));
    }
    for (final row in preview) {
      final id = switch (row.value) {
        models.ImportData data => data.transactions.single.syncId,
        models.DayEvent event => event.id,
        MemoEntry entry => entry.id,
        FitnessTransferRecord record => record.id,
        _ => null,
      };
      row.duplicate = ids.contains(id);
      if (row.duplicate) row.selected = false;
    }
  }

  Future<TransferResult> import(
    void Function(int done, int total) progress,
    void Function(String) phase,
  ) async {
    final selected = preview
        .where((r) => r.selected && r.error == null && !r.duplicate)
        .toList();
    if (selected.isEmpty) throw StateError('请选择有效记录');
    target.checkSession(read);
    phase('正在写入');
    progress(0, selected.length);
    if (target.ledgerId case final id?) {
      final ledger = await read(ledgerActionsProvider).getById(id);
      if (ledger == null || ledger.isArchived) throw StateError('导入目标不可用');
      final restricted = ledger.memberCount > 1 && ledger.myRole != 'owner';
      var author = ledger.selfMemberId;
      // 缺 self 指针时统一走身份解析链（self_member_id → 绑定账号成员 → 按账本与
      // 账号派生）：云端本同样解析得出成员，不能因为入库顺序差异让整个导入失败。
      if (author == null || author.isEmpty) {
        author = await authorMemberIdForLedger(read, id);
        if (ledger.storageMode == 'local') {
          final member = await read(importActionsProvider).getMember(author);
          if (member == null || member.ledgerId != id) {
            throw StateError('账本成员身份无效');
          }
        }
      }
      if (author.isEmpty) throw StateError('账本成员身份未就绪');
      final categoriesByPath = <String, models.ImportCategory>{};
      final transactions = <models.ImportTransaction>[];
      for (final row in selected) {
        final data = row.value as models.ImportData;
        for (final c in data.categories) {
          categoriesByPath[jsonEncode([c.kind, c.parentName, c.name])] = c;
        }
        transactions.addAll(data.transactions);
      }
      final sorted = categoriesByPath.values.toList()
        ..sort((a, b) => a.level.compareTo(b.level));
      final result = await read(importActionsProvider).import(
        target: target.ledgerTarget!,
        data: models.ImportData(categories: sorted, transactions: transactions),
        authorMemberId: author,
        allowCategoryCreation: !restricted,
        allowedCategoryIds: restricted
            ? categories.map((c) => c.id).toSet()
            : null,
        onProgress: progress,
        onPhase: phase,
      );
      return (
        imported: result.inserted,
        skipped: result.duplicateSkipped,
        failed: result.failed,
        pendingSync:
            ledger.storageMode == 'cloud' &&
            await read(importActionsProvider).countPendingChanges(id) > 0,
      );
    }
    if (target.dayTarget case final fixed?) {
      final document = DayCsvDocument(
        exportId: exportId,
        entries: selected.map((r) => r.value as models.DayEvent).toList(),
      );
      final result = await read(
        dayFileActionsProvider,
      ).import(fixed, document, onProgress: progress);
      return (
        imported: result.imported,
        skipped: result.skipped,
        failed: 0,
        pendingSync: fixed.book.isCloud,
      );
    }
    if (target.memoTarget case final fixed?) {
      final repo = read(memoTransferRepositoryProvider);
      final book = MemoBook(
        id: sourceBookId,
        name: targetName,
        type: memoBook!.type,
        createdAt: now,
        updatedAt: now,
      );
      final entries = selected.map((r) => r.value as MemoEntry).toList();
      final document = MemoJsonDocument(exportId, now, [
        MemoJsonBook(book, entries),
      ]);
      final input = await repo.previewImport(document, fixed);
      final result = await repo.importJson(input, onProgress: progress);
      return (
        imported: result.imported,
        skipped: result.skipped,
        failed: 0,
        pendingSync: result.pendingSync,
      );
    }
    final fixed = target.fitnessTarget!;
    final records = selected
        .map((r) => r.value as FitnessTransferRecord)
        .toList();
    FitnessTransferFormat.validateRecords(records);
    final space = await read(
      fitnessSpaceQueryRepositoryProvider,
    ).requireTarget(fixed);
    final result = await read(fitnessFileActionsProvider).import(
      fixed,
      FitnessTransferDocument(exportId, now, records, space: space),
      onProgress: progress,
    );
    return (
      imported: result.imported,
      skipped: result.skipped,
      failed: 0,
      pendingSync: space.isCloud,
    );
  }
}
