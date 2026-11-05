import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/logging/logger_service.dart';
import '../../../data/models/fitness_library.dart';
import '../../../l10n/app_localizations.dart';
import '../../../navigation/route_consts.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../theme/dimens.dart';
import 'widgets/fitness_plan_widgets.dart';

/// 官方计划详情只读呈现完整周期，统一通过调整后使用进入编排。
class FitnessOfficialPlanDetailPage extends StatefulWidget {
  /// 展示进入详情时固定的计划与模板快照。
  const FitnessOfficialPlanDetailPage({super.key, required this.importDraft});

  final FitnessPlanImportDraft importDraft;

  /// 页面持有导航防重入状态，重复点击不会打开多个编辑器。
  @override
  State<FitnessOfficialPlanDetailPage> createState() =>
      _FitnessOfficialPlanDetailPageState();
}

class _FitnessOfficialPlanDetailPageState
    extends State<FitnessOfficialPlanDetailPage> {
  bool _opening = false;

  /// 编辑器接收完整官方快照，实际采用的训练内容由周期编排决定。
  Future<void> _adjust() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      await context.pushNamed(
        Routes.fitnessPlanEdit,
        extra: widget.importDraft,
      );
    } catch (error, stackTrace) {
      logger.error('FitnessOfficialPlanDetail', '打开计划编排失败', error, stackTrace);
      if (mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  /// 详情没有目标或难度副标题，训练日可直接展开动作与组次。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final plan = widget.importDraft.plan;
    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(title: l.fitnessPlanDetailTitle, showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppDimens.p16),
              children: [
                FitnessPlanSummary(plan: plan),
                const SizedBox(height: AppDimens.p16),
                SectionTitle(
                  title: l.fitnessPlanSchedule,
                  trailing: Text(l.fitnessPlanOpenExercises),
                ),
                const SizedBox(height: AppDimens.p8),
                FitnessPlanDayList(days: plan.days),
              ],
            ),
          ),
          AppEditorFooter(
            label: l.fitnessPlanAdjustAndUse,
            busy: _opening,
            onPressed: _opening ? null : _adjust,
          ),
        ],
      ),
    );
  }
}
