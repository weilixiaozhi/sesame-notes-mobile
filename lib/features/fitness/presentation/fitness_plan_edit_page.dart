import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/utils/text_validation.dart';
import '../../../data/models/private_book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/fitness_library.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/shared/widgets/app_calendar.dart';
import 'package:sesame_notes/shared/widgets/app_form_section.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import '../application/fitness_providers.dart';
import 'widgets/fitness_library_widgets.dart';
import 'widgets/fitness_widgets.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';

/// 计划页的模板按钮：固定两列尺寸、统一主题色，长名称省略号收尾。
/// 我的计划点击后安排到当天，官方计划点击后进入只读模板详情。
class _PlanTemplateButtons extends StatelessWidget {
  const _PlanTemplateButtons({
    super.key,
    required this.items,
    required this.onSelected,
  });
  final List<({String id, String name})> items;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = AppDimens.p8;
      // 固定两列：按钮宽度只跟可用宽度有关，不随名称长度变化。
      final width = (constraints.maxWidth - gap) / 2;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final item in items)
            SizedBox(
              key: ValueKey('fitness-plan-template-${item.id}'),
              width: width,
              height: AppDimens.actionButtonMinHeight,
              child: AppInputSurface(
                onTap: () => onSelected(item.id),
                child: Row(
                  children: [
                    Icon(
                      AppIcons.fitness,
                      size: AppDimens.icon16,
                      color: AppTokens.iconSecondary(context),
                    ),
                    const SizedBox(width: AppDimens.p8),
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextTokens.label(
                          context,
                        ).copyWith(color: AppTokens.textPrimary(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}

class FitnessPlanEditPage extends ConsumerStatefulWidget {
  const FitnessPlanEditPage({super.key, this.plan, this.importDraft})
    : assert(plan == null || importDraft == null);
  final FitnessPlan? plan;
  final FitnessPlanImportDraft? importDraft;
  @override
  ConsumerState<FitnessPlanEditPage> createState() =>
      _FitnessPlanEditPageState();
}

class _FitnessPlanEditPageState extends ConsumerState<FitnessPlanEditPage> {
  late final FitnessPlan? _saved = widget.importDraft == null
      ? widget.plan
      : null;
  late FitnessPlan _draft =
      widget.importDraft?.plan ??
      widget.plan ??
      FitnessPlan(
        name: '',
        status: 'in_progress',
        startDate: fitnessDate(DateTime.now()),
        cycleDays: 7,
        days: List.generate(7, (i) => FitnessPlanDay(dayIndex: i)),
      );
  late final _name = TextEditingController(text: _draft.name);
  final _formKey = GlobalKey<FormState>();
  int _selected = 0;
  late Set<int> _filled = widget.plan == null && widget.importDraft == null
      ? {}
      : {for (final day in _draft.days) day.dayIndex};
  String? _restartDate;
  bool _busy = false;
  late PrivateBookTarget? _owner = widget.importDraft?.target;

  /// 官方计划确认页：只读展示周期安排，底部只保留"添加到我的计划"。
  bool get _readOnly => widget.importDraft != null;

  @override
  void initState() {
    super.initState();
    if (_draft.startDate == null) {
      _draft = _draft.copyWith(startDate: fitnessDate(DateTime.now()));
    }
    if (_draft.pendingSchedule case final schedule?) {
      _draft = _draft.copyWith(
        cycleDays: schedule.cycleDays,
        days: schedule.days,
      );
    }
    _draft = _draft.copyWith(
      days: [..._draft.days]..sort((a, b) => a.dayIndex.compareTo(b.dayIndex)),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _assign(FitnessTemplate? template) => setState(() {
    final days = [..._draft.days];
    _filled.add(_selected);
    days[_selected] = FitnessPlanDay(
      dayIndex: _selected,
      slot: template == null
          ? null
          : FitnessPlanSlot(
              id: const Uuid().v4(),
              sourceTemplateId: template.id,
              name: template.name,
              exercises: fitnessSnapshotExercises(template.exercises),
            ),
    );
    _draft = _draft.copyWith(days: days);
    if (_selected < days.length - 1) _selected++;
  });

  /// 只读态展示当天安排的官方模板按钮，与我的计划同一规格，
  /// 区别只是点击进入只读模板详情而不是安排到当天。
  Widget _arrangedTemplate(BuildContext context) {
    final library = widget.importDraft?.library;
    final sourceId = _draft.days[_selected].slot?.sourceTemplateId;
    final template = sourceId == null || library == null
        ? null
        : library.templateOrNull(sourceId);
    if (template == null) return const SizedBox.shrink();
    return _PlanTemplateButtons(
      key: const ValueKey('fitness-plan-arranged-template'),
      items: [
        (
          id: template.id,
          name: template.name.resolve(Localizations.localeOf(context)),
        ),
      ],
      onSelected: (_) =>
          context.pushNamed(Routes.fitnessTemplateDetail, extra: template),
    );
  }

  void _reorder(int from, int to) => setState(() {
    final days = fitnessReorderItems(_draft.days, from, to);
    // 已填充标记跟随安排一起移动，拖动后安排的训练不会落回原位置。
    final filled = fitnessReorderItems(
      [for (var i = 0; i < days.length; i++) _filled.contains(i)],
      from,
      to,
    );
    _filled = {
      for (var i = 0; i < filled.length; i++)
        if (filled[i]) i,
    };
    _draft = _draft.copyWith(
      days: [
        for (var i = 0; i < days.length; i++) days[i].copyWith(dayIndex: i),
      ],
    );
    _selected = to;
  });

  Future<void> _resize() async {
    final value = await fitnessInput(
      context,
      title: AppLocalizations.of(context).fitnessCycleDays,
      initial: '${_draft.cycleDays}',
      numeric: true,
      minValue: 1,
      maxValue: FitnessDefaults.maxCycleDays,
    );
    if (value == null || !mounted) return;
    final count = int.parse(value);
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
      _selected = _selected.clamp(0, count - 1);
      _filled.removeWhere((i) => i >= count);
    });
  }

  Future<bool> _pickStart() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final initial = DateTime.tryParse(_draft.startDate ?? '') ?? today;
    final date = await showWheelDatePicker(
      context,
      initial: initial.isBefore(today) ? today : initial,
      minDate: today,
      title: AppLocalizations.of(context).fitnessStartDate,
    );
    if (date == null || !mounted) return false;
    setState(() {
      final start = fitnessDate(date);
      _restartDate = _saved?.createdAt != null && _saved!.status == 'closed'
          ? start
          : null;
      _draft = _draft.copyWith(startDate: start);
      _selected = 0;
    });
    return true;
  }

  Future<void> _setEnabled(bool enabled) async {
    if (enabled &&
        _saved?.status == 'closed' &&
        _saved?.generationState.nextCycleStartDate != null &&
        _restartDate == null) {
      if (!await _pickStart() || !mounted) return;
    }
    setState(
      () =>
          _draft = _draft.copyWith(status: enabled ? 'in_progress' : 'closed'),
    );
  }

  /// 保存点击和实际写入分别统计，取消模板复用选择不构成保存成功。
  Future<void> _save() async {
    if (_busy) return;
    final analyticsContext = ref
        .read(productAnalyticsControllerProvider)
        .beginFlow();
    final analyticsPage = _readOnly
        ? 'fitness.plans.library.detail'
        : 'fitness.plans.edit';
    final completed = ref
        .read(productAnalyticsControllerProvider)
        .captureCompletion(pageId: analyticsPage, context: analyticsContext);
    ref
        .read(productAnalyticsControllerProvider)
        .trackAction(
          pageId: analyticsPage,
          action: _readOnly
              ? ProductAction.fitnessPlanAddClick
              : ProductAction.fitnessPlanSaveClick,
          context: analyticsContext,
        );
    final l = AppLocalizations.of(context);
    final importDraft = widget.importDraft;
    // 只读确认页不做编辑校验，直接把草稿整体复制进当前训练空间。
    if (importDraft != null) {
      setState(() => _busy = true);
      var added = false;
      try {
        // 选择副本期间也保持单次提交，重复点击不能并行创建两个计划。
        final reusableIds = await _chooseReusableTemplates(importDraft);
        if (reusableIds == null || !mounted) return;
        final repo = ref.read(fitnessActionsProvider);
        final ok = await fitnessRun(context, () async {
          if (_owner != null &&
              !matchesPrivateBookTarget(_owner!, repo.target)) {
            throw StateError('FITNESS_TARGET_CHANGED');
          }
          await repo.importCatalogPlan(
            _draft,
            importDraft.officialTemplates,
            reusableTemplateIds: reusableIds,
          );
        });
        if (ok) completed(ProductAction.fitnessPlanAdded);
        added = ok;
      } finally {
        if (mounted) setState(() => _busy = false);
      }
      if (added && mounted) {
        fitnessReturnTo(context, Routes.fitnessPlans);
      }
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final unfilled = fitnessPlanUnfilledDay(_draft.cycleDays, _filled);
    if (unfilled != null) {
      setState(() => _selected = unfilled);
      showToast(context, l.fitnessPlanFillDays);
      return;
    }
    if (!_draft.days.any((day) => day.slot != null)) {
      showToast(context, l.fitnessInvalidForm);
      return;
    }
    if (_draft.startDate == null) {
      showToast(context, l.fitnessPlanStartDateRequired);
      return;
    }
    final repo = ref.read(fitnessActionsProvider);
    if (_owner != null && !matchesPrivateBookTarget(_owner!, repo.target)) {
      throw StateError('FITNESS_TARGET_CHANGED');
    }
    setState(() => _busy = true);
    final ok = await fitnessRun(context, () async {
      final normalized = _draft.copyWith(name: normalizeName(_name.text));
      await repo.savePlan(
        normalized,
        restartDate: _draft.status == 'in_progress' ? _restartDate : null,
      );
    });
    if (ok) completed(ProductAction.fitnessPlanSaved);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      Navigator.pop(context);
    }
  }

  /// 官方计划引用到的模板已有同源副本时，让用户逐条选择复用或新建；
  /// 没有副本直接新建，取消选择返回 null。
  Future<Map<String, String>?> _chooseReusableTemplates(
    FitnessPlanImportDraft draft,
  ) async {
    final l = AppLocalizations.of(context);
    final copies = await loadUserTemplates(ref);
    if (!mounted) return null;
    final referenced = {
      for (final id in draft.officialTemplates.keys)
        if (fitnessLatestCopy(copies, id) != null) id,
    };
    if (referenced.isEmpty) return const {};
    return chooseTemplateCopies(
      context,
      title: l.fitnessAddToMyPlan,
      labels: {
        for (final id in referenced) id: draft.officialTemplates[id]!.name,
      },
      candidates: {
        for (final id in referenced) id: fitnessCopiesOfOrigin(copies, id),
      },
    );
  }

  Widget _marker(int index) {
    final l = AppLocalizations.of(context);
    final empty = !_filled.contains(index);
    final labels = [
      empty
          ? l.fitnessPlanUnfilled
          : _draft.days[index].slot?.name ?? l.fitnessRestDay,
    ];
    final marker = AppCalendarLabels(
      labels: labels,
      isPlaceholder: empty,
      tooltipTriggerMode: TooltipTriggerMode.manual,
    );
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => !_readOnly && details.data != index,
      onAcceptWithDetails: (details) => _reorder(details.data, index),
      builder: (_, _, _) => LongPressDraggable<int>(
        key: ValueKey('fitness-plan-day-$index'),
        data: index,
        maxSimultaneousDrags: _readOnly || empty ? 0 : 1,
        feedback: Material(
          type: MaterialType.transparency,
          child: SizedBox(
            width: AppDimens.calendarDayDiameter * 2,
            child: marker,
          ),
        ),
        child: InkWell(
          onTap: () => setState(() => _selected = index),
          child: marker,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final repo = ref.watch(fitnessActionsProvider);
    final templateState = ref.watch(fitnessTemplatesProvider);
    _owner ??= repo.target;
    if (matchesPrivateBookTarget(_owner!, repo.target)) _owner = repo.target;
    final available = matchesPrivateBookTarget(_owner!, repo.target);
    final persisted = _saved?.createdAt != null;
    // 同源官方计划已经在当前空间存在时，按钮提示为再次添加。
    final importOrigin = widget.importDraft?.plan.catalogOrigin?.itemId;
    final importAdded =
        importOrigin != null &&
        (ref
                .watch(fitnessPlansProvider)
                .value
                ?.any((plan) => plan.catalogOrigin?.itemId == importOrigin) ??
            false);
    final dateLocked =
        _saved?.status == 'in_progress' &&
        _saved?.generationState.nextCycleStartDate != null;
    final start = fitnessParseDate(_draft.startDate!);
    final selectedDate = fitnessParseDate(
      fitnessAddDays(_draft.startDate!, _selected),
    );
    final selectedName = _filled.contains(_selected)
        ? (_draft.days[_selected].slot?.name ?? l.fitnessRestDay)
        : l.fitnessPlanUnfilled;
    final rowHeight = AppCalendarLabels.rowHeight(context, 1);
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        body: Column(
          children: [
            PrimaryHeader(
              title: _readOnly
                  ? _draft.name
                  : persisted
                  ? l.fitnessPlans
                  : l.fitnessNewPlan,
              showBack: true,
              subtitle: persisted && _draft.startDate != null
                  ? (_saved!.status == 'closed'
                        ? l.fitnessClosed
                        : l.fitnessActive)
                  : null,
            ),
            Expanded(
              child: !available
                  ? AppEmpty(text: l.fitnessLoadFailed)
                  : AbsorbPointer(
                      absorbing: _busy,
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: const EdgeInsets.all(AppDimens.p16),
                          children: [
                            if (!_readOnly) ...[
                              SectionTitle(
                                title: l.fitnessPlanEnabled,
                                trailing: Switch.adaptive(
                                  key: const ValueKey('fitness-plan-enabled'),
                                  value: _draft.status == 'in_progress',
                                  onChanged: _setEnabled,
                                ),
                              ),
                              const SizedBox(height: AppDimens.p16),
                            ],

                            AppFormSection(
                              title: l.fitnessName,
                              child: _readOnly
                                  ? AppSelectionField(
                                      title: _draft.name,
                                      // 与全局禁用态一致：只读字段用禁用色而非正文色。
                                      enabled: false,
                                    )
                                  : TextFormField(
                                      controller: _name,
                                      validator: (value) =>
                                          fitnessValidName(value?.trim() ?? '')
                                          ? null
                                          : l.fitnessInvalidForm,
                                    ),
                            ),
                            AppFormSection(
                              title: l.fitnessCycleDays,
                              child: AppSelectionField(
                                title: '${_draft.cycleDays}',
                                enabled: !_readOnly,
                                onTap: _readOnly ? null : _resize,
                              ),
                            ),
                            AppFormSection(
                              title: l.fitnessStartDate,
                              child: AppSelectionField(
                                title:
                                    _draft.startDate ??
                                    l.fitnessPlanNoStartDate,
                                enabled: !dateLocked,
                                // 官方计划同样可选开始日期，选完下面的排布随之刷新。
                                onTap: dateLocked ? null : _pickStart,
                              ),
                            ),
                            SectionTitle(title: l.fitnessPlanSchedule),
                            const SizedBox(height: AppDimens.p8),
                            AppCalendar<Object>(
                              firstDay: start,
                              lastDay: fitnessParseDate(
                                fitnessAddDays(
                                  _draft.startDate!,
                                  _draft.cycleDays - 1,
                                ),
                              ),
                              focusedDay: start,
                              rangeOnly: true,
                              rowHeight: rowHeight,
                              selectedDayPredicate: (date) =>
                                  fitnessDaysBetween(
                                    _draft.startDate!,
                                    fitnessDate(date),
                                  ) ==
                                  _selected,
                              onDaySelected: (date, _) => setState(
                                () => _selected = fitnessDaysBetween(
                                  _draft.startDate!,
                                  fitnessDate(date),
                                ),
                              ),
                              onPageChanged: (_) {},
                              dayMarkerBuilder: (_, date, _) => _marker(
                                fitnessDaysBetween(
                                  _draft.startDate!,
                                  fitnessDate(date),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimens.p16),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${AppCalendarDateSectionHeader.dateLabel(context, selectedDate)} · $selectedName',
                                    style: AppTextTokens.dateHeading(context),
                                  ),
                                ),
                                if (!_readOnly)
                                  TextButton.icon(
                                    key: const ValueKey('fitness-plan-rest'),
                                    onPressed: () => _assign(null),
                                    icon: const Icon(
                                      AppIcons.darkMode,
                                      size: AppDimens.icon16,
                                    ),
                                    label: Text(l.fitnessPlanSetRest),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppDimens.p16),
                            if (_readOnly)
                              _arrangedTemplate(context)
                            else ...[
                              if (templateState.value?.isNotEmpty == true)
                                Text(
                                  _filled.contains(_selected)
                                      ? l.fitnessPlanReplaceHint
                                      : l.fitnessPlanFillHint,
                                  style: AppTextTokens.label(context),
                                ),
                              const SizedBox(height: AppDimens.p8),
                              templateState.when(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (_, _) => AppLoadError(
                                  message: l.fitnessLoadFailed,
                                  onRetry: () =>
                                      ref.invalidate(fitnessTemplatesProvider),
                                ),
                                data: (templates) => templates.isEmpty
                                    ? AppEmpty(
                                        icon: AppIcons.fitness,
                                        text: l.fitnessNoTemplates,
                                      )
                                    : _PlanTemplateButtons(
                                        items: [
                                          for (final template in templates)
                                            (
                                              id: template.id,
                                              name: template.name,
                                            ),
                                        ],
                                        onSelected: (id) => _assign(
                                          templates.firstWhere(
                                            (template) => template.id == id,
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
            if (available)
              AppEditorFooter(
                onPressed: _save,
                busy: _busy,
                label: _readOnly
                    ? (importAdded ? l.fitnessAddAgain : l.fitnessAddToMyPlan)
                    : l.commonSave,
              ),
          ],
        ),
      ),
    );
  }
}
