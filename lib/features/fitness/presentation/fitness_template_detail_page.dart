import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/router/product_analytics_routes.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/shared/application/serial_draft_writer.dart';
import 'package:flutter/material.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/fitness_library.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/features/fitness/application/fitness_catalog_provider.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import '../application/fitness_providers.dart';
import 'fitness_exercise_editing.dart';
import 'widgets/fitness_library_widgets.dart';
import 'widgets/fitness_exercise_editor.dart';
import 'widgets/fitness_rest_settings.dart';
import 'widgets/fitness_session_summary.dart';
import 'widgets/fitness_editor_footer.dart';
import 'widgets/fitness_set_keyboard.dart';
import 'widgets/fitness_widgets.dart';
import 'widgets/fitness_editable_title.dart';

/// 模板详情为独立页面，动作配置串行保存后才允许开始训练。
///
/// [official] 非空时只读展示官方动作配置；用户模板只用于副本复用判断，
/// 明确确认添加后才把官方内容复制到当前空间。
class FitnessTemplateDetailPage extends ConsumerStatefulWidget {
  const FitnessTemplateDetailPage({
    super.key,
    required this.templateId,
    this.official,
  });
  final String templateId;
  final OfficialFitnessTemplate? official;
  @override
  ConsumerState<FitnessTemplateDetailPage> createState() =>
      _FitnessTemplateDetailPageState();
}

class _FitnessTemplateDetailPageState
    extends ConsumerState<FitnessTemplateDetailPage> {
  @override
  void dispose() {
    _writer.dispose();
    _keyboard.dispose();
    super.dispose();
  }

  final _keyboard = FitnessKeyboardController();
  @override
  void initState() {
    super.initState();
    _keyboard.addListener(_keyboardChanged);
  }

  void _keyboardChanged() {
    if (mounted) setState(() {});
  }

  FitnessTemplate? _draft;

  /// 官方模板动作只展开一次：每次重建都生成新身份会丢掉展开状态。
  late final List<FitnessExercise> _officialExercises = [
    for (final exercise in widget.official?.exercises ?? const [])
      exercise.toFitnessExercise(),
  ];
  FitnessActions? _owner;
  bool _busy = false;
  bool _editingExercises = false;
  final _editingPreferences = FitnessEditingPreferences();
  int get _pending => _writer.pending;
  bool get _failed => _writer.failed;
  late final _writer =
      SerialDraftWriter<
        ({FitnessTemplate draft, void Function(ProductAction) completed})
      >(
        save: (value) async {
          final saved = await _owner!.saveTemplate(value.draft);
          value.completed(ProductAction.fitnessTemplateSaved);
          return (draft: saved, completed: value.completed);
        },
        onSaved: (saved) {
          if (mounted) setState(() => _draft = saved.draft);
        },
        onChanged: () {
          if (mounted) setState(() {});
        },
      );

  /// 将当前输入交给应用保存队列，展示层不组合数据库写入。
  void _save(FitnessTemplate draft) {
    setState(() => _draft = draft);
    final analyticsContext = ref
        .read(productAnalyticsControllerProvider)
        .captureContext();
    _writer.submit((
      draft: draft,
      completed: ref
          .read(productAnalyticsControllerProvider)
          .captureCompletion(
            pageId: 'fitness.template',
            context: analyticsContext,
          ),
    ));
  }

  /// 页面离开或执行训练动作前等待最后一个编辑意图落盘。
  Future<bool> _flush() => _writer.flush();

  /// 无待保存输入时接收最新持久化快照，旧回放不会覆盖更新的保存回执。
  void _synchronizeDraft(FitnessTemplate? stored) {
    if (_pending == 0 &&
        !_failed &&
        !_busy &&
        (stored == null ||
            _draft?.updatedAt == null ||
            stored.updatedAt != null &&
                !stored.updatedAt!.isBefore(_draft!.updatedAt!))) {
      _draft = stored;
    }
  }

  /// 使用仍在接收更新的模板流核实身份，合并选择结果前同步当前草稿。
  List<FitnessExercise>? _currentExercisesForEdit(String templateId) {
    if (widget.official != null || widget.templateId != templateId) return null;
    final stored = ref
        .read(fitnessTemplatesProvider)
        .value
        ?.where((template) => template.id == templateId)
        .firstOrNull;
    if (stored == null) return null;
    _synchronizeDraft(stored);
    return _draft?.id == templateId ? _draft!.exercises : null;
  }

  /// 动作编辑固定发起时的模板，等待期间保留最新草稿并禁止重复操作。
  Future<bool> _editExercises(FitnessExerciseEditIntent intent) async {
    if (_editingExercises || _busy || _owner == null || _draft == null) {
      return false;
    }
    final target = _owner!.target;
    final templateId = widget.templateId;
    ProviderSubscription<Object?>? subscription;
    _keyboard.close();
    setState(() => _editingExercises = true);
    var changed = false;
    try {
      // 页面被动作库覆盖时 watch 会暂停，临时手动订阅保留本次编辑的数据源。
      subscription = ref.listenManual(fitnessTemplatesProvider, (_, _) {});
      await editFitnessExercises(
        context,
        ref,
        target: target,
        intent: intent,
        readCurrentExercises: () => _currentExercisesForEdit(templateId),
        onChanged: (result) {
          final draft = _draft!.copyWith(exercises: result.exercises);
          // 已提交偏好与迁移后的草稿同帧发布，订阅回读慢时也使用正确口径。
          setState(() {
            _editingPreferences.accept(target, result.confirmedPreferences);
            _draft = draft;
          });
          _save(draft);
          changed = true;
        },
      );
    } finally {
      subscription?.close();
      if (mounted) setState(() => _editingExercises = false);
    }
    return changed;
  }

  @override
  Widget build(BuildContext context) {
    final official = widget.official;
    if (official != null) return _buildOfficial(context, official);
    final l = AppLocalizations.of(context);
    final repo = ref.watch(fitnessActionsProvider);
    _owner ??= repo;
    final available = matchesPrivateBookTarget(_owner!.target, repo.target);
    if (available) _owner = repo;
    if (!available) _editingPreferences.clear();
    final templates = ref.watch(fitnessTemplatesProvider);
    final catalog = ref.watch(fitnessCatalogProvider);
    final preferences = ref.watch(fitnessPreferencesProvider);
    final stored = templates.value
        ?.where((t) => t.id == widget.templateId)
        .firstOrNull;
    _synchronizeDraft(stored);
    final template = _draft;
    final canEditName = template != null && available;
    final canEditExercises =
        canEditName &&
        !templates.hasError &&
        !catalog.hasError &&
        !preferences.hasError &&
        templates.hasValue &&
        catalog.hasValue &&
        preferences.hasValue;
    Widget body;
    if (!available) {
      body = AppEmpty(text: l.fitnessLoadFailed);
    } else if (templates.hasError || catalog.hasError || preferences.hasError) {
      body = AppLoadError(
        message: l.fitnessLoadFailed,
        onRetry: () {
          ref.invalidate(fitnessTemplatesProvider);
          ref.invalidate(fitnessCatalogProvider);
          ref.invalidate(fitnessPreferencesProvider);
        },
      );
    } else if (!templates.hasValue ||
        !catalog.hasValue ||
        !preferences.hasValue) {
      body = const Center(child: CircularProgressIndicator());
    } else if (template == null) {
      body = AppEmpty(
        icon: AppIcons.folder,
        text: l.fitnessTemplateMissing,
        subtext: l.fitnessMissingDetailHint,
      );
    } else {
      final editor = FitnessExerciseEditor(
        keyboard: _keyboard,
        exercises: template.exercises,
        catalog: catalog.value!,
        preferences: _editingPreferences.resolve(
          repo.target,
          preferences.value!,
        ),
        onRest: (e) => showFitnessRestSettings(context, ref, [e]),
        onReplaceRequested: (id) => _editExercises(ReplaceFitnessExercise(id)),
        onDeleteRequested: (id) => _editExercises(DeleteFitnessExercise(id)),
        onWeightModeRequested: (id, enabled) =>
            _editExercises(SetFitnessExerciseWeightMode(id, enabled)),
        onChanged: (values) =>
            _save((_draft ?? template).copyWith(exercises: values)),
      );
      body = CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppDimens.p16),
            sliver: SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      if (_failed)
                        AppLoadError(
                          message: l.fitnessSaveFailed,
                          onRetry: () => _save(_draft!),
                        ),
                      FitnessSessionSummary(exercises: template.exercises),
                    ],
                  ),
                ),
                editor,
              ],
            ),
          ),
        ],
      );
    }
    return PopScope(
      canPop:
          !_keyboard.isOpen &&
          _pending == 0 &&
          !_failed &&
          !_busy &&
          !_editingExercises,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _busy || _editingExercises) return;
        if (_keyboard.isOpen) {
          _keyboard.close();
          return;
        }
        if (await _flush() && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(this.context);
          });
        }
      },
      child: Scaffold(
        body: AbsorbPointer(
          absorbing: _busy || _editingExercises,
          child: Column(
            children: [
              !canEditName
                  ? PrimaryHeader(
                      title: template?.name ?? l.fitnessTemplates,
                      showBack: true,
                    )
                  : FitnessEditableTitle(
                      name: template.name,
                      builder: (editor, edit, actions) => PrimaryHeader(
                        title: template.name,
                        titleWidget: editor,
                        titleAction: edit,
                        actions: actions,
                        showBack: true,
                      ),
                      onSave: (name) async {
                        if (_busy) return false;
                        final analyticsContext = ref
                            .read(productAnalyticsControllerProvider)
                            .beginFlow();
                        final completed = ref
                            .read(productAnalyticsControllerProvider)
                            .captureCompletion(
                              pageId: 'fitness.template',
                              context: analyticsContext,
                            );
                        ref
                            .read(productAnalyticsControllerProvider)
                            .trackAction(
                              pageId: 'fitness.template',
                              action: ProductAction.fitnessTemplateSaveClick,
                              context: analyticsContext,
                            );
                        setState(() => _busy = true);
                        try {
                          if (!await _flush() || !context.mounted) return false;
                          return await fitnessRun(context, () async {
                            final saved = await _owner!.saveTemplate(
                              (_draft ?? template).copyWith(name: name),
                            );
                            completed(ProductAction.fitnessTemplateSaved);
                            if (mounted) setState(() => _draft = saved);
                          });
                        } finally {
                          if (mounted) setState(() => _busy = false);
                        }
                      },
                    ),
              Expanded(child: body),
              if (canEditExercises)
                FitnessEditorFooter(
                  keyboard: _keyboard,
                  onRest: template.exercises.isEmpty
                      ? null
                      : () => showFitnessRestSettings(
                          context,
                          ref,
                          template.exercises,
                        ),
                  onAdd: _editingExercises
                      ? null
                      : () => _editExercises(const AddFitnessExercises()),
                  onStart: () async {
                    if (_busy) return;
                    final analyticsContext = ref
                        .read(productAnalyticsControllerProvider)
                        .beginFlow();
                    ref
                        .read(productAnalyticsControllerProvider)
                        .trackAction(
                          pageId: 'fitness.template',
                          action: ProductAction.fitnessWorkoutStartClick,
                          context: analyticsContext,
                        );
                    setState(() => _busy = true);
                    if (await _flush() && context.mounted) {
                      await fitnessRun(context, () async {
                        final workout = await _owner!.startFromTemplate(
                          widget.templateId,
                        );
                        if (context.mounted) {
                          ref
                              .read(productAnalyticsControllerProvider)
                              .trackAction(
                                pageId: 'fitness.template',
                                action: ProductAction.fitnessWorkoutStarted,
                                context: analyticsContext,
                              );
                          final identity = analyticsContext.identity;
                          if (identity.account != null &&
                              analyticsContext.flowId != null) {
                            try {
                              await ref
                                  .read(fitnessAnalyticsProvider)
                                  .remember(
                                    context: analyticsContext,
                                    workoutId: workout.id,
                                  );
                            } catch (error, stackTrace) {
                              logger.error(
                                'ProductAnalytics',
                                '训练统计关联暂不可用，训练记录不受影响',
                                error.runtimeType,
                                stackTrace,
                              );
                            }
                          }
                          if (!context.mounted) return;
                          await context.pushNamed(
                            Routes.fitnessWorkout,
                            extra: ProductAnalyticsNavigation(
                              arguments: workout.id,
                              context: analyticsContext,
                            ),
                          );
                        }
                      });
                    }
                    if (mounted) setState(() => _busy = false);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 官方模板只读态：与我的模板详情同一版式，去掉标题编辑、
  /// 动作菜单与新增入口，只保留动作与组数据预览。
  Widget _buildOfficial(
    BuildContext context,
    OfficialFitnessTemplate official,
  ) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final catalog = ref.watch(fitnessCatalogProvider);
    final copies = ref.watch(fitnessTemplatesProvider).value;
    final added =
        copies?.any((copy) => copy.catalogOrigin?.itemId == official.id) ??
        false;
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        body: AbsorbPointer(
          absorbing: _busy,
          child: Column(
            children: [
              PrimaryHeader(
                title: official.name.resolve(locale),
                showBack: true,
              ),
              Expanded(
                child: catalog.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => AppLoadError(
                    message: l.fitnessLoadFailed,
                    onRetry: () => ref.invalidate(fitnessCatalogProvider),
                  ),
                  data: (definitions) => CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(AppDimens.p16),
                        sliver: SliverMainAxisGroup(
                          slivers: [
                            SliverToBoxAdapter(
                              child: FitnessSessionSummary(
                                exercises: _officialExercises,
                              ),
                            ),
                            FitnessExerciseEditor(
                              readOnly: true,
                              exercises: _officialExercises,
                              catalog: definitions,
                              preferences: const FitnessPreferences(),
                              onChanged: (_) {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppEditorFooter(
                label: added ? l.fitnessAddAgain : l.fitnessAddToMyTemplate,
                busy: _busy,
                onPressed: () => _addOfficial(official),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 把官方模板复制进当前训练空间：同源已有副本时先让用户选择复用或新建。
  Future<void> _addOfficial(OfficialFitnessTemplate official) async {
    if (_busy) return;
    final owner = ref.read(fitnessActionsProvider);
    final analyticsContext = ref
        .read(productAnalyticsControllerProvider)
        .beginFlow();
    final completed = ref
        .read(productAnalyticsControllerProvider)
        .captureCompletion(
          pageId: 'fitness.templates.library.detail',
          context: analyticsContext,
        );
    ref
        .read(productAnalyticsControllerProvider)
        .trackAction(
          pageId: 'fitness.templates.library.detail',
          action: ProductAction.fitnessTemplateAddClick,
          context: analyticsContext,
        );
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    setState(() => _busy = true);
    var added = false;
    try {
      final copies = await loadUserTemplates(ref);
      if (!mounted) return;
      String? reuseTemplateId;
      if (fitnessLatestCopy(copies, official.id) != null) {
        final choice = await chooseTemplateCopies(
          context,
          title: l.fitnessAddToMyTemplate,
          labels: {official.id: official.name.resolve(locale)},
          candidates: {official.id: fitnessCopiesOfOrigin(copies, official.id)},
        );
        if (choice == null || !mounted) return;
        reuseTemplateId = choice[official.id];
      }
      if (!mounted) return;
      final ok = await fitnessRun(context, () async {
        // 副本选择跨越异步边界，确认结果只能写回点击时所属的空间与会话。
        if (!matchesPrivateBookTarget(
          owner.target,
          ref.read(fitnessActionsProvider).target,
        )) {
          throw StateError('FITNESS_TARGET_CHANGED');
        }
        await owner.importCatalogTemplate(
          official.toFitnessTemplate(locale, id: official.id),
          reuseTemplateId: reuseTemplateId,
        );
      });
      if (ok) completed(ProductAction.fitnessTemplateAdded);
      added = ok;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (added && mounted) {
      showToast(context, l.fitnessLibraryAdded);
      fitnessReturnTo(context, Routes.fitnessTemplates);
    }
  }
}
