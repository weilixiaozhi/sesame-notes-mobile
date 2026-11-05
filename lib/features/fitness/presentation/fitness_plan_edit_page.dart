import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/logging/logger_service.dart';
import '../../../data/models/fitness.dart';
import '../../../data/models/fitness_library.dart';
import '../../../data/models/private_book.dart';
import '../../../domain/analytics/product_analytics_actions.dart';
import '../../../domain/fitness/fitness_rules.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/route_consts.dart';
import '../../../providers/product_analytics_providers.dart';
import '../../../shared/widgets/app_form_section.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../theme/colors.dart';
import '../../../theme/dimens.dart';
import '../../../theme/icons/app_icons.dart';
import '../../../theme/typography.dart';
import '../../../utils/text_validation.dart';
import '../application/fitness_actions.dart';
import '../application/fitness_providers.dart';
import 'widgets/fitness_plan_day_sheet.dart';
import 'widgets/fitness_plan_widgets.dart';
import 'widgets/fitness_widgets.dart';

/// 新建、调整官方计划和编辑已有计划共用三个明确的表单步骤。
class FitnessPlanEditPage extends ConsumerStatefulWidget {
  /// 官方计划从周期编排开始，自建计划从基本设置开始。
  const FitnessPlanEditPage({
    super.key,
    this.plan,
    this.importDraft,
    this.owner,
  }) : assert(plan == null || importDraft == null);

  final FitnessPlan? plan;
  final FitnessPlanImportDraft? importDraft;
  final PrivateBookTarget? owner;

  /// 每次进入均创建临时状态，只有确认提交才持久化。
  @override
  ConsumerState<FitnessPlanEditPage> createState() =>
      _FitnessPlanEditPageState();
}

class _FitnessPlanEditPageState extends ConsumerState<FitnessPlanEditPage> {
  late FitnessPlan _draft;
  late final TextEditingController _name;
  late final Set<int> _filled;
  final Map<String, FitnessTemplate> _officialTemplates = {};
  PrivateBookTarget? _owner;
  FitnessPlan? _created;
  int _step = 0;
  int? _focusDay;
  int _focusRequest = 0;
  String? _error;
  String? _restartDate;
  bool _busy = false;
  bool _exiting = false;
  bool _allowPop = false;

  /// 已生成周期的运行计划由仓储锁定开始日期。
  bool get _dateLocked =>
      widget.plan?.status == 'in_progress' &&
      widget.plan?.generationState.nextCycleStartDate != null;

  /// 新建与编辑沿用各自的退出提示和保存语义。
  bool get _editing => widget.plan != null;

  /// 所有空白日期都使用当天，已有待生效安排作为本次编辑内容。
  @override
  void initState() {
    super.initState();
    _draft =
        widget.importDraft?.plan ??
        widget.plan ??
        FitnessPlan(
          name: '',
          status: 'in_progress',
          startDate: fitnessDate(DateTime.now()),
          cycleDays: 7,
          days: List.generate(7, (i) => FitnessPlanDay(dayIndex: i)),
        );
    if (_draft.pendingSchedule case final pending?) {
      _draft = _draft.copyWith(
        cycleDays: pending.cycleDays,
        days: pending.days,
      );
    }
    _draft = _draft.copyWith(
      startDate: _draft.startDate ?? fitnessDate(DateTime.now()),
      days: [..._draft.days]..sort((a, b) => a.dayIndex.compareTo(b.dayIndex)),
    );
    _filled = widget.plan == null && widget.importDraft == null
        ? <int>{}
        : {for (final day in _draft.days) day.dayIndex};
    _name = TextEditingController(text: _draft.name);
    _officialTemplates.addAll(widget.importDraft?.officialTemplates ?? {});
    _owner = widget.owner ?? widget.importDraft?.target;
    _step = widget.plan != null || widget.importDraft != null ? 1 : 0;
  }

  /// 输入控制器随页面释放，不留下未提交状态。
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// 处理标题关闭和系统返回，两者均明确告知未保存内容会丢失。
  Future<void> _requestExit() async {
    if (_busy || _exiting) return;
    if (_created != null) {
      _finish();
      return;
    }
    _exiting = true;
    try {
      final l = AppLocalizations.of(context);
      final exit = await AppDialog.confirm(
        context,
        balancedActions: true,
        title: _editing ? l.fitnessPlanExitEditTitle : l.fitnessPlanExitTitle,
        message: l.fitnessPlanExitMessage,
        cancelLabel: l.fitnessPlanContinueEditing,
        okLabel: l.fitnessPlanExitDiscard,
      );
      if (exit == true && mounted) {
        setState(() => _allowPop = true);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } catch (error, stackTrace) {
      logger.error('FitnessPlanEditor', '退出计划编辑失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    } finally {
      _exiting = false;
    }
  }

  /// 只写入被点击的当天；选中模板后保持当前滚动位置。
  Future<void> _pickDay(int index) async {
    if (_busy) return;
    try {
      final choice = await showAppSheet<FitnessPlanDaySelection>(
        context: context,
        child: FitnessPlanDaySheet(
          dayIndex: index,
          filled: _filled.contains(index),
          currentSlot: _draft.days[index].slot,
        ),
      );
      if (choice == null || !mounted) return;
      final target = ref.read(fitnessActionsProvider).target;
      if (_owner != null && !matchesPrivateBookTarget(_owner!, target)) {
        throw StateError('FITNESS_TARGET_CHANGED');
      }
      setState(() {
        _error = null;
        final days = [..._draft.days];
        if (choice.kind == FitnessPlanDaySelectionKind.clear) {
          _filled.remove(index);
          days[index] = FitnessPlanDay(dayIndex: index);
        } else {
          _filled.add(index);
          final template = choice.template;
          if (choice.official && template != null) {
            _officialTemplates[template.id] = template;
          }
          days[index] = FitnessPlanDay(
            dayIndex: index,
            slot: template == null
                ? null
                : FitnessPlanSlot(
                    id: const Uuid().v4(),
                    sourceTemplateId: template.id,
                    name: template.name,
                    exercises: fitnessSnapshotExercises(template.exercises),
                  ),
          );
        }
        _draft = _draft.copyWith(days: days);
      });
    } catch (error, stackTrace) {
      logger.error('FitnessPlanEditor', '安排当天训练失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).fitnessLoadFailed);
      }
    }
  }

  /// 扩展周期只新增未安排天数，缩短前先说明已有内容的影响。
  Future<void> _resize(int count) async {
    if (_busy || count == _draft.cycleDays) return;
    try {
      if (count < 1 || count > FitnessDefaults.maxCycleDays) return;
      final lost = _filled.where((day) => day >= count).length;
      if (lost > 0) {
        final l = AppLocalizations.of(context);
        final confirmed = await AppDialog.confirm(
          context,
          balancedActions: true,
          title: l.fitnessPlanShrinkTitle(count),
          message: l.fitnessPlanShrinkMessage(
            count + 1,
            _draft.cycleDays,
            lost,
            count,
          ),
        );
        if (confirmed != true || !mounted) return;
      }
      setState(() {
        _draft = _draft.copyWith(
          cycleDays: count,
          days: List.generate(
            count,
            (i) => i < _draft.days.length
                ? _draft.days[i]
                : FitnessPlanDay(dayIndex: i),
          ),
        );
        _filled.removeWhere((day) => day >= count);
        _focusDay = null;
        _error = null;
      });
    } catch (error, stackTrace) {
      logger.error('FitnessPlanEditor', '修改计划周期失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 自定义天数使用现有数字输入与领域容量校验。
  Future<void> _customCycle() async {
    try {
      final value = await fitnessInput(
        context,
        title: AppLocalizations.of(context).fitnessPlanCycleLabel,
        initial: '${_draft.cycleDays}',
        numeric: true,
        minValue: 1,
        maxValue: FitnessDefaults.maxCycleDays,
      );
      if (value != null && mounted) await _resize(int.parse(value));
    } catch (error, stackTrace) {
      logger.error('FitnessPlanEditor', '读取自定义周期失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 只有用户明确确认后，才把未安排天数批量设置为休息。
  Future<void> _restRemaining() async {
    try {
      final count = _draft.cycleDays - _filled.length;
      if (count == 0) return;
      final l = AppLocalizations.of(context);
      if (await AppDialog.confirm(
                context,
                balancedActions: true,
                title: l.fitnessPlanRestConfirmTitle,
                message: l.fitnessPlanRestConfirmMessage(count),
              ) !=
              true ||
          !mounted) {
        return;
      }
      setState(() {
        _filled.addAll(Iterable.generate(_draft.cycleDays));
        _error = null;
      });
    } catch (error, stackTrace) {
      logger.error('FitnessPlanEditor', '批量安排休息失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 开始日期与已生成周期的锁定、关闭后重新启用规则一致。
  Future<bool> _pickStart() async {
    try {
      if (_dateLocked) return false;
      final today = DateUtils.dateOnly(DateTime.now());
      final stored = DateTime.tryParse(_draft.startDate ?? '') ?? today;
      final date = await showWheelDatePicker(
        context,
        initial: stored.isBefore(today) ? today : stored,
        minDate: today,
        title: AppLocalizations.of(context).fitnessStartDate,
      );
      if (date == null || !mounted) return false;
      setState(() {
        final start = fitnessDate(date);
        _draft = _draft.copyWith(startDate: start);
        if (widget.plan?.status == 'closed' &&
            widget.plan?.generationState.nextCycleStartDate != null) {
          _restartDate = start;
        }
        _error = null;
      });
      return true;
    } catch (error, stackTrace) {
      logger.error('FitnessPlanEditor', '选择计划开始日期失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
      return false;
    }
  }

  /// 重新启用已结束的生成计划时，先确认新的开始日期。
  Future<void> _setEnabled(bool enabled) async {
    if (_busy) return;
    final start = _draft.startDate;
    final pastStart =
        start != null && start.compareTo(fitnessDate(DateTime.now())) < 0;
    final needsRestart =
        widget.plan?.generationState.nextCycleStartDate != null &&
        _restartDate == null;
    if (enabled &&
        widget.plan?.status == 'closed' &&
        (pastStart || needsRestart) &&
        !await _pickStart()) {
      return;
    }
    if (mounted) {
      setState(
        () => _draft = _draft.copyWith(
          status: enabled ? 'in_progress' : 'closed',
        ),
      );
    }
  }

  /// 对名称、未安排日和全休息分别提示，并定位到对应步骤。
  bool _validate(int step) {
    final l = AppLocalizations.of(context);
    if (!fitnessValidName(normalizeName(_name.text))) {
      setState(() {
        _error = l.fitnessPlanNameInvalid;
        _step = 0;
      });
      return false;
    }
    if (step > 0) {
      final unfilled = fitnessPlanUnfilledDay(_draft.cycleDays, _filled);
      if (unfilled != null) {
        setState(() {
          _error = l.fitnessPlanUnassigned(_draft.cycleDays - _filled.length);
          _step = 1;
          _focusDay = unfilled;
          _focusRequest++;
        });
        return false;
      }
      if (!_draft.days.any((day) => day.slot != null)) {
        setState(() {
          _error = l.fitnessPlanNeedTraining;
          _step = 1;
        });
        return false;
      }
    }
    return true;
  }

  /// 步骤回退仅改变当前表单阶段，不保存或复制数据。
  void _previous() {
    if (_busy || _step == 0) return;
    setState(() {
      _step--;
      _error = null;
    });
  }

  /// 只有第三步的确认操作会写入计划。
  Future<void> _next() async {
    if (_busy || !_validate(_step)) return;
    if (_step == 2) {
      await _save();
      return;
    }
    setState(() {
      _draft = _draft.copyWith(name: normalizeName(_name.text));
      _step++;
      _error = null;
    });
  }

  /// 原子保存当前安排，库模板只按实际引用物化，提交后不再要求选版本。
  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final actions = ref.read(fitnessActionsProvider);
      if (_owner != null &&
          !matchesPrivateBookTarget(_owner!, actions.target)) {
        throw StateError('FITNESS_TARGET_CHANGED');
      }
      final analytics = ref.read(productAnalyticsControllerProvider);
      final flow = analytics.beginFlow();
      final fromLibrary = widget.importDraft != null;
      final pageId = fromLibrary
          ? 'fitness.plans.library.detail'
          : 'fitness.plans.edit';
      analytics.trackAction(
        pageId: pageId,
        action: fromLibrary
            ? ProductAction.fitnessPlanAddClick
            : ProductAction.fitnessPlanSaveClick,
        context: flow,
      );
      final complete = analytics.captureCompletion(
        pageId: pageId,
        context: flow,
      );
      final result = await actions.savePlan(
        _draft.copyWith(name: normalizeName(_name.text)),
        officialTemplates: _officialTemplates,
        restartDate: _draft.status == 'in_progress' ? _restartDate : null,
      );
      complete(
        fromLibrary
            ? ProductAction.fitnessPlanAdded
            : ProductAction.fitnessPlanSaved,
      );
      if (!mounted) return;
      if (_editing) {
        setState(() {
          _allowPop = true;
          _busy = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) Navigator.of(context).pop(true);
        });
      } else {
        setState(() {
          _created = result;
          _busy = false;
          _error = null;
        });
      }
    } catch (error, stackTrace) {
      logger.error('FitnessPlanEditor', '保存计划及所选模板失败', error, stackTrace);
      if (mounted) {
        setState(() {
          _busy = false;
          _error = AppLocalizations.of(context).fitnessSaveFailed;
        });
      }
    }
  }

  /// 完成后返回原计划列表；跳转入口不在栈中时回到原页面。
  void _finish() {
    if (_busy) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) fitnessReturnTo(context, Routes.fitnessPlans);
    });
  }

  /// 进度标签使用相同名称，辅助模式也能读出当前步骤。
  Widget _steps(AppLocalizations l) => Padding(
    padding: const EdgeInsets.all(AppDimens.p16),
    child: Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.p4),
              child: Icon(AppIcons.chevronRight, size: AppDimens.icon12),
            ),
          Expanded(
            child: Semantics(
              selected: i == _step,
              child: Text(
                '${i + 1}  ${[l.fitnessPlanBasicStep, l.fitnessPlanScheduleStep, _editing ? l.fitnessPlanConfirmSave : l.fitnessPlanConfirmStep][i]}',
                key: ValueKey('fitness-plan-step-${i + 1}'),
                style: AppTextTokens.caption(context).copyWith(
                  color: i == _step
                      ? AppTokens.primary(context)
                      : AppTokens.textSecondary(context),
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );

  /// 基本设置只显示计划名称、周期和下一阶段的内容说明。
  Widget _basic(AppLocalizations l) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AppFormSection(
        title: l.fitnessName,
        child: TextField(
          key: const ValueKey('fitness-plan-name'),
          controller: _name,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(hintText: l.fitnessPlanNameHint),
        ),
      ),
      Text(l.fitnessPlanCycleLabel, style: AppTextTokens.strongTitle(context)),
      const SizedBox(height: AppDimens.p8),
      CapsuleSwitcher<int>(
        selectedValue: [4, 7, 14].contains(_draft.cycleDays)
            ? _draft.cycleDays
            : 0,
        options: [
          for (final count in [4, 7, 14])
            CapsuleOption(value: count, label: l.dayDaysValue(count)),
          CapsuleOption(value: 0, label: l.fitnessCustom),
        ],
        height: AppDimens.actionButtonMinHeight,
        backgroundColor: AppTokens.surfaceSecondary(context),
        selectedBackgroundColor: AppTokens.surfaceSelected(context),
        selectedTextColor: AppTokens.primary(context),
        onChanged: (count) {
          if (count == 0) {
            _customCycle();
          } else {
            _resize(count);
          }
        },
      ),
      const SizedBox(height: AppDimens.p8),
      Text(
        '${l.fitnessPlanCycleCount(_draft.cycleDays)} · ${l.fitnessPlanCycleHint}',
        style: AppTextTokens.caption(context),
      ),
      const SizedBox(height: AppDimens.p20),
      SectionCard(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.fitnessPlanBasicHint,
              style: AppTextTokens.strongTitle(context),
            ),
            const SizedBox(height: AppDimens.p12),
            for (final item in [
              (AppIcons.fitness, l.fitnessPlanDayTemplateHint),
              (AppIcons.darkMode, l.fitnessPlanDayRestHint),
              (AppIcons.calendar, l.fitnessPlanStartHint),
            ])
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimens.p4),
                child: Row(
                  children: [
                    Icon(
                      item.$1,
                      size: AppDimens.icon20,
                      color: AppTokens.primary(context),
                    ),
                    const SizedBox(width: AppDimens.p12),
                    Expanded(
                      child: Text(item.$2, style: AppTextTokens.body(context)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ],
  );

  /// 周期编排逐天展示，未安排日与休息日由独立状态区分。
  Widget _schedule(AppLocalizations l) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(_name.text, style: AppTextTokens.strongTitle(context)),
      const SizedBox(height: AppDimens.p4),
      Text(
        l.fitnessPlanCycleCount(_draft.cycleDays),
        style: AppTextTokens.caption(context),
      ),
      const SizedBox(height: AppDimens.p16),
      Text(
        l.fitnessPlanAssigned(_filled.length, _draft.cycleDays),
        style: AppTextTokens.body(context),
      ),
      const SizedBox(height: AppDimens.p12),
      FitnessPlanDayList(
        key: ValueKey('fitness-plan-focus-$_focusRequest'),
        days: _draft.days,
        filledDays: _filled,
        onDayTap: _pickDay,
        focusDayIndex: _focusDay,
      ),
      if (_filled.length < _draft.cycleDays)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            key: const ValueKey('fitness-plan-rest-remaining'),
            onPressed: _restRemaining,
            child: Text(
              l.fitnessPlanRestRemaining(_draft.cycleDays - _filled.length),
            ),
          ),
        ),
    ],
  );

  /// 确认页只设置日期和启用方式，所有训练内容沿用周期编排结果。
  Widget _review(AppLocalizations l) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FitnessPlanSummary(plan: _draft.copyWith(name: _name.text)),
      const SizedBox(height: AppDimens.p16),
      AppFormSection(
        title: l.fitnessStartDate,
        child: AppSelectionField(
          title: _draft.startDate ?? l.fitnessPlanNoStartDate,
          enabled: !_dateLocked,
          onTap: _dateLocked ? null : _pickStart,
        ),
      ),
      Text(
        _dateLocked
            ? l.fitnessPlanStartLocked
            : l.fitnessPlanDateFrom(_draft.startDate ?? ''),
        style: AppTextTokens.caption(context),
      ),
      const SizedBox(height: AppDimens.p16),
      SectionCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(AppDimens.p12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _editing
                  ? l.fitnessPlanEditStartChoice
                  : l.fitnessPlanStartChoice,
              style: AppTextTokens.strongTitle(context),
            ),
            RadioGroup<bool>(
              groupValue: _draft.status == 'in_progress',
              onChanged: (value) {
                if (value != null) _setEnabled(value);
              },
              child: Column(
                children: [
                  AppRadioTile<bool>.grouped(
                    key: const ValueKey('fitness-plan-enabled'),
                    value: true,
                    title: l.fitnessPlanEnableOnDate,
                  ),
                  AppRadioTile<bool>.grouped(
                    key: const ValueKey('fitness-plan-disabled'),
                    value: false,
                    title: l.fitnessPlanSaveDisabled,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      if (_editing &&
          widget.plan!.generationState.nextCycleStartDate != null) ...[
        const SizedBox(height: AppDimens.p12),
        Text(l.fitnessPlanPendingChange, style: AppTextTokens.caption(context)),
      ],
      const SizedBox(height: AppDimens.p20),
      Text(l.fitnessPlanSchedule, style: AppTextTokens.strongTitle(context)),
      const SizedBox(height: AppDimens.p8),
      FitnessPlanDayList(days: _draft.days),
    ],
  );

  /// 创建成功后展示完整周期，而不截断为首个训练日。
  Widget _success(AppLocalizations l) {
    final plan = _created!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppDimens.p20),
        Icon(
          AppIcons.checkCircle,
          size: AppDimens.icon40,
          color: AppTokens.primary(context),
        ),
        const SizedBox(height: AppDimens.p12),
        Text(
          l.fitnessPlanCreated,
          textAlign: TextAlign.center,
          style: AppTextTokens.display1(context),
        ),
        const SizedBox(height: AppDimens.p8),
        Text(
          plan.status == 'in_progress'
              ? l.fitnessPlanCreatedEnabled(plan.startDate ?? '')
              : l.fitnessPlanCreatedDisabled,
          textAlign: TextAlign.center,
          style: AppTextTokens.caption(context),
        ),
        const SizedBox(height: AppDimens.p20),
        FitnessPlanSummary(plan: plan),
        const SizedBox(height: AppDimens.p20),
        Text(
          l.fitnessPlanCompleteCycle,
          style: AppTextTokens.strongTitle(context),
        ),
        const SizedBox(height: AppDimens.p8),
        FitnessPlanDayList(days: plan.days),
      ],
    );
  }

  /// 底部统一提供阶段回退和主操作，按钮文案与步骤名称保持一致。
  Widget _footer(AppLocalizations l, bool available) {
    if (_created != null) {
      return AppEditorFooter(label: l.fitnessPlanDone, onPressed: _finish);
    }
    final label = _step == 0
        ? l.fitnessPlanNextSchedule
        : _step == 1
        ? (_editing ? l.fitnessPlanNextConfirmSave : l.fitnessPlanNextConfirm)
        : _editing || _draft.status == 'closed'
        ? l.commonSave
        : l.fitnessPlanCreateEnabled;
    return Material(
      color: AppTokens.surface(context),
      child: AppEditorFooter(
        label: label,
        onPressed: available ? _next : null,
        busy: _busy,
        secondaryLabel: _step > 0 ? l.fitnessPlanPreviousStep : null,
        onSecondaryPressed: available ? _previous : null,
        primaryButtonKey: const ValueKey('fitness-plan-next'),
        secondaryButtonKey: const ValueKey('fitness-plan-previous'),
      ),
    );
  }

  /// 系统返回始终走退出确认，成功页的完整周期可以直接返回列表。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final actions = ref.watch(fitnessActionsProvider);
    ref.watch(fitnessTemplatesProvider);
    _owner ??= actions.target;
    final available = matchesPrivateBookTarget(_owner!, actions.target);
    if (available) _owner = actions.target;
    final title = _created != null
        ? l.fitnessPlanCreatedTitle
        : _editing
        ? l.fitnessPlanEditTitle
        : l.fitnessPlanNewTitle;
    return PopScope<Object?>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _requestExit();
      },
      child: Scaffold(
        body: Column(
          children: [
            PrimaryHeader(
              title: title,
              titleWidget: Row(
                children: [
                  HeaderIconAction(
                    key: const ValueKey('fitness-plan-exit'),
                    icon: _created != null ? AppIcons.back : AppIcons.close,
                    tooltip: l.commonBack,
                    onPressed: _busy ? null : _requestExit,
                  ),
                  const SizedBox(width: AppDimens.p8),
                  Expanded(child: Text(title)),
                ],
              ),
              actions: _created == null
                  ? [
                      Text(
                        '${_step + 1} / 3',
                        style: AppTextTokens.caption(context),
                      ),
                    ]
                  : null,
            ),
            if (_created == null) _steps(l),
            Expanded(
              child: !available
                  ? AppEmpty(text: l.fitnessLoadFailed)
                  : AbsorbPointer(
                      absorbing: _busy,
                      child: ListView(
                        key: ValueKey(
                          'fitness-plan-content-${_created != null ? 'success' : _step}',
                        ),
                        padding: const EdgeInsets.all(AppDimens.p16),
                        children: [
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppDimens.p12,
                              ),
                              child: Semantics(
                                liveRegion: true,
                                child: Text(
                                  _error!,
                                  style: AppTextTokens.body(
                                    context,
                                  ).copyWith(color: AppTokens.error(context)),
                                ),
                              ),
                            ),
                          if (_created != null)
                            _success(l)
                          else
                            switch (_step) {
                              0 => _basic(l),
                              1 => _schedule(l),
                              _ => _review(l),
                            },
                        ],
                      ),
                    ),
            ),
            _footer(l, available),
          ],
        ),
      ),
    );
  }
}
