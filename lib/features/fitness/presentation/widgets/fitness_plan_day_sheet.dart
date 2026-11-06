import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/logging/logger_service.dart';
import '../../../../data/models/fitness.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/providers/fitness_library_provider.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../../theme/colors.dart';
import '../../../../theme/dimens.dart';
import '../../../../theme/icons/app_icons.dart';
import '../../application/fitness_providers.dart';
import 'fitness_plan_widgets.dart';

/// 当天选择只描述本次表单变更，不立即写入模板或计划。
enum FitnessPlanDaySelectionKind { template, rest, clear }

/// 返回当前明确选择的模板快照，官方内容由计划保存事务统一复制。
class FitnessPlanDaySelection {
  /// 选择训练内容，并记录它是否直接来自官方模板库。
  const FitnessPlanDaySelection.template(this.template, {this.official = false})
    : kind = FitnessPlanDaySelectionKind.template;

  /// 将当天明确安排为休息。
  const FitnessPlanDaySelection.rest()
    : kind = FitnessPlanDaySelectionKind.rest,
      template = null,
      official = false;

  /// 将当天恢复为未安排，供用户重新选择。
  const FitnessPlanDaySelection.clear()
    : kind = FitnessPlanDaySelectionKind.clear,
      template = null,
      official = false;

  final FitnessPlanDaySelectionKind kind;
  final FitnessTemplate? template;
  final bool official;
}

/// 周期编排的当天选择器，清空操作固定在右上角，不显示关闭图标。
class FitnessPlanDaySheet extends ConsumerStatefulWidget {
  /// 当前安排用于标示已选内容；已填休息日同样允许清空。
  const FitnessPlanDaySheet({
    super.key,
    required this.dayIndex,
    required this.filled,
    this.currentSlot,
  });

  final int dayIndex;
  final bool filled;
  final FitnessPlanSlot? currentSlot;

  /// 创建独立页签状态，切换模板来源不会改变当天安排。
  @override
  ConsumerState<FitnessPlanDaySheet> createState() =>
      _FitnessPlanDaySheetState();
}

class _FitnessPlanDaySheetState extends ConsumerState<FitnessPlanDaySheet> {
  bool _official = false;
  bool _previewing = false;

  /// 只有用户明确选择后才关闭弹层并把结果交给计划编辑器。
  void _choose(FitnessPlanDaySelection choice) {
    if (ModalRoute.isCurrentOf(context) == true) {
      Navigator.of(context).pop(choice);
    }
  }

  /// 预览只读动作，不导入模板，返回时保留选择器和当前页签。
  Future<void> _preview(FitnessTemplate template, bool official) async {
    if (_previewing) return;
    _previewing = true;
    try {
      final l = AppLocalizations.of(context);
      final result = await showAppSheet<FitnessPlanDaySelection>(
        context: context,
        child: AppSheet(
          title: template.name,
          footer: AppPairedActions(
            primaryLabel: l.fitnessPlanArrangeDay(widget.dayIndex + 1),
            onPrimaryPressed: () => Navigator.of(context).pop(
              FitnessPlanDaySelection.template(template, official: official),
            ),
            secondaryLabel: l.commonBack,
            onSecondaryPressed: () => Navigator.of(context).pop(),
          ),
          child: SingleChildScrollView(
            child: FitnessPlanExercises(exercises: template.exercises),
          ),
        ),
      );
      if (result != null && mounted) _choose(result);
    } catch (error, stackTrace) {
      logger.error('FitnessPlanDaySheet', '预览计划训练内容失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).fitnessLoadFailed);
      }
    } finally {
      _previewing = false;
    }
  }

  /// 模板行同时提供只读预览和明确选择，当前选择与来源身份保持一致。
  Widget _templateRow(FitnessTemplate template, bool official) {
    final l = AppLocalizations.of(context);
    final selected = widget.currentSlot?.sourceTemplateId == template.id;
    final count = template.exercises.fold<int>(0, (n, e) => n + e.sets.length);
    return AppListTile(
      title: template.name,
      subtitle: l.fitnessPlanDaySummary(template.exercises.length, count),
      titleMaxLines: null,
      subtitleMaxLines: null,
      onTap: () => _preview(template, official),
      trailing: TextButton(
        key: ValueKey('fitness-plan-select-template-${template.id}'),
        onPressed: () => _choose(
          FitnessPlanDaySelection.template(template, official: official),
        ),
        child: selected
            ? const Icon(AppIcons.check)
            : Text(l.fitnessPlanSelectTemplate),
      ),
    );
  }

  /// 页签的数据加载和失败均停留在选择器，用户可以切换来源或重试。
  Widget _content() {
    final l = AppLocalizations.of(context);
    if (_official) {
      return ref
          .watch(fitnessLibraryProvider)
          .when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => AppLoadError(
              message: l.fitnessLoadFailed,
              onRetry: () => ref.invalidate(fitnessLibraryProvider),
            ),
            data: (library) => ListView.separated(
              shrinkWrap: true,
              itemCount: library.templates.length,
              separatorBuilder: (context, _) =>
                  AppTokens.cardDivider(context, indent: 0, verticalGap: 0),
              itemBuilder: (_, index) {
                final t = library.templates[index];
                return _templateRow(
                  t.toFitnessTemplate(
                    Localizations.localeOf(context),
                    id: t.id,
                  ),
                  true,
                );
              },
            ),
          );
    }
    return ref
        .watch(fitnessTemplatesProvider)
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => AppLoadError(
            message: l.fitnessLoadFailed,
            onRetry: () => ref.invalidate(fitnessTemplatesProvider),
          ),
          data: (templates) => templates.isEmpty
              ? AppEmpty(text: l.fitnessNoTemplates)
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: templates.length,
                  separatorBuilder: (context, _) =>
                      AppTokens.cardDivider(context, indent: 0, verticalGap: 0),
                  itemBuilder: (_, index) =>
                      _templateRow(templates[index], false),
                ),
        );
  }

  /// 标题右侧只显示清空当天；拖拽或点击遮罩可取消选择。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppSheet(
      title: l.fitnessPlanArrangeDay(widget.dayIndex + 1),
      trailing: widget.filled
          ? HeaderTextAction(
              key: const ValueKey('fitness-plan-clear-day'),
              label: l.fitnessPlanClearDay,
              onPressed: () => _choose(const FitnessPlanDaySelection.clear()),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSecondaryButton(
            key: const ValueKey('fitness-plan-select-rest'),
            onPressed: () => _choose(const FitnessPlanDaySelection.rest()),
            icon: AppIcons.darkMode,
            label: l.fitnessPlanSetRest,
          ),
          const SizedBox(height: AppDimens.p12),
          CapsuleSwitcher<bool>(
            options: [
              CapsuleOption(value: false, label: l.fitnessMyTemplates),
              CapsuleOption(value: true, label: l.fitnessTemplateLibrary),
            ],
            selectedValue: _official,
            height: AppDimens.actionButtonMinHeight,
            backgroundColor: AppTokens.surfaceSecondary(context),
            selectedBackgroundColor: AppTokens.surfaceSelected(context),
            selectedTextColor: AppTokens.primary(context),
            onChanged: (value) => setState(() => _official = value),
          ),
          const SizedBox(height: AppDimens.p12),
          Flexible(child: _content()),
        ],
      ),
    );
  }
}
