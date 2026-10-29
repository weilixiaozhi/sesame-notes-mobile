import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'category_scope.dart';
import 'package:sesame_notes/utils/text_validation.dart';

/// 同一分类身份内容冲突保留两份原始内容，调用者可展示比较后再由用户决策。
class CategoryCloneConflict implements Exception {
  /// 冻结本次复制的来源与目标，不在异常处理中合并记录或改写任何身份。
  const CategoryCloneConflict({required this.source, required this.target});

  final Map<String, Object?> source;
  final Map<String, Object?> target;

  @override
  String toString() => '分类与目标目录存在冲突，请先核对分类后再复制';
}

/// 复制指定目录的分类及祖先，不覆盖目标同 ID 的不同内容，也不读取第三方账号目录。
Future<Map<String, String>> cloneCategoryReferences({
  required SesameDatabase source,
  required SesameDatabase target,
  required Iterable<String> categoryIds,
  required String? sourceAccountId,
  required String? targetAccountId,
  String? sharedLedgerId,
}) async {
  try {
    return await target.transaction(() async {
      final mapping = <String, String>{};
      final visiting = <String>{};

      /// 按明确来源读取单行；共享本只使用该本镜像，私有和本地目录分别按指定域定位。
      Future<Map<String, Object?>?> readSource(String id) async {
        if (sharedLedgerId != null) {
          final row =
              await (source.select(source.sharedLedgerCategories)..where(
                    (c) =>
                        c.ledgerId.equals(sharedLedgerId) &
                        c.categoryId.equals(id),
                  ))
                  .getSingleOrNull();
          return row == null
              ? null
              : {
                  'id': row.categoryId,
                  'name': row.name,
                  'kind': row.kind,
                  'level': row.level,
                  'sort_order': row.sortOrder,
                  'icon': row.icon,
                  'parent_id': row.parentId,
                  'updated_at': row.updatedAt,
                  'deleted_at': row.deletedAt,
                };
        }

        /// 私有查询同时限定实体 UUID 与分类目录，纯本地源采用非空 SQL 域键。
        Future<Category?> read(String? account) =>
            (source.select(source.categories)..where(
                  (c) => c.id.equals(id) & categoryScopePredicate(c, account),
                ))
                .getSingleOrNull();
        final row = await read(sourceAccountId);
        return row == null
            ? null
            : {
                'id': row.id,
                'name': row.name,
                'kind': row.kind,
                'level': row.level,
                'sort_order': row.sortOrder,
                'icon': row.icon,
                'parent_id': row.parentId,
                'scope_account_id': row.scopeAccountId,
                'updated_at': row.updatedAt,
                'deleted_at': row.deletedAt,
              };
      }

      /// 先复制父分类，再比较目标可见内容；相同来源重复复制复用同一身份。
      Future<String> copy(String id) async {
        if (mapping[id] case final existing?) return existing;
        if (!visiting.add(id)) throw StateError('分类父子关系异常，复制已取消');
        final row = await readSource(id);
        if (row == null) throw StateError('分类资料不完整，请先同步后再复制');
        final parent = row['parent_id'] as String?;
        final mappedParent = parent == null ? null : await copy(parent);
        final content = {
          'name': row['name'],
          'kind': row['kind'],
          'level': row['level'],
          'sort_order': row['sort_order'],
          'icon': row['icon'],
          'parent_id': mappedParent,
          'deleted': row['deleted_at'] != null,
        };
        final targetId = id;
        final existing =
            await (target.select(target.categories)..where(
                  (c) =>
                      c.id.equals(targetId) &
                      categoryScopePredicate(c, targetAccountId),
                ))
                .getSingleOrNull();
        if (existing != null) {
          if (normalizeName(existing.name) ==
                  normalizeName(content['name'] as String) &&
              existing.kind == content['kind'] &&
              existing.level == content['level'] &&
              existing.sortOrder == content['sort_order'] &&
              existing.icon == content['icon'] &&
              existing.parentId == mappedParent &&
              (existing.deletedAt != null) == content['deleted']) {
            mapping[id] = targetId;
            visiting.remove(id);
            return targetId;
          }
          throw CategoryCloneConflict(source: row, target: existing.toJson());
        }
        final updated = row['updated_at'] as DateTime;
        final deleted = row['deleted_at'] as DateTime?;
        await target
            .into(target.categories)
            .insert(
              CategoriesCompanion.insert(
                id: targetId,
                name: row['name'] as String,
                kind: row['kind'] as String,
                level: row['level'] as int,
                sortOrder: d.Value(row['sort_order'] as int),
                icon: d.Value(row['icon'] as String?),
                parentId: d.Value(mappedParent),
                scopeAccountId: d.Value(targetAccountId),
                serverVersionToken: const d.Value(null),
                updatedAt: updated,
                deletedAt: d.Value(deleted),
              ),
            );
        mapping[id] = targetId;
        visiting.remove(id);
        return targetId;
      }

      for (final id in categoryIds.toSet()) {
        await copy(id);
      }
      return mapping;
    });
  } catch (error, stack) {
    logger.error('CategoryCopy', '复制分类目录失败', safeErrorSummary(error), stack);
    rethrow;
  }
}
