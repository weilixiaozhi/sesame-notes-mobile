import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models.dart' as db;
import 'package:sesame_notes/data/repositories/contracts/accounting_repositories.dart'
    show CategoryParentUnavailableException;
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/features/categories/application/category_template_providers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/application/provider_reader.dart';
import 'package:sesame_notes/shared/providers/category_query_providers.dart';
import 'package:sesame_notes/shared/widgets/app_form_section.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'category_template_widgets.dart';
import 'widgets/category_selector_dialog.dart';
import 'widgets/compact_category_tile.dart';

/// 模板库的两个明确操作：新建父子组，或向用户指定的已有父分类添加子项。
class CategoryTemplatesPage extends ConsumerStatefulWidget {
  const CategoryTemplatesPage({super.key});

  @override
  ConsumerState<CategoryTemplatesPage> createState() =>
      _CategoryTemplatesPageState();
}

class _CategoryTemplatesPageState extends ConsumerState<CategoryTemplatesPage> {
  late final TemplateInsertSession _session;
  bool _append = false;
  bool _busy = false;
  bool _writing = false;
  bool _failed = false;
  bool _expired = false;
  String? _expandedKey;
  Set<String> _selected = {};
  db.CategoryDisplay? _target;
  TemplateInsertPlan? _attempt;

  /// 页面打开即固定会话，目标选择期间切号或切本也不能变更写入归属。
  @override
  void initState() {
    super.initState();
    _session = captureTemplateInsertSession(
      ref.read(applicationReaderProvider),
    );
  }

  bool get _locked => _busy || _attempt != null || _expired;

  /// 新建模式展示分类树；追加模式仅展示独立节点，已有目录不参与模板状态判断。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final groups = buildCategoryTemplateGroups(l);
    final selected = effectiveTemplateSelection(
      groups: groups,
      selectedKeys: _selected,
      appendToParent: _append,
    );
    final allKeys = {
      for (final group in groups) ...[
        group.parent.key,
        ...group.children.map((child) => child.key),
      ],
    };
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        body: Column(
          children: [
            PrimaryHeader(
              title: l.categoryTemplateLibraryTitle,
              subtitle: l.categoryTemplatePersonalScope,
              showBack: true,
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: false,
                        label: Text(l.categoryTemplateCreateMode),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text(l.categoryTemplateAppendMode),
                      ),
                    ],
                    selected: {_append},
                    onSelectionChanged: _locked
                        ? null
                        : (values) => setState(() {
                            _append = values.single;
                            _selected = {};
                          }),
                  ),
                  if (_append) ...[
                    const SizedBox(height: AppDimens.p12),
                    AppSelectionField(
                      key: const ValueKey('template-target'),
                      enabled: !_locked,
                      onTap: _chooseTarget,
                      child: Row(
                        children: [
                          Text(
                            l.categoryTemplateTargetPrefix,
                            style: AppTextTokens.caption(context),
                          ),
                          const SizedBox(width: AppDimens.p8),
                          if (_target != null) ...[
                            CategoryIconWidget(
                              iconName: _target!.icon,
                              size: AppDimens.icon22,
                              showBackground: true,
                              backgroundSize: AppDimens.icon28,
                            ),
                            const SizedBox(width: AppDimens.p8),
                          ],
                          Expanded(
                            child: Text(
                              _target?.name ?? l.categoryTemplateChooseTarget,
                              style: AppTextTokens.body(context),
                            ),
                          ),
                          if (_target != null)
                            Text(
                              l.categoryTemplateChangeTarget,
                              style: AppTextTokens.label(
                                context,
                              ).copyWith(color: AppTokens.textLink(context)),
                            ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: AppDimens.p8),
                    Text(
                      l.categoryTemplateCreateHint,
                      style: AppTextTokens.caption(context),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(child: _catalogue(groups, selected)),
            if (_failed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.p16),
                child: Text(
                  l.categoryTemplateRetryHint,
                  style: AppTextTokens.caption(context),
                ),
              ),
            SafeArea(
              top: false,
              child: TemplateBottomBar(
                selectedCount: selected.length,
                allSelected: selected.length == allKeys.length,
                isAdding: _busy,
                isWriting: _writing,
                selectionLocked: _locked,
                canSubmit: !_expired && (!_append || _target != null),
                addLabel: _failed
                    ? l.commonRetry
                    : _append
                    ? l.categoryTemplateAddCount(selected.length)
                    : null,
                onToggleSelectAll: () => setState(
                  () => _selected = selected.length == allKeys.length
                      ? {}
                      : allKeys,
                ),
                onAdd: () => _submit(groups),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 两种操作共用尺寸令牌，追加网格完全移除原模板的分组与展开信息。
  Widget _catalogue(List<CategoryTemplateGroup> groups, Set<String> selected) =>
      LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth - AppDimens.p16 * 2;
          final columns = compactCategoryColumns(context, width);
          if (_append) {
            final items = [
              for (final group in groups) ...[group.parent, ...group.children],
            ];
            return GridView.builder(
              key: const ValueKey('template-flat-grid'),
              padding: const EdgeInsets.fromLTRB(
                AppDimens.p16,
                0,
                AppDimens.p16,
                AppDimens.p8,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: AppDimens.p8,
                mainAxisSpacing: AppDimens.p8,
                mainAxisExtent: compactCategoryTileHeight(context),
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return TemplateItemTile(
                  key: ValueKey('template-flat-${item.key}'),
                  item: item,
                  selected: _selected.contains(item.key),
                  enabled: !_locked,
                  onToggle: () => setState(
                    () => _selected = toggleTemplateSelection(
                      _selected,
                      item.key,
                    ),
                  ),
                );
              },
            );
          }
          final rowCount = (groups.length / columns).ceil();
          return ListView.separated(
            key: const ValueKey('template-group-grid'),
            padding: const EdgeInsets.fromLTRB(
              AppDimens.p16,
              0,
              AppDimens.p16,
              AppDimens.p8,
            ),
            itemCount: rowCount,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimens.p8),
            itemBuilder: (context, rowIndex) {
              final start = rowIndex * columns;
              final row = groups.sublist(
                start,
                (start + columns).clamp(0, groups.length),
              );
              return Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: AppDimens.p8,
                      mainAxisSpacing: AppDimens.p8,
                      mainAxisExtent: compactCategoryTileHeight(context),
                    ),
                    itemCount: row.length,
                    itemBuilder: (context, index) =>
                        _categoryCard(row[index], selected),
                  ),
                  for (final group in row)
                    if (group.children.isNotEmpty &&
                        _expandedKey == group.parent.key)
                      _childrenPanel(group, columns),
                ],
              );
            },
          );
        },
      );

  /// 点击具有子项的分类时始终展示其内容，单独维护展开与本次多选状态。
  Widget _categoryCard(CategoryTemplateGroup group, Set<String> effective) {
    final item = group.parent;
    final checked = effective.contains(item.key);
    return CompactCategoryTile(
      key: ValueKey('template-category-${item.key}'),
      name: item.name,
      iconName: item.iconName,
      selected: checked,
      enabled: !_locked,
      hasChildren: group.children.isNotEmpty,
      expanded: _expandedKey == item.key,
      onTap: () {
        if (_locked) return;
        setState(() {
          // 所选节点只影响本次添加，已有分类与展开位置互不认领。
          if (checked) {
            _selected.remove(item.key);
            _selected.removeAll(group.children.map((child) => child.key));
          } else {
            _selected.add(item.key);
          }
          _expandedKey = group.children.isEmpty ? null : item.key;
        });
      },
    );
  }

  /// 在所属分类所在行下展开子项网格，列数和父卡保持一致。
  Widget _childrenPanel(CategoryTemplateGroup group, int columns) {
    final l = AppLocalizations.of(context);
    final childCount = group.children
        .where((child) => _selected.contains(child.key))
        .length;
    return Container(
      key: ValueKey('template-children-${group.parent.key}'),
      margin: const EdgeInsets.only(top: AppDimens.p8),
      padding: const EdgeInsets.all(AppDimens.p8),
      decoration: BoxDecoration(
        color: AppTokens.surface(context),
        border: Border.fromBorderSide(AppTokens.cardBorder(context)),
        borderRadius: BorderRadius.circular(AppTokens.cardRadius(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppDimens.p8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    group.parent.name,
                    style: AppTextTokens.caption(context),
                  ),
                ),
                Text(
                  l.categoryTemplateCompactSelectedCount(childCount),
                  style: AppTextTokens.caption(context),
                ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: AppDimens.p8,
              mainAxisSpacing: AppDimens.p8,
              mainAxisExtent: compactCategoryTileHeight(context),
            ),
            itemCount: group.children.length,
            itemBuilder: (context, index) {
              final child = group.children[index];
              return TemplateItemTile(
                key: ValueKey('template-child-${child.key}'),
                item: child,
                selected: _selected.contains(child.key),
                enabled: !_locked,
                onToggle: () => setState(
                  () =>
                      _selected = toggleTemplateSelection(_selected, child.key),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 从本人分类目录显式选择目标，保留真实 ID 与图标，不用名称反向匹配。
  Future<void> _chooseTarget() async {
    try {
      _session.assertCurrent();
      final actions = ref.read(categoryActionsProvider);
      final target = await showParentCategorySelector(
        context,
        initialSelection: _target,
        categoryActions: actions,
        compact: true,
        title: AppLocalizations.of(context).categoryTemplateChooseTarget,
      );
      _session.assertCurrent();
      if (!mounted || target == null) return;
      actions.requireCategoryContext(target);
      setState(() => _target = target);
    } catch (error, stack) {
      _report(error, stack);
    }
  }

  /// 确认后冻结一次操作的全部 ID，失败重试复用计划，成功后才允许另一轮主动添加。
  Future<void> _submit(List<CategoryTemplateGroup> groups) async {
    if (_busy || _expired || (_append && _target == null)) return;
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      _session.assertCurrent();
      if (_attempt == null) {
        final plan = buildInsertPlan(
          groups: groups,
          selectedKeys: _selected,
          targetParentId: _append ? _target!.id : null,
        );
        if (plan.total == 0) return;
        final confirmed = await AppDialog.confirm(
          context,
          title: l.categoryTemplateConfirmTitle,
          message: _append
              ? l.categoryTemplateAppendConfirm(plan.total, _target!.name)
              : l.categoryTemplateConfirmMessage(plan.total),
        );
        _session.assertCurrent();
        if (!mounted || confirmed != true) return;
        _attempt = plan;
      }
      setState(() => _writing = true);
      await executeTemplateInsertPlanFromUi(plan: _attempt!, session: _session);
      if (!mounted) return;
      _session.assertCurrent();
      ref.invalidate(categoriesWithCountProvider);
      showToast(context, l.categoryTemplateAddSuccess(_attempt!.total));
      setState(() {
        _attempt = null;
        _selected = {};
        _failed = false;
      });
    } catch (error, stack) {
      if (mounted) {
        setState(() {
          if (error is CategoryParentUnavailableException) {
            // 仓储确认整笔回滚后才能撤销这次计划，保留子项供用户重新选父。
            _attempt = null;
            _target = null;
          }
          _failed = _attempt != null;
        });
      }
      _report(error, stack);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _writing = false;
        });
      }
    }
  }

  /// 记录完整错误并显示固定友好说明，不向用户泄露账号或底层异常。
  void _report(Object error, StackTrace stack) {
    logger.error(
      'CategoryTemplates',
      '分类模板操作失败',
      safeErrorSummary(error),
      stack,
    );
    if (mounted) {
      final l = AppLocalizations.of(context);
      final expired =
          error is StateError &&
          error.message == 'CATEGORY_TEMPLATE_SCOPE_CHANGED';
      if (expired) setState(() => _expired = true);
      showToast(
        context,
        expired
            ? l.categoryTemplateScopeChanged
            : error is CategoryParentUnavailableException
            ? l.categoryTemplateTargetUnavailable
            : l.commonOperationFailed,
      );
    }
  }
}
