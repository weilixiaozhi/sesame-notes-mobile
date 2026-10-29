import 'package:sesame_notes/utils/text_validation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/features/categories/application/category_actions.dart';
import 'package:sesame_notes/features/categories/domain/category_edit_logic.dart';
import 'package:sesame_notes/shared/providers/category_query_providers.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/shared/widgets/app_form_section.dart';
import 'package:sesame_notes/features/categories/presentation/widgets/category_selector_dialog.dart';
import 'package:sesame_notes/data/models.dart' as db;
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/formatting/category_utils.dart';
import 'package:sesame_notes/shared/widgets/overlay_keyboard_guard.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/icons/category_icons.dart';
import 'package:sesame_notes/shared/widgets/app_icon_picker.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';

class CategoryEditPage extends ConsumerStatefulWidget {
  final db.CategoryDisplay? category; // null表示新建
  final db.CategoryDisplay? parentCategory; // 父分类（用于创建二级分类）
  final String? ledgerId;

  const CategoryEditPage({
    super.key,
    this.category,
    this.parentCategory,
    this.ledgerId,
  });

  @override
  ConsumerState<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends ConsumerState<CategoryEditPage> {
  late final CategoryActions _actions;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String? _selectedIcon;
  bool _saving = false;
  // 父分类相关状态
  db.CategoryDisplay? _selectedParentCategory;
  bool _parentLoading = false;
  bool _parentLoadFailed = false;

  /// 当前编辑的分类是否已有子分类（编辑模式下异步加载）
  /// 为 true 时所属分类行置灰不可点击。
  bool _hasChildren = false;

  @override
  void initState() {
    super.initState();
    _actions = ref.read(categoryActionsProvider);
    _nameController = TextEditingController(text: widget.category?.name ?? '');

    // 确保选中的图标在可用的图标组中存在
    _selectedIcon = resolveCategoryFormIcon(
      widget.category?.icon,
      availableIconKeys: lucideIconLibrary.keys.toSet(),
    );

    // 初始化父分类状态
    if (widget.category != null) {
      // 编辑模式：加载现有父分类
      if (widget.category!.parentId != null) {
        _loadParentCategory(widget.category!.parentId!);
      }
      // 异步检查当前分类是否有子分类（决定所属分类行是否可点击）
      _loadHasChildren();
    } else if (widget.parentCategory != null) {
      // 创建二级分类模式：预设父分类
      _selectedParentCategory = widget.parentCategory;
    }
  }

  /// 异步加载当前编辑分类是否有子分类
  /// 有子分类时所属分类行置灰，无法修改父分类。
  Future<void> _loadHasChildren() async {
    if (widget.category == null) return;
    try {
      final hasChildren = await _actions.hasSubCategories(
        widget.category!.id,
        ledgerId: widget.ledgerId,
      );
      if (mounted) {
        setState(() {
          _hasChildren = hasChildren;
        });
      }
    } catch (e, st) {
      // 查询失败时保守视为「已有子分类」:禁用所属分类修改,避免把带子分类的
      // 父分类改挂到别处造成数据错乱。
      logger.error('CategoryEdit', '加载子分类状态失败', e, st);
      if (mounted) {
        setState(() => _hasChildren = true);
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 原父级未读出前阻断保存；读取失败不能被解释为用户选择了一级分类。
  Future<void> _loadParentCategory(String parentId) async {
    setState(() {
      _parentLoading = true;
      _parentLoadFailed = false;
    });
    try {
      final parent = await _actions.getById(
        parentId,
        ledgerId: widget.ledgerId,
      );
      if (parent == null) throw StateError('分类父级不可用，请重新加载');
      if (mounted) {
        setState(() {
          _selectedParentCategory = parent;
        });
      }
    } catch (e, st) {
      logger.error('CategoryEdit', '加载父分类失败', safeErrorSummary(e), st);
      if (mounted) setState(() => _parentLoadFailed = true);
    } finally {
      if (mounted) setState(() => _parentLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.category != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    String headerTitle;
    if (isEditing) {
      headerTitle = l10n.categoryEditTitle;
    } else {
      headerTitle = l10n.categoryNewTitle;
    }

    return _buildScaffold(context, headerTitle);
  }

  Widget _buildScaffold(BuildContext context, String headerTitle) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(
            title: headerTitle,
            showBack: true,
            // 编辑模式恒显示分类汇总入口：编辑对象恒存在，入口始终可见
            actions: isEditing
                ? [
                    HeaderIconAction(
                      icon: AppIcons.categoryDetail,
                      tooltip: l10n.categoryDetailTooltip,
                      onPressed: _openCategoryDetails,
                    ),
                  ]
                : null,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.p16),
                children: [
                  AppFormSection(
                    title: l10n.categoryNameLabel,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: l10n.categoryNameHint,
                      ),
                      maxLength: maxNameLength,
                      validator: (value) {
                        if (!isValidName(value ?? '')) {
                          return l10n.commonNameInvalid(maxNameLength);
                        }
                        return null;
                      },
                    ),
                  ),
                  _buildParentCategoryCard(context),
                  if (_parentLoading) const LinearProgressIndicator(),
                  if (_parentLoadFailed)
                    AppLoadError(
                      message: l10n.commonOperationFailed,
                      onRetry: () =>
                          _loadParentCategory(widget.category!.parentId!),
                    ),
                  AppIconPicker(
                    selectedIcon: _selectedIcon,
                    onIconSelected: (icon) =>
                        setState(() => _selectedIcon = icon),
                  ),
                ],
              ),
            ),
          ),

          AppEditorFooter(
            label: l10n.commonSave,
            busy: _saving,
            onPressed: _parentLoading || _parentLoadFailed
                ? null
                : _saveCategory,
          ),
        ],
      ),
    );
  }

  /// 白底卡片内使用主题灰色选择框，有子分类时展示禁用提示。
  Widget _buildParentCategoryCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppFormSection(
      child: AppSelectionField(
        title: _selectedParentCategory == null
            ? l10n.categorySelectParentHint
            : CategoryUtils.getDisplayName(
                _selectedParentCategory!.name,
                context,
              ),
        isPlaceholder: _selectedParentCategory == null,
        enabled:
            !_hasChildren && !_parentLoading && !_parentLoadFailed && !_saving,
        subtitle: _hasChildren ? l10n.categoryHasSubCategories : null,
        onTap: _selectParentCategory,
      ),
    );
  }

  /// 分类摘要固定到同目录的本人账本，不能把个人分类解析成另一所有者的同 UUID。
  void _openCategoryDetails() async {
    try {
      final category = widget.category;
      final ledgerId = await _actions.getCategoryDetailsLedgerId(
        category,
        ledgerId: widget.ledgerId,
      );
      if (!mounted) return;
      if (category == null || ledgerId == null) {
        showToast(context, '请先选择属于这项分类的账本，再查看分类记录。');
        return;
      }
      context.pushNamed(
        Routes.categoryDetail,
        queryParameters: {'ledgerId': ledgerId},
        extra: (category.id, category.name, null, null, null),
      );
    } catch (error, stack) {
      logger.error('CategoryEdit', '打开分类摘要失败', safeErrorSummary(error), stack);
      if (mounted) {
        showToast(
          context,
          categoryActionErrorMessage(
            error,
            AppLocalizations.of(context).commonOperationFailed,
          ),
        );
      }
    }
  }

  /// 保存前完成名称校验，整个异步流程共用忙碌状态和错误反馈。
  void _saveCategory() async {
    if (_saving || _parentLoading || _parentLoadFailed) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await _actions.requireCategoryContextForLedger(
        widget.category,
        ledgerId: widget.ledgerId,
      );
      await _actions.requireCategoryContextForLedger(
        widget.parentCategory,
        ledgerId: widget.ledgerId,
      );
      await _actions.requireCategoryContextForLedger(
        _selectedParentCategory,
        ledgerId: widget.ledgerId,
      );
      final actions = _actions;
      final name = normalizeName(_nameController.text);

      if (isEditing) {
        // 编辑现有分类：parentId 空串表示清空父分类（二级降为一级）
        final placement = resolveCategoryPlacement(
          selectedParentId: _selectedParentCategory?.id,
          currentParentId: widget.category!.parentId,
        );

        await actions.update(
          widget.category!.id,
          name: name,
          icon: _selectedIcon,
          ledgerId: widget.ledgerId,
          parentId: placement,
        );

        if (!mounted) return;
        showToast(context, AppLocalizations.of(context).categoryUpdated(name));
      } else {
        await actions.create(
          name: name,
          kind: 'expense',
          icon: _selectedIcon,
          parentId: _selectedParentCategory?.id,
          ledgerId: widget.ledgerId,
        );
        if (!mounted) return;
        showToast(context, AppLocalizations.of(context).categoryCreated(name));
      }

      // 刷新分类列表
      ref.invalidate(categoriesProvider);

      if (!mounted) return;
      Navigator.of(context).pop(true); // 返回true表示有更新
    } catch (e, st) {
      logger.error('CategoryEdit', '保存分类失败', e, st);
      if (!mounted) return;
      await _showSaveError(
        categoryActionErrorMessage(
          e,
          AppLocalizations.of(context).commonOperationFailed,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// 保存操作已结束，错误提示等待用户关闭时不继续展示保存进度。
  Future<void> _showSaveError(String message) async {
    setState(() => _saving = false);
    await AppDialog.error(
      context,
      title: AppLocalizations.of(context).categorySaveError,
      message: message,
    );
  }

  /// 拉起选择所属分类 BottomSheet
  /// 过滤逻辑：有子分类的一级分类 OR 无交易记录的一级分类
  void _selectParentCategory() async {
    // 收起键盘并等待动画结束，避免选择所属分类后键盘重新弹出（与记账页 _pickDate() 统一）。
    await prepareForOverlay();
    if (!mounted) return;

    final actions = _actions;

    try {
      await _actions.requireCategoryContextForLedger(
        widget.category,
        ledgerId: widget.ledgerId,
      );
      if (!mounted) return;
      final selected = await showParentCategorySelector(
        context,
        initialSelection: _selectedParentCategory,
        ledgerId: widget.ledgerId,
        categoryActions: _actions,
        // 编辑模式排除当前分类自身（不能选自己做父分类）
        excludeIds: isEditing ? [widget.category!.id] : null,
        categoryFilter: (category) async {
          // 可选条件：有子分类 OR 没有交易记录
          if (await actions.hasSubCategories(
            category.id,
            ledgerId: widget.ledgerId,
          )) {
            return true;
          }

          return await actions.countTransactions(
                category.id,
                ledgerId: widget.ledgerId,
              ) ==
              0;
        },
      );

      if (selected != null && mounted) {
        setState(() {
          _selectedParentCategory = selected;
        });
      }
    } catch (error, stackTrace) {
      logger.error('CategoryEdit', '加载所属分类失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }
}
