import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_context.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_surface_visibility.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/shared/application/serial_draft_writer.dart';
import '../../../data/models/private_book.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/fitness/application/fitness_catalog_provider.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';
import '../application/fitness_providers.dart';
import 'fitness_exercise_editing.dart';
import 'widgets/fitness_exercise_editor.dart';
import 'widgets/fitness_rest_sheet.dart';
import 'widgets/fitness_widgets.dart';
import 'widgets/fitness_rest_settings.dart';
import 'widgets/fitness_session_summary.dart';
import 'widgets/fitness_editor_footer.dart';
import 'widgets/fitness_set_keyboard.dart';
import 'widgets/fitness_editable_title.dart';

class FitnessWorkoutPage extends ConsumerStatefulWidget {
  /// 入口可传入本次新建的操作流，普通重开由本机索引恢复实际开始流。
  const FitnessWorkoutPage({
    super.key,
    required this.workoutId,
    this.analyticsContext,
  });

  final String workoutId;
  final ProductAnalyticsContext? analyticsContext;
  @override
  ConsumerState<FitnessWorkoutPage> createState() => _FitnessWorkoutPageState();
}

class _FitnessWorkoutPageState extends ConsumerState<FitnessWorkoutPage> {
  late ProductAnalyticsContext _analyticsContext;
  late final Future<void> _analyticsRestored;
  bool _observedStarted = false;
  @override
  void dispose() {
    _writer.dispose();
    fitnessRestSheetVisibility.removeListener(_restSheetClosed);
    _keyboard.dispose();
    fitnessWorkoutVisibility.close(widget.workoutId);
    super.dispose();
  }

  final _keyboard = FitnessKeyboardController();

  /// 统计关联恢复独立于训练内容，失败保留无流的真实访问。
  @override
  void initState() {
    super.initState();
    _analyticsContext =
        widget.analyticsContext ??
        ref.read(productAnalyticsControllerProvider).captureContext();
    _analyticsRestored = _restoreAnalyticsFlow();
    _keyboard.addListener(_keyboardChanged);
    fitnessRestSheetVisibility.addListener(_restSheetClosed);
    fitnessWorkoutVisibility.open(widget.workoutId);
  }

  /// 只恢复同一账号已观察到的开始流，不根据在训状态制造开始关联。
  Future<void> _restoreAnalyticsFlow() async {
    final identity = _analyticsContext.identity;
    if (identity.account == null) return;
    try {
      final flow = await ref
          .read(fitnessAnalyticsProvider)
          .restore(identity: identity, workoutId: widget.workoutId);
      if (!mounted || flow == null) return;
      final current = ref
          .read(productAnalyticsControllerProvider)
          .currentIdentity();
      if (current.account == identity.account &&
          current.generation == identity.generation) {
        _analyticsContext = ref
            .read(productAnalyticsControllerProvider)
            .captureContext()
            .withFlowId(flow);
        _observedStarted = true;
      }
    } catch (error, stackTrace) {
      logger.error(
        'ProductAnalytics',
        '训练统计关联暂不可用，训练功能不受影响',
        error.runtimeType,
        stackTrace,
      );
    }
  }

  /// 本次动作先固定会话，异步加载仅补已知随机流，不能改变动作的会话归属。
  Future<ProductAnalyticsContext> _workoutAnalyticsContext({
    bool start = false,
    bool restart = false,
    bool completion = false,
  }) async {
    final clicked = ref
        .read(productAnalyticsControllerProvider)
        .captureContext(parent: _analyticsContext);
    await _analyticsRestored;
    if (completion && !_observedStarted) return clicked.withFlowId(null);
    final restored = clicked.withFlowId(_analyticsContext.flowId);
    return start && (restart || restored.flowId == null)
        ? beginProductAnalyticsFlowFrom(restored)
        : restored;
  }

  /// 开始成功后落本机索引，完成或删除后清理，业务记录标识只作为本机键。
  Future<void> _storeAnalyticsFlow(
    ProductAnalyticsContext scope, {
    bool remove = false,
  }) async {
    final identity = scope.identity;
    if (identity.account == null) return;
    try {
      final analytics = ref.read(fitnessAnalyticsProvider);
      if (remove) {
        await analytics.forget(context: scope, workoutId: widget.workoutId);
      } else if (scope.flowId != null) {
        await analytics.remember(context: scope, workoutId: widget.workoutId);
      }
    } catch (error, stackTrace) {
      logger.error(
        'ProductAnalytics',
        '训练统计关联暂不可用，训练记录不受影响',
        error.runtimeType,
        stackTrace,
      );
    }
  }

  /// 已自动弹出结束态的休息截止时间，同一段休息只弹一次。
  DateTime? _restPromptedEndsAt;

  /// 休息到时自动弹出结束态弹窗；处于其它页面之上时不抢占弹窗，回到详情后再提示。
  void _promptRestCompletion(FitnessWorkout workout, DateTime now) {
    final timer = workout.restTimer;
    if (workout.status != 'in_progress' || !fitnessRestCompleted(timer, now)) {
      _restPromptedEndsAt = null;
      return;
    }
    final endsAt = timer!.endsAt;
    if (_restPromptedEndsAt == endsAt) return;
    // 详情页被其它页面覆盖时不抢占弹窗，回到详情后仍会提示。
    if (ModalRoute.of(context)?.isCurrent != true) return;
    _restPromptedEndsAt = endsAt;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || fitnessRestSheetVisibility.isOpen(widget.workoutId)) {
        return;
      }
      unawaited(_rest());
    });
  }

  /// 结束态弹窗关闭后仍未处理的休息立即结算，结束态不常驻。
  void _restSheetClosed() {
    if (!mounted || fitnessRestSheetVisibility.isOpen(widget.workoutId)) return;
    unawaited(_settleCompletedRest());
  }

  /// 弹层关闭的异步查询与结算共用错误反馈，读取失败不能成为未处理异常。
  Future<void> _settleCompletedRest() => fitnessRun(context, () async {
    final owner = _owner;
    if (owner == null) return;
    final latest = await owner.getWorkout(widget.workoutId);
    if (!mounted ||
        latest?.status != 'in_progress' ||
        !fitnessRestCompleted(latest?.restTimer, DateTime.now())) {
      return;
    }
    await _run((repo) => repo.skipRest(widget.workoutId));
  });

  void _keyboardChanged() {
    if (mounted) setState(() {});
  }

  FitnessWorkout? _draft;
  FitnessActions? _owner;
  bool _busy = false;
  bool _editingExercises = false;
  final _editingPreferences = FitnessEditingPreferences();
  bool _deleted = false;
  int get _pending => _writer.pending;
  bool get _failed => _writer.failed;
  late final _writer = SerialDraftWriter<FitnessWorkout>(
    save: (draft) => _owner!.saveWorkoutDraft(draft),
    onSaved: (saved) {
      if (mounted) setState(() => _draft = saved);
    },
    onChanged: () {
      if (mounted) setState(() {});
    },
  );

  /// 将当前输入交给应用保存队列，展示层不组合数据库写入。
  void _save(FitnessWorkout draft) {
    setState(() => _draft = draft);
    _writer.submit(draft);
  }

  /// 页面离开或执行训练动作前等待最后一个编辑意图落盘。
  Future<bool> _flush() => _writer.flush();

  /// 接收最新持久化快照，保留正在保存或等待重试的本地编辑。
  void _synchronizeDraft(FitnessWorkout stored) {
    if (_pending == 0 &&
        !_failed &&
        !_busy &&
        (_draft?.updatedAt == null ||
            stored.updatedAt != null &&
                !stored.updatedAt!.isBefore(_draft!.updatedAt!))) {
      _draft = stored;
    }
  }

  /// 选择返回时从活动订阅核实训练仍存在，再读取当前有效的动作列表。
  List<FitnessExercise>? _currentExercisesForEdit(String workoutId) {
    if (_deleted || widget.workoutId != workoutId) return null;
    final stored = ref.read(fitnessWorkoutProvider(workoutId)).value;
    if (stored == null) return null;
    _synchronizeDraft(stored);
    return _draft?.id == workoutId ? _draft!.exercises : null;
  }

  /// 固定训练和空间身份，异步动作编辑完成后合并当前仍有效的草稿。
  Future<bool> _editExercises(FitnessExerciseEditIntent intent) async {
    if (_editingExercises || _busy || _owner == null || _draft == null) {
      return false;
    }
    final target = _owner!.target;
    final workoutId = widget.workoutId;
    ProviderSubscription<Object?>? subscription;
    _keyboard.close();
    setState(() => _editingExercises = true);
    var changed = false;
    try {
      // 选择路由覆盖详情期间仍接收同步删除和更新，不依赖离屏页面重建。
      subscription = ref.listenManual(
        fitnessWorkoutProvider(workoutId),
        (_, _) {},
      );
      await editFitnessExercises(
        context,
        ref,
        target: target,
        intent: intent,
        readCurrentExercises: () => _currentExercisesForEdit(workoutId),
        onChanged: (result) {
          final draft = _draft!.copyWith(exercises: result.exercises);
          // 已提交偏好与迁移后的草稿同帧发布，订阅回读慢时也使用正确口径。
          setState(() {
            _editingPreferences.accept(target, result.confirmedPreferences);
            _draft = draft;
          });
          _writer.submit(draft);
          changed = true;
        },
      );
    } finally {
      subscription?.close();
      if (mounted) setState(() => _editingExercises = false);
    }
    return changed;
  }

  Future<bool> _run(
    Future<FitnessWorkout> Function(FitnessActions) action,
  ) async {
    if (_busy) return false;
    setState(() => _busy = true);
    if (!await _flush() || !mounted) {
      if (mounted) setState(() => _busy = false);
      return false;
    }
    final ok = await fitnessRun(context, () async {
      final saved = await action(_owner!);
      if (mounted) setState(() => _draft = saved);
    });
    if (mounted) setState(() => _busy = false);
    return ok;
  }

  Future<void> _rest() async {
    if (!await _flush() || !mounted) return;
    await showAppSheet<void>(
      context: context,
      child: FitnessRestSheet(workoutId: widget.workoutId),
    );
  }

  /// 删除期间保留详情快照，确认成功后关闭键盘并返回上一页。
  Future<void> _delete() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final analyticsContext = await _workoutAnalyticsContext();
      if (!await _flush() || !mounted) return;
      final lifecycle = ref.read(dataLifecycleProvider);
      final deleted = await fitnessDelete(
        context,
        () => lifecycle.deleteTarget(
          SyncTarget('fitness_workout', widget.workoutId),
        ),
      );
      if (!deleted || !mounted) return;
      await _storeAnalyticsFlow(analyticsContext, remove: true);
      _deleted = true;
      _keyboard.close();
      // 等待页面解除退出限制，再关闭当前详情路由。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    } catch (error, stackTrace) {
      logger.error('Fitness', '删除训练详情失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).fitnessSaveFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 完成点击与持久化完成分别记录，取消确认不会进入完成统计。
  Future<void> _finish(FitnessWorkout workout) async {
    if (_busy) return;
    final analyticsContext = await _workoutAnalyticsContext(completion: true);
    if (!mounted || _busy) return;
    ref
        .read(productAnalyticsControllerProvider)
        .trackAction(
          pageId: 'fitness.workout',
          action: ProductAction.fitnessWorkoutFinishClick,
          context: analyticsContext,
        );
    final l = AppLocalizations.of(context);
    final confirmed = await AppDialog.confirm(
      context,
      title: l.fitnessFinish,
      message: l.fitnessFinishConfirm,
    );
    if (confirmed != true || !mounted) return;
    if (await _run((repo) => repo.finishWorkout(workout.id)) && mounted) {
      ref
          .read(productAnalyticsControllerProvider)
          .trackAction(
            pageId: 'fitness.workout',
            action: ProductAction.fitnessWorkoutCompleted,
            context: analyticsContext,
          );
      await _storeAnalyticsFlow(analyticsContext, remove: true);
      _observedStarted = false;
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  /// 训练开始、恢复与暂停只在领域操作成功后记录对应完成事件。
  Future<void> _changeRunning(
    FitnessWorkout workout, {
    bool pause = false,
  }) async {
    if (_busy) return;
    final analyticsContext = await _workoutAnalyticsContext(
      start: !pause,
      restart: workout.status == 'completed',
    );
    if (!mounted || _busy) return;
    ref
        .read(productAnalyticsControllerProvider)
        .trackAction(
          pageId: 'fitness.workout',
          action: pause
              ? ProductAction.fitnessWorkoutPauseClick
              : ProductAction.fitnessWorkoutStartClick,
          context: analyticsContext,
        );
    try {
      final ok = await _run(
        (repo) => pause
            ? repo.pauseWorkout(workout.id)
            : repo.startWorkout(workout.id),
      );
      if (ok && mounted) {
        ref
            .read(productAnalyticsControllerProvider)
            .trackAction(
              pageId: 'fitness.workout',
              action: pause
                  ? ProductAction.fitnessWorkoutPaused
                  : ProductAction.fitnessWorkoutStarted,
              context: analyticsContext,
            );
        if (!pause) {
          _analyticsContext = analyticsContext;
          _observedStarted = true;
          await _storeAnalyticsFlow(analyticsContext);
        }
      }
    } catch (error, stackTrace) {
      logger.error('Fitness', '训练状态暂时无法更新，当前记录已保留', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).fitnessSaveFailed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final repo = ref.watch(fitnessActionsProvider);
    _owner ??= repo;
    if (matchesPrivateBookTarget(_owner!.target, repo.target)) _owner = repo;
    if (!matchesPrivateBookTarget(_owner!.target, repo.target)) {
      _editingPreferences.clear();
      return AppSheet(child: AppEmpty(text: l.fitnessLoadFailed));
    }
    final workouts = ref.watch(fitnessWorkoutProvider(widget.workoutId));
    final catalog = ref.watch(fitnessCatalogProvider);
    final prefs = ref.watch(fitnessPreferencesProvider);
    final now = ref.watch(fitnessClockProvider).value ?? DateTime.now();
    Widget failure(VoidCallback retry) => AppSheet(
      child: AppLoadError(message: l.fitnessLoadFailed, onRetry: retry),
    );
    if (workouts.hasError) {
      return failure(
        () => ref.invalidate(fitnessWorkoutProvider(widget.workoutId)),
      );
    }
    if (catalog.hasError) {
      return failure(() => ref.invalidate(fitnessCatalogProvider));
    }
    if (prefs.hasError) {
      return failure(() => ref.invalidate(fitnessPreferencesProvider));
    }
    if (!workouts.hasValue || !catalog.hasValue || !prefs.hasValue) {
      return const AppSheet(child: Center(child: CircularProgressIndicator()));
    }
    final stored = workouts.value ?? (_busy || _deleted ? _draft : null);
    if (stored == null) {
      return AppSheet(
        child: AppEmpty(
          icon: AppIcons.fitness,
          text: l.fitnessWorkoutMissing,
          subtext: l.fitnessMissingDetailHint,
        ),
      );
    }
    _synchronizeDraft(stored);
    final w = _draft ?? stored;
    _promptRestCompletion(w, now);
    final running = w.status == 'in_progress';
    final ticking = running && w.runSegments.last.endedAt == null;
    final editor = FitnessExerciseEditor(
      keyboard: _keyboard,
      exercises: w.exercises,
      catalog: catalog.value!,
      preferences: _editingPreferences.resolve(repo.target, prefs.value!),
      execution: true,
      onRest: (e) => showFitnessRestSettings(context, ref, [e]),
      onReplaceRequested: (id) => _editExercises(ReplaceFitnessExercise(id)),
      onDeleteRequested: (id) => _editExercises(DeleteFitnessExercise(id)),
      onWeightModeRequested: (id, enabled) =>
          _editExercises(SetFitnessExerciseWeightMode(id, enabled)),
      onChanged: (exercises) =>
          _save((_draft ?? w).copyWith(exercises: exercises)),
      onCompleted: (e, s, completed) async {
        await _run(
          (repo) => repo.setGroupCompleted(w.id, e.id, s.id, completed),
        );
      },
    );
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
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: AbsorbPointer(
          absorbing: _busy || _editingExercises,
          child: FitnessEditableTitle(
            name: w.name,
            onSave: (name) => _run((repo) async {
              return repo.renameWorkout(w.id, name);
            }),
            builder: (titleEditor, edit, actions) => AppSheet(
              title: w.name,
              titleWidget: titleEditor,
              titleAction: edit,
              trailing: actions.isNotEmpty
                  ? Wrap(children: actions)
                  : IgnorePointer(
                      ignoring: _pending > 0,
                      child: FitnessWorkoutMenu(
                        workout: w,
                        enabled: !_failed,
                        onDelete: _delete,
                      ),
                    ),
              footerPadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimens.p16,
              ),
              footer: FitnessEditorFooter(
                keyboard: _keyboard,
                execution: true,
                onRest: w.exercises.isEmpty
                    ? null
                    : () => showFitnessRestSettings(context, ref, w.exercises),
                onAdd: _editingExercises
                    ? null
                    : () => _editExercises(const AddFitnessExercises()),
              ),
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: AppDimens.p20,
                                bottom: AppDimens.p12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              fitnessDuration(
                                                fitnessElapsed(
                                                  w,
                                                  now,
                                                ).inSeconds,
                                              ),
                                              style: AppTextTokens.display2(
                                                context,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppDimens.p8),
                                        IconButton(
                                          style: IconButton.styleFrom(
                                            minimumSize: const Size.square(
                                              AppDimens.p32,
                                            ),
                                            padding: const EdgeInsets.all(
                                              AppDimens.p4,
                                            ),
                                            backgroundColor: Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                          ),
                                          icon: Icon(
                                            ticking
                                                ? AppIcons.pause
                                                : AppIcons.play,
                                            size: AppDimens.icon20,
                                          ),
                                          tooltip: ticking
                                              ? l.fitnessPause
                                              : l.fitnessResume,
                                          onPressed: () =>
                                              _changeRunning(w, pause: ticking),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppDimens.p12),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(0, AppDimens.p36),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppDimens.p16,
                                      ),
                                      textStyle: AppTextTokens.label(context),
                                    ),
                                    onPressed: () => running
                                        ? _finish(w)
                                        : _changeRunning(w),
                                    child: Text(
                                      running
                                          ? l.fitnessFinish
                                          : w.status == 'completed'
                                          ? l.fitnessRestart
                                          : l.fitnessStart,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_failed)
                              AppLoadError(
                                message: l.fitnessSaveFailed,
                                onRetry: () => _save(_draft!),
                              ),
                            FitnessSessionSummary(
                              exercises: w.exercises,
                              execution: true,
                            ),
                          ],
                        ),
                      ),
                      editor,
                      if (running)
                        const SliverToBoxAdapter(
                          child: SizedBox(
                            height: AppDimens.domainBottomClearance,
                          ),
                        ),
                    ],
                  ),
                  if (running)
                    Positioned(
                      right: AppDimens.p4,
                      bottom: AppDimens.p12,
                      child: Material(
                        color: AppTokens.surface(context),
                        elevation: 4,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _rest,
                          child: Tooltip(
                            message: l.fitnessRest,
                            child: Padding(
                              padding: const EdgeInsets.all(AppDimens.p4),
                              child: FitnessRestCountdown(
                                timer: w.restTimer,
                                now: now,
                                seconds: prefs.value!.defaultRestSeconds,
                                style: FitnessRestCountdownStyle.compact,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
