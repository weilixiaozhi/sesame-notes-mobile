import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/typography.dart';

import 'fitness_exercise_media.dart';
import 'fitness_set_keyboard.dart';

/// 模板与当次训练共用动作卡和组表格，仅训练展示完成操作。
class FitnessExerciseEditor extends StatefulWidget {
  const FitnessExerciseEditor({
    super.key,
    required this.exercises,
    required this.catalog,
    required this.preferences,
    required this.onChanged,
    this.execution = false,
    this.readOnly = false,
    this.onCompleted,
    this.onRest,
    this.onReplaceRequested,
    this.onDeleteRequested,
    this.onWeightModeRequested,
    this.keyboard,
  });
  final List<FitnessExercise> exercises;
  final List<FitnessExerciseDefinition> catalog;
  final FitnessPreferences preferences;
  final ValueChanged<List<FitnessExercise>> onChanged;
  final FitnessKeyboardController? keyboard;
  final bool execution;

  /// 官方内容只读预览：隐藏菜单与新增入口，数值不可编辑。
  final bool readOnly;
  final Future<void> Function(FitnessExercise, FitnessSet, bool)? onCompleted;
  final ValueChanged<FitnessExercise>? onRest;

  /// 将替换意图交给持有最新草稿的父页面。
  final ValueChanged<String>? onReplaceRequested;

  /// 删除确认由父编辑会话核实最新实例后执行。
  final ValueChanged<String>? onDeleteRequested;

  /// 父页面固定编辑会话，并在偏好保存后统一迁移同目录动作。
  final Future<bool> Function(String instanceId, bool enabled)?
  onWeightModeRequested;

  @override
  State<FitnessExerciseEditor> createState() => _FitnessExerciseEditorState();
}

class _FitnessExerciseEditorState extends State<FitnessExerciseEditor> {
  /// 当前展开的动作；同一时间只展开一个，键盘激活的动作优先展开。
  String? _expandedId;

  /// 输入会话固定同动作口径，清空最后一个重量字段时保持焦点与输入框。
  final _editingWeightModes = <String, bool>{};

  /// 模板首次展示首个动作，训练单动作时直接展开，后续沿用用户的展开选择。
  @override
  void initState() {
    super.initState();
    _expandedId =
        widget.exercises.isNotEmpty &&
            (!widget.execution || widget.exercises.length == 1)
        ? widget.exercises.first.id
        : null;
    widget.keyboard?.addListener(_keyboardChanged);
  }

  @override
  void didUpdateWidget(FitnessExerciseEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keyboard != widget.keyboard) {
      oldWidget.keyboard?.removeListener(_keyboardChanged);
      widget.keyboard?.addListener(_keyboardChanged);
    }
    // 空列表添加首个动作时默认展开，与单动作页面保持一致。
    if (oldWidget.exercises.isEmpty && widget.exercises.isNotEmpty) {
      _expandedId = widget.exercises.first.id;
    }
  }

  @override
  void dispose() {
    widget.keyboard?.removeListener(_keyboardChanged);
    super.dispose();
  }

  /// 键盘在某动作上激活时展开该动作；键盘关闭后保持展开，编辑位置不跳动。
  void _keyboardChanged() {
    final id = widget.keyboard?.exerciseId;
    if (id == null || id == _expandedId || !mounted) return;
    setState(() => _expandedId = id);
  }

  /// 点击动作标题展开或收起；展开另一个动作时上一个自动收起。
  void _toggle(String id) =>
      setState(() => _expandedId = _expandedId == id ? null : id);

  void _update(int index, FitnessExercise exercise) {
    final next = [...widget.exercises];
    next[index] = exercise;
    widget.onChanged(next);
  }

  /// 更新组输入并复核完成条件，无效成绩退回未完成状态。
  void _set(BuildContext context, int index, int setIndex, FitnessSet value) {
    final exercise = widget.exercises[index];
    _editingWeightModes[exercise.exerciseId] = _sideWeight(exercise);
    if (value.completed && !fitnessSetIsValid(value)) {
      value = value.copyWith(completed: false);
      showToast(context, AppLocalizations.of(context).fitnessIncompleteSet);
    }
    final next = [...exercise.sets];
    next[setIndex] = value;
    _update(index, exercise.copyWith(sets: next));
  }

  /// 菜单关闭后按实例身份重新定位，动作被重排或删除也不会操作到相邻项。
  void _exerciseAction(String instanceId, String action) {
    final index = widget.exercises.indexWhere((item) => item.id == instanceId);
    if (index < 0) return;
    final e = widget.exercises[index];
    switch (action) {
      case 'replace':
        widget.onReplaceRequested?.call(instanceId);
      case 'delete':
        widget.onDeleteRequested?.call(instanceId);
      case 'rest':
        widget.onRest?.call(e);
      case 'up':
      case 'down':
        final destination = action == 'up' ? index - 1 : index + 1;
        if (destination < 0 || destination >= widget.exercises.length) return;
        final next = [...widget.exercises];
        next.removeAt(index);
        next.insert(destination, e);
        widget.onChanged(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (widget.exercises.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppEmpty(
              key: const ValueKey('fitness-exercises-empty'),
              icon: AppIcons.fitness,
              text: l.fitnessDetailEmptyExercises,
            ),
          ],
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverReorderableList(
          itemCount: widget.exercises.length,
          itemBuilder: _card,
          findChildIndexCallback: (key) {
            final index = widget.exercises.indexWhere(
              (e) => ValueKey(e.id) == key,
            );
            return index < 0 ? null : index;
          },
          onReorderItem: (from, to) =>
              widget.onChanged(fitnessReorderItems(widget.exercises, from, to)),
          proxyDecorator: (child, _, _) => child,
        ),
      ],
    );
  }

  Widget _card(BuildContext context, int index) {
    final l = AppLocalizations.of(context);
    final e = widget.exercises[index];
    final def = widget.catalog.where((d) => d.id == e.exerciseId).firstOrNull;
    final sideWeight = _sideWeight(e);
    final name = def == null ? e.exerciseId : fitnessExerciseName(context, def);
    return SectionCard(
      key: ValueKey(e.id),
      margin: const EdgeInsets.only(bottom: AppDimens.p8),
      showShadow: false,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.p12,
        vertical: AppDimens.p8,
      ),
      child: _ExerciseExpansion(
        expanded: _expandedId == e.id,
        onToggle: () => _toggle(e.id),
        leading: InkWell(
          onTap: () => context.pushNamed(
            Routes.fitnessExerciseDetail,
            extra: e.exerciseId,
          ),
          child: Tooltip(
            message: l.fitnessExerciseDetail,
            child: def == null
                ? const Icon(AppIcons.fitness)
                : SizedBox(
                    width: AppDimens.exerciseThumbnailSize,
                    height: AppDimens.actionButtonMinHeight,
                    child: FitnessExerciseMedia(definition: def),
                  ),
          ),
        ),
        title: ReorderableDelayedDragStartListener(
          index: index,
          enabled: !widget.readOnly && widget.exercises.length > 1,
          child: Tooltip(
            triggerMode: TooltipTriggerMode.manual,
            message: l.fitnessReorderHint,
            child: Text(
              name,
              key: ValueKey('fitness-drag-${e.id}'),
              style: AppTextTokens.strongTitle(context),
            ),
          ),
        ),
        menu: widget.readOnly
            ? null
            : AppPopupMenu(
                tooltip: l.fitnessDetails,
                items: [
                  if (widget.onReplaceRequested != null)
                    AppMenuItem.action(
                      value: 'replace',
                      label: l.fitnessReplace,
                    ),
                  if (widget.onRest != null)
                    AppMenuItem.action(
                      value: 'rest',
                      label: l.fitnessRestSeconds,
                    ),
                  if (index > 0)
                    AppMenuItem.action(value: 'up', label: l.fitnessMoveUp),
                  if (index < widget.exercises.length - 1)
                    AppMenuItem.action(value: 'down', label: l.fitnessMoveDown),
                  if (widget.onDeleteRequested != null)
                    AppMenuItem.action(
                      value: 'delete',
                      label: l.commonDelete,
                      isDanger: true,
                    ),
                ],
                onSelected: (action) => _exerciseAction(e.id, action),
              ),
        subtitle: Row(
          children: [
            Flexible(
              child: Wrap(
                spacing: AppDimens.p4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l.fitnessSetCount(e.sets.length),
                    style: AppTextTokens.label(context),
                  ),
                  for (final set in e.sets)
                    Container(
                      width: AppDimens.p8,
                      height: AppDimens.p8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.execution && set.completed
                            ? AppTokens.primary(context)
                            : AppTokens.textTertiary(context),
                      ),
                    ),
                ],
              ),
            ),
            // 口径切换跟组数同一行，不额外占用卡片高度。
            if (widget.onWeightModeRequested != null && !widget.readOnly)
              _weightModeLink(context, e, sideWeight),
          ],
        ),
        children: [
          for (var i = 0; i < e.sets.length; i++)
            _setFields(context, index, i, sideWeight),
          // 只读预览不提供新增组入口。
          if (!widget.readOnly) ...[
            const SizedBox(height: AppDimens.p8),
            SizedBox(
              width: double.infinity,
              child: CustomPaint(
                foregroundPainter: _AddSetBorder(
                  color: AppTokens.primary(context),
                  radius: AppTokens.buttonRadius(context),
                ),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, AppDimens.p36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(AppIcons.add),
                  label: Text(l.fitnessAddSet),
                  onPressed: () => _update(
                    index,
                    e.copyWith(
                      sets: [
                        ...e.sets,
                        e.sets.isEmpty
                            ? FitnessSet(id: const Uuid().v4())
                            : fitnessCopySet(e.sets.last),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 键盘一键改：按方向把当前字段写入同类型组的向上或向下范围，
  /// 记录左右时同一行的左右两侧一起写入，不需要再逐侧改一遍。
  void _keyboardAction(
    int index,
    int setIndex,
    String field,
    String value,
    String action,
  ) {
    final e = widget.exercises[index];
    _update(
      index,
      e.copyWith(
        sets: fitnessFillSets(
          e,
          setIndex: setIndex,
          field: field,
          value: value,
          action: action,
        ),
      ),
    );
  }

  /// 同动作成绩优先；全空时沿用本次编辑口径，再取空间偏好和器械默认值。
  bool _sideWeight(FitnessExercise exercise) => fitnessUsesSideWeight(
    widget.preferences,
    exerciseId: exercise.exerciseId,
    equipment: widget.catalog
        .where((d) => d.id == exercise.exerciseId)
        .firstOrNull
        ?.equipment,
    dataUsesSideWeight:
        fitnessSideWeightFromSets(
          widget.exercises
              .where((item) => item.exerciseId == exercise.exerciseId)
              .expand((item) => item.sets),
        ) ??
        _editingWeightModes[exercise.exerciseId],
  );

  /// 成功回执才更新当前输入口径，失败时保持原草稿和字段布局。
  Future<void> _requestWeightMode(FitnessExercise exercise, bool side) async {
    try {
      final changed = await widget.onWeightModeRequested?.call(
        exercise.id,
        side,
      );
      if (mounted && changed == true) {
        setState(() => _editingWeightModes[exercise.exerciseId] = side);
      }
    } catch (error, stackTrace) {
      logger.error('FitnessExerciseEditor', '切换动作重量口径失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).fitnessSaveFailed);
      }
    }
  }

  /// 重量口径决定首个重量字段：总重一个框，左右重量先左后右。
  String _weightField(FitnessExercise exercise) =>
      _sideWeight(exercise) ? 'weight_left' : 'weight';

  void _nextInput(int index, int setIndex, String field) {
    final e = widget.exercises[index];
    switch (field) {
      case 'weight' || 'weight_right':
        widget.keyboard!.focusNext('${e.id}:${e.sets[setIndex].id}:reps', e.id);
        return;
      case 'weight_left':
        widget.keyboard!.focusNext(
          '${e.id}:${e.sets[setIndex].id}:weight_right',
          e.id,
        );
        return;
    }
    if (setIndex + 1 < e.sets.length) {
      final nextSet = e.sets[setIndex + 1];
      widget.keyboard!.focusNext(
        '${e.id}:${nextSet.id}:${_weightField(e)}',
        e.id,
      );
      return;
    }
    for (final next in widget.exercises.skip(index + 1)) {
      if (next.sets.isNotEmpty) {
        widget.keyboard!.focusNext(
          '${next.id}:${next.sets.first.id}:${_weightField(next)}',
          next.id,
        );
        return;
      }
    }
    widget.keyboard!.close();
  }

  /// 写入单个重量字段：同一组只保留一种重量口径，切换口径时清除另一种。
  void _setWeight(
    BuildContext context,
    int index,
    int setIndex,
    String field,
    String raw,
  ) {
    final set = widget.exercises[index].sets[setIndex];
    final value = fitnessValidWeight(raw) ? raw : null;
    _set(context, index, setIndex, switch (field) {
      'weight_left' => set.copyWith(weightLeft: value, weight: null),
      'weight_right' => set.copyWith(weightRight: value, weight: null),
      _ => set.copyWith(weight: value, weightLeft: null, weightRight: null),
    });
  }

  /// 重量口径文字链：直接显示当前口径，点一下切到另一种。
  Widget _weightModeLink(
    BuildContext context,
    FitnessExercise exercise,
    bool sideWeight,
  ) {
    final l = AppLocalizations.of(context);
    return TextButton(
      key: ValueKey('${exercise.id}:side-weight'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.p4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: AppTextTokens.label(
          context,
        ).copyWith(fontWeight: FontWeight.w600),
      ),
      onPressed: () => _requestWeightMode(exercise, !sideWeight),
      child: Text(sideWeight ? l.fitnessSideWeight : l.fitnessTotalWeight),
    );
  }

  Widget _setFields(
    BuildContext context,
    int index,
    int setIndex,
    bool sideWeight,
  ) {
    final e = widget.exercises[index], s = e.sets[setIndex];
    final l = AppLocalizations.of(context);
    final completed = widget.execution && s.completed;
    final fieldHeight = MediaQuery.textScalerOf(context).scale(AppDimens.p36);
    Widget input(
      String field,
      String label,
      String value,
      ValueChanged<String> onChanged, {
      bool decimal = false,
    }) => DecoratedBox(
      decoration: BoxDecoration(
        color: completed
            ? AppTokens.primary(context)
            : AppTokens.surfaceInput(context),
        borderRadius: BorderRadius.circular(AppTokens.inputRadius(context)),
        border: widget.keyboard?.activeId == '${e.id}:${s.id}:$field'
            ? Border.all(
                color: completed
                    ? AppTokens.textPrimary(context)
                    : AppTokens.primary(context),
                width: AppDimens.selectionIndicatorWidth,
              )
            : null,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: fieldHeight),
        child: FitnessNumericInput(
          key: ValueKey('${s.id}:$field:kg'),
          keyboard: widget.keyboard,
          readOnly: widget.readOnly,
          inputId: '${e.id}:${s.id}:$field',
          exerciseId: e.id,
          onAddSet: (value) =>
              _keyboardAction(index, setIndex, field, value, 'add'),
          onFillAbove: (value) =>
              _keyboardAction(index, setIndex, field, value, 'above'),
          onFillBelow: (value) =>
              _keyboardAction(index, setIndex, field, value, 'below'),
          onNext: () => _nextInput(index, setIndex, field),
          label: label,
          value: value,
          onChanged: onChanged,
          decimal: decimal,
          compact: true,
          completed: completed,
        ),
      ),
    );
    final ordinal = e.sets
        .take(setIndex + 1)
        .where((set) => set.kind == 'working')
        .length;
    // 记录左右的动作给出左右两个重量框，其余动作只有一个总重框。
    final weightFields = sideWeight
        ? <Widget>[
            input(
              'weight_left',
              l.fitnessLeftKg,
              s.weightLeft ?? '',
              (raw) => _setWeight(context, index, setIndex, 'weight_left', raw),
              decimal: true,
            ),
            input(
              'weight_right',
              l.fitnessRightKg,
              s.weightRight ?? '',
              (raw) =>
                  _setWeight(context, index, setIndex, 'weight_right', raw),
              decimal: true,
            ),
          ]
        : <Widget>[
            input(
              'weight',
              'kg',
              s.weight ?? '',
              (raw) => _setWeight(context, index, setIndex, 'weight', raw),
              decimal: true,
            ),
          ];
    final fields = <Widget>[
      TextButton(
        key: ValueKey('${s.id}:kind'),
        style: TextButton.styleFrom(
          minimumSize: Size(0, fieldHeight),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: AppTextTokens.strongTitle(context),
          // 只读预览与全局禁用态保持一致。
          disabledForegroundColor: AppTokens.textDisabled(context),
        ),
        onPressed: widget.readOnly
            ? null
            : () {
                _update(
                  index,
                  e.copyWith(
                    sets: fitnessEditSets(e.sets, setIndex, 'toggleKind'),
                  ),
                );
                // 切组类型会把该组移到热身/正式组的交界处，键盘选中的行已经不是同一组，
                // 继续留在键盘上会把后续输入写进错误的位置。
                widget.keyboard?.close();
              },
        child: Text(s.kind == 'warmup' ? l.fitnessWarmupLabel : '$ordinal'),
      ),
      for (final field in weightFields) field,
      input(
        'reps',
        l.fitnessRepUnit,
        '${s.reps ?? ''}',
        (raw) => _set(
          context,
          index,
          setIndex,
          s.copyWith(reps: fitnessPositiveInt(raw)),
        ),
      ),
      if (widget.execution)
        Semantics(
          container: true,
          checked: completed,
          label: '${l.commonConfirm} ${setIndex + 1}',
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: completed
                  ? AppTokens.primary(context)
                  : AppTokens.surfaceInput(context),
              borderRadius: BorderRadius.circular(
                AppTokens.buttonRadius(context),
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.center,
              constraints: BoxConstraints.tightFor(height: fieldHeight),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                AppIcons.check,
                color: completed
                    ? AppTokens.textOnPrimary(context)
                    : AppTokens.textTertiary(context),
              ),
              onPressed: widget.onCompleted == null
                  ? null
                  : () async {
                      if (!s.completed && !fitnessSetIsValid(s)) {
                        showToast(context, l.fitnessInvalidSet);
                        return;
                      }
                      await widget.onCompleted!(e, s, !s.completed);
                    },
            ),
          ),
        ),
    ];
    final kindWidth = MediaQuery.textScalerOf(context).scale(AppDimens.p36);
    return Padding(
      key: ValueKey(s.id),
      padding: const EdgeInsets.only(bottom: AppDimens.p8),
      child: Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 单边口径的格子数最多，按它等分出固定格子宽度：
                // 切到总重量时每个格子尺寸不变，只是整体少一格并保持左对齐。
                final cellWidth =
                    (constraints.maxWidth -
                        kindWidth -
                        _fieldGap * _fieldSlots) /
                    _fieldSlots;
                return Row(
                  children: [
                    SizedBox(width: kindWidth, child: fields.first),
                    for (final field in fields.skip(1)) ...[
                      const SizedBox(width: _fieldGap),
                      SizedBox(width: cellWidth, child: field),
                    ],
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: AppDimens.p8),
          if (!widget.readOnly)
            AppPopupMenu(
              key: ValueKey('${s.id}:menu'),
              tooltip: l.fitnessEdit,
              items: [
                AppMenuItem.action(value: 'copy', label: l.fitnessCopySet),
                AppMenuItem.action(
                  value: 'delete',
                  label: l.fitnessDeleteSet,
                  isDanger: true,
                ),
              ],
              onSelected: (action) {
                if (action == 'copy' || action == 'delete') {
                  _update(
                    index,
                    e.copyWith(sets: fitnessEditSets(e.sets, setIndex, action)),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}

/// 动作展开区：内容固定在标题下方展开，收起时从底部向上收拢，
/// 收起动画结束才移出内容，避免内容先消失再由列表腾出空间。
class _ExerciseExpansion extends StatefulWidget {
  const _ExerciseExpansion({
    required this.expanded,
    required this.onToggle,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.menu,
    required this.children,
  });
  final bool expanded;
  final VoidCallback onToggle;
  final Widget leading, title, subtitle;

  /// 动作管理菜单；只读预览不提供。
  final Widget? menu;
  final List<Widget> children;
  @override
  State<_ExerciseExpansion> createState() => _ExerciseExpansionState();
}

class _ExerciseExpansionState extends State<_ExerciseExpansion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: widget.expanded ? 1 : 0,
  );
  late final CurvedAnimation _size = CurvedAnimation(
    parent: _animation,
    curve: Curves.easeOutCubic,
  );

  /// 收起动画播放期间内容保留在树上，由 SizeTransition 按高度裁剪。
  late bool _content = widget.expanded;

  @override
  void initState() {
    super.initState();
    // 收起结束（含直接以收起状态挂载）后移除内容，输入框随之注销。
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted && _content) {
        setState(() => _content = false);
      }
    });
  }

  @override
  void didUpdateWidget(_ExerciseExpansion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expanded == oldWidget.expanded) return;
    if (widget.expanded) {
      setState(() => _content = true);
      _animation.forward();
    } else {
      _animation.reverse();
    }
  }

  @override
  void dispose() {
    _size.dispose();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          widget.leading,
          const SizedBox(width: AppDimens.p20),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onToggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDimens.p8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.title,
                      const SizedBox(height: AppDimens.p4),
                      widget.subtitle,
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (widget.menu != null) widget.menu!,
        ],
      ),
      SizeTransition(
        sizeFactor: _size,
        // 内容与标题顶部对齐，展开向下生长、收起向下回缩。
        alignment: Alignment.topCenter,
        child: _content
            ? Padding(
                padding: const EdgeInsets.only(top: AppDimens.p8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.children,
                ),
              )
            : const SizedBox(width: double.infinity),
      ),
    ],
  );
}

/// 组行内各字段之间的固定间距。
const _fieldGap = AppDimens.p16;

/// 单边口径一行的字段格子数（左kg、右kg、次数、勾选），作为格子宽度基准。
const _fieldSlots = 4;

/// 焦点内保留用户原始输入（包括未输完的小数），单位显示变化不回写原精度。
class FitnessNumericInput extends StatefulWidget {
  const FitnessNumericInput({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.decimal = false,
    this.compact = false,
    this.completed = false,
    this.errorText,
    this.keyboard,
    this.readOnly = false,
    this.inputId,
    this.exerciseId,
    this.onAddSet,
    this.onFillAbove,
    this.onFillBelow,
    this.onNext,
  });
  final FitnessKeyboardController? keyboard;
  final String? inputId, exerciseId;
  final ValueChanged<String>? onAddSet, onFillAbove, onFillBelow;
  final VoidCallback? onNext;
  final String label, value;
  final String? errorText;
  final bool decimal, compact, completed;

  /// 只读预览：不注册键盘，也不接受输入。
  final bool readOnly;
  final ValueChanged<String> onChanged;
  @override
  State<FitnessNumericInput> createState() => _FitnessNumericInputState();
}

class _FitnessNumericInputState extends State<FitnessNumericInput> {
  late final _controller = TextEditingController(text: widget.value);
  final _focus = FocusNode();
  // 数值框不共享动作展开状态的 PageStorage，避免滚动偏移读取到布尔值。
  final _scroll = ScrollController(keepScrollOffset: false);
  FitnessKeyboardTarget? _target;
  void _register() {
    if (widget.keyboard == null || widget.readOnly) return;
    _target = FitnessKeyboardTarget(
      id: widget.inputId!,
      exerciseId: widget.exerciseId!,
      text: _controller,
      focus: _focus,
      context: context,
      decimal: widget.decimal,
      onChanged: (raw) => widget.onChanged(raw),
      onAddSet: (raw) => widget.onAddSet!(raw),
      onFillAbove: (raw) => widget.onFillAbove!(raw),
      onFillBelow: (raw) => widget.onFillBelow!(raw),
      onNext: () => widget.onNext!(),
    );
    widget.keyboard!.register(_target!);
  }

  void _focusChanged() {
    if (_target == null) return;
    if (_focus.hasFocus) {
      widget.keyboard!.activate(_target!);
    } else {
      widget.keyboard!.release(_target!);
    }
  }

  @override
  void initState() {
    super.initState();
    _register();
    _focus.addListener(_focusChanged);
  }

  @override
  void didUpdateWidget(FitnessNumericInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.keyboard != widget.keyboard) {
      if (_target != null) oldWidget.keyboard?.unregister(_target!);
      _target = null;
      _register();
    }
    if (!_focus.hasFocus && widget.value != oldWidget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_focusChanged);
    if (_target != null) widget.keyboard?.unregister(_target!);
    _controller.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// 点击单位或数值均聚焦当前字段，并让训练键盘显示对应输入内容。
  void _activateInput() {
    if (widget.readOnly) return;
    _focus.requestFocus();
    if (_target != null) widget.keyboard!.activate(_target!);
  }

  /// 单位与数值按实际文字高度纵向排版，字体缩放时仍保留独立间距。
  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: _controller,
      focusNode: _focus,
      scrollController: _scroll,
      textAlign: widget.compact ? TextAlign.center : TextAlign.start,
      style: widget.compact
          ? AppTextTokens.title(context).copyWith(
              color: widget.completed
                  ? AppTokens.textOnPrimary(context)
                  : widget.readOnly
                  ? AppTokens.textDisabled(context)
                  : AppTokens.textPrimary(context),
            )
          : null,
      readOnly: widget.readOnly,
      keyboardType: widget.keyboard != null || widget.readOnly
          ? TextInputType.none
          : TextInputType.numberWithOptions(decimal: widget.decimal),
      onTap: _activateInput,
      decoration: InputDecoration(
        isDense: true,
        labelText: widget.compact ? null : widget.label,
        labelStyle: AppTextTokens.label(context).copyWith(
          color: widget.completed
              ? AppTokens.textOnPrimary(context)
              : AppTokens.textSecondary(context),
        ),
        filled: widget.compact ? false : null,
        border: widget.compact ? InputBorder.none : null,
        enabledBorder: widget.compact ? InputBorder.none : null,
        focusedBorder: widget.compact ? InputBorder.none : null,
        contentPadding: widget.compact
            ? const EdgeInsets.fromLTRB(
                AppDimens.p8,
                AppDimens.p4,
                AppDimens.p8,
                AppDimens.p4,
              )
            : null,
        hintText: '—',
        errorText: widget.errorText,
        errorMaxLines: 5,
      ),
      onChanged: (raw) => widget.onChanged(
        widget.keyboard == null ? raw : FitnessKeyboardController.value(raw),
      ),
      validator: (value) {
        if (widget.errorText != null) return widget.errorText;
        if (value == null || value.isEmpty) return null;
        return (widget.decimal
                ? fitnessValidWeight(value)
                : fitnessPositiveInt(value) != null)
            ? null
            : AppLocalizations.of(context).fitnessInvalidSet;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
    return Semantics(
      label: widget.label,
      textField: true,
      child: widget.compact
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.readOnly ? null : _activateInput,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 标签参与正常布局，数值输入框的顶部留白提供两行之间的间距。
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.p8,
                      AppDimens.p4,
                      AppDimens.p8,
                      0,
                    ),
                    child: Text(
                      widget.label,
                      style: AppTextTokens.caption(context).copyWith(
                        color: widget.completed
                            ? AppTokens.textOnPrimary(context)
                            : AppTokens.textTertiary(context),
                      ),
                    ),
                  ),
                  field,
                ],
              ),
            )
          : field,
    );
  }
}

class _AddSetBorder extends CustomPainter {
  const _AddSetBorder({required this.color, required this.radius});
  final Color color;
  final double radius;

  /// 虚线沿主题按钮轮廓绘制，按键自身继续负责焦点和点击。
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = const BorderSide().width;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(stroke),
          Radius.circular(radius),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    for (final metric in path.computeMetrics()) {
      for (var offset = 0.0; offset < metric.length; offset += AppDimens.p8) {
        canvas.drawPath(
          metric.extractPath(offset, offset + AppDimens.p4),
          paint,
        );
      }
    }
  }

  /// 主题切换改变颜色或圆角时更新虚线轮廓。
  @override
  bool shouldRepaint(_AddSetBorder oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}
