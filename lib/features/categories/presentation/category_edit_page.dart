import 'package:sesame_notes/utils/text_validation.dart';
import 'dart:async';

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
  bool _isDuplicateName = false;
  String? _duplicateErrorMessage;

  /// 判重查询失败标志:失败时按「不可保存」保守处理,避免重名入库后被 repo 抛错。
  bool _duplicateCheckFailed = false;
  int _duplicateCheckGeneration = 0;
  Timer? _debounceTimer;

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
      if (widget.category!.level == 2 && widget.category!.parentId != null) {
        _loadParentCategory(widget.category!.parentId!);
      }
      // 异步检查当前分类是否有子分类（决定所属分类行是否可点击）
      _loadHasChildren();
    } else if (widget.parentCategory != null) {
      // 创建二级分类模式：预设父分类
      _selectedParentCategory = widget.parentCategory;
    }

    // 监听输入框文本变化，防抖500毫秒后检查重复
    _nameController.addListener(() {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _checkNameDuplicate();
      });
    });
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
    _debounceTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.category != null;

  /// 检查分类名称是否重复
  Future<void> _checkNameDuplicate() async {
    if (!mounted) return;
    final generation = ++_duplicateCheckGeneration;
    final rawName = _nameController.text;
    final parentId = _selectedParentCategory?.id;
    if (!isValidName(rawName)) {
      setState(() {
        _isDuplicateName = false;
        _duplicateErrorMessage = null;
        _duplicateCheckFailed = false;
      });
      return;
    }

    final name = normalizeName(rawName);
    try {
      final excludeId = isEditing ? widget.category!.id : null;

      // 作用域判重:二级分类只和「同一父级下」的兄弟比,一级分类只和其他一级比。
      // 跨父级允许同名(默认 seed 即有「购物>鞋子」「服装>鞋子」)。
      final isDuplicate = await _actions.isNameDuplicate(
        name: name,
        kind: 'expense',
        excludeId: excludeId,
        // 以 _selectedParentCategory 是否为空判定子分类作用域
        parentId: parentId,
        ledgerId: widget.ledgerId,
      );

      if (mounted &&
          generation == _duplicateCheckGeneration &&
          _nameController.text == rawName &&
          _selectedParentCategory?.id == parentId) {
        setState(() {
          _isDuplicateName = isDuplicate;
          _duplicateCheckFailed = false;
          if (isDuplicate) {
            final l10n = AppLocalizations.of(context);
            _duplicateErrorMessage = l10n.categoryNameDuplicate;
          } else {
            _duplicateErrorMessage = null;
          }
        });
        // 触发表单验证更新
        _formKey.currentState?.validate();
      }
    } catch (e, st) {
      // 判重查询失败:禁用保存并提示,避免用户保存后被 repo 抛重名错误。
      logger.error('CategoryEdit', '检查分类名称重复失败', e, st);
      if (mounted &&
          generation == _duplicateCheckGeneration &&
          _nameController.text == rawName &&
          _selectedParentCategory?.id == parentId) {
        setState(() {
          _duplicateCheckFailed = true;
          _duplicateErrorMessage = AppLocalizations.of(
            context,
          ).commonOperationFailed;
        });
        _formKey.currentState?.validate();
      }
    }
  }

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
                        errorText: _duplicateErrorMessage,
                      ),
                      maxLength: maxNameLength,
                      validator: (value) {
                        if (!isValidName(value ?? '')) {
                          return l10n.commonNameInvalid(maxNameLength);
                        }
                        if (_isDuplicateName) return _duplicateErrorMessage;
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
            onPressed:
                _isDuplicateName ||
                    _duplicateCheckFailed ||
                    _parentLoading ||
                    _parentLoadFailed
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
      // 在所属父分类范围内复核名称，查询期间保持按钮禁用。
      final actions = _actions;
      final name = normalizeName(_nameController.text);
      final excludeId = isEditing ? widget.category!.id : null;
      final isDuplicate = await actions.isNameDuplicate(
        name: name,
        kind: 'expense',
        excludeId: excludeId,
        parentId: _selectedParentCategory?.id,
        ledgerId: widget.ledgerId,
      );
      if (!mounted) return;
      if (isDuplicate) {
        await _showSaveError(
          AppLocalizations.of(context).categoryNameDuplicate,
        );
        return;
      }
      // 是否为子分类：有父分类 → level 2，无父分类 → level 1
      final isSubCategory = _selectedParentCategory != null;

      if (isEditing) {
        // 编辑现有分类：parentId 空串表示清空父分类（二级降为一级）
        final placement = resolveCategoryPlacement(
          selectedParentId: _selectedParentCategory?.id,
          currentLevel: widget.category!.level,
        );

        await actions.update(
          widget.category!.id,
          name: name,
          icon: _selectedIcon,
          ledgerId: widget.ledgerId,
          parentId: placement.parentId,
          level: placement.level,
        );

        if (!mounted) return;
        showToast(context, AppLocalizations.of(context).categoryUpdated(name));
      } else {
        // 新建分类
        if (isSubCategory) {
          // 新建二级分类
          await actions.createSub(
            parentId: _selectedParentCategory!.id,
            name: name,
            kind: 'expense',
            icon: _selectedIcon,
            ledgerId: widget.ledgerId,
          );
          if (!mounted) return;
          showToast(
            context,
            AppLocalizations.of(context).categorySubCategoryCreated(name),
          );
        } else {
          // 新建一级分类
          await actions.create(
            name: name,
            kind: 'expense',
            icon: _selectedIcon,
            ledgerId: widget.ledgerId,
          );
          if (!mounted) return;
          showToast(
            context,
            AppLocalizations.of(context).categoryCreated(name),
          );
        }
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
        // 切换父分类后主动重跑判重:防抖只监听文本输入,不改名只切父时
        // 按钮态仍停留在旧父级作用域,这里显式刷新一次。
        _debounceTimer?.cancel();
        _checkNameDuplicate();
      }
    } catch (error, stackTrace) {
      logger.error('CategoryEdit', '加载所属分类失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }
}
