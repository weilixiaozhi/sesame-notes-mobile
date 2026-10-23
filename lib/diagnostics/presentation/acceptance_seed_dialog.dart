/// 首页 debug 入口的验收数据选项弹窗。
///
/// 仅 debug 构建调用：按业务弹出验收数据生成选项，点击返回对应枚举值，
/// 入口统一经 providers 门面执行生成逻辑。文案为 debug
/// 专用硬编码中文，不进 l10n（与生产文案隔离）。
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/diagnostics/application/acceptance_data_providers.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/shared/widgets/primary_header.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:sesame_notes/shared/widgets/app_content_dialog.dart';
import 'package:sesame_notes/data/models/app_mode.dart';

import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 验收数据生成选项。
enum AcceptanceSeedOption {
  /// 一键填充账单（近 12 个月）。
  fill,

  /// 健身暂停场景，与进行中场景互斥。
  fillPaused,

  /// 新建本地账本。
  createLocal,

  /// 新建云账本（未登录时由调用方跳过）。
  createCloud,

  /// 新建 AA 分摊账单。
  createAaBills,

  /// 新建虚拟用户。
  createVirtualUsers,
}

/// 弹出验收数据选项弹窗；用户取消时返回 null。
Future<AcceptanceSeedOption?> showAcceptanceSeedDialog(
  BuildContext context, {
  AppMode mode = AppMode.bookkeeping,
}) {
  return showDialog<AcceptanceSeedOption>(
    context: context,
    builder: (ctx) => AppContentDialog(
      title: '验收数据',
      actions: const [],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mode == AppMode.fitness)
            const Text('每批包含模板、计划、已完成和未开始的训练。进行中与暂停场景二选一；请先结束当前训练再添加。'),
          _option(
            ctx,
            AcceptanceSeedOption.fill,
            AppIcons.autoAwesome,
            switch (mode) {
              AppMode.bookkeeping => '一键填充账单（近 12 个月）',
              AppMode.days => '一键填充纪念日',
              AppMode.memos => '一键填充备忘录',
              AppMode.fitness => '一键填充健身（进行中场景）',
            },
          ),
          if (mode == AppMode.fitness)
            _option(
              ctx,
              AcceptanceSeedOption.fillPaused,
              AppIcons.autoAwesome,
              '一键填充健身（暂停场景）',
            ),
          if (mode != AppMode.fitness)
            _option(
              ctx,
              AcceptanceSeedOption.createLocal,
              AppIcons.cloudOff,
              switch (mode) {
                AppMode.bookkeeping => '添加本地账本',
                AppMode.days => '添加本地纪念日本',
                AppMode.memos => '添加本地备忘录示例本',
                AppMode.fitness => '健身',
              },
            ),
          if (mode != AppMode.fitness)
            _option(
              ctx,
              AcceptanceSeedOption.createCloud,
              AppIcons.cloud,
              switch (mode) {
                AppMode.bookkeeping => '添加云账本',
                AppMode.days => '添加云端纪念日本',
                AppMode.memos => '添加云端备忘录示例本',
                AppMode.fitness => '健身',
              },
            ),
          if (mode == AppMode.bookkeeping)
            _option(
              ctx,
              AcceptanceSeedOption.createAaBills,
              AppIcons.pieChart,
              '添加 AA 分摊账单',
            ),
          if (mode == AppMode.bookkeeping)
            _option(
              ctx,
              AcceptanceSeedOption.createVirtualUsers,
              AppIcons.personAdd,
              '添加虚拟用户（3 个）',
            ),
        ],
      ),
    ),
  );
}

/// 弹窗选项行：点击后 pop 返回对应枚举。
Widget _option(
  BuildContext ctx,
  AcceptanceSeedOption value,
  IconData icon,
  String title,
) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    onTap: () => Navigator.pop(ctx, value),
  );
}

/// 各业务首页共用入口、选项、执行锁和结果反馈，页面只声明业务类型。
class AcceptanceSeedAction extends ConsumerStatefulWidget {
  const AcceptanceSeedAction({super.key, required this.mode});
  final AppMode mode;
  @override
  ConsumerState<AcceptanceSeedAction> createState() =>
      _AcceptanceSeedActionState();
}

class _AcceptanceSeedActionState extends ConsumerState<AcceptanceSeedAction> {
  bool _busy = false;

  Future<String> _run(AcceptanceSeedOption option) async {
    if (widget.mode == AppMode.fitness) {
      await ref
          .read(acceptanceDataActionsProvider)
          .seedAcceptanceFitness(
            paused: option == AcceptanceSeedOption.fillPaused,
          );
      return '已添加模板、计划、已完成与未开始训练，以及${option == AcceptanceSeedOption.fillPaused ? '暂停' : '进行中'}训练';
    }
    if (widget.mode == AppMode.bookkeeping) {
      return switch (option) {
        AcceptanceSeedOption.fill =>
          '已填充 ${await ref.read(acceptanceDataActionsProvider).seedAcceptanceBills()} 笔账单（近 12 个月）',
        AcceptanceSeedOption.createLocal =>
          '已创建本地账本：${await ref.read(acceptanceDataActionsProvider).seedAcceptanceLocalLedger()}',
        AcceptanceSeedOption.createCloud =>
          (await ref
                  .read(acceptanceDataActionsProvider)
                  .seedAcceptanceCloudLedger()) ??
              '未登录，已跳过云账本创建',
        AcceptanceSeedOption.createAaBills =>
          '已创建 ${await ref.read(acceptanceDataActionsProvider).seedAcceptanceAaBills()} 笔 AA 分摊账单',
        AcceptanceSeedOption.createVirtualUsers =>
          '已创建 ${await ref.read(acceptanceDataActionsProvider).seedAcceptanceVirtualUsers()} 个虚拟用户',
        AcceptanceSeedOption.fillPaused => throw StateError('不支持的验收选项'),
      };
    }
    if (option == AcceptanceSeedOption.fill) {
      final count = widget.mode == AppMode.days
          ? await ref.read(acceptanceDataActionsProvider).seedAcceptanceDays()
          : await ref.read(acceptanceDataActionsProvider).seedAcceptanceMemos();
      return '已填充 $count 条测试数据';
    }
    final cloud = option == AcceptanceSeedOption.createCloud;
    if (widget.mode == AppMode.days) {
      return (await ref
              .read(acceptanceDataActionsProvider)
              .seedAcceptanceDayBook(cloud: cloud)) ??
          '未登录，已跳过云端本创建';
    }
    final count = await ref
        .read(acceptanceDataActionsProvider)
        .seedAcceptanceMemoBooks(cloud: cloud);
    return count == null
        ? '未登录，已跳过云端本创建'
        : '已新建 $count 个${cloud ? '云端' : '本地'}备忘录本';
  }

  Future<void> _open() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final option = await showAcceptanceSeedDialog(context, mode: widget.mode);
      if (option == null || !mounted) return;
      final message = await _run(option);
      if (mounted) showToast(context, message);
    } on FitnessRunningWorkoutException {
      if (mounted) showToast(context, '请先结束当前进行中或暂停的训练，再添加验收数据');
    } catch (error, stackTrace) {
      logger.error('AcceptanceSeed', '生成验收数据失败', error, stackTrace);
      if (mounted) showToast(context, '生成验收数据失败，请重试');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => !kDebugMode
      ? const SizedBox.shrink()
      : HeaderIconAction(
          icon: AppIcons.autoAwesome,
          tooltip: '验收数据',
          onPressed: _busy ? null : _open,
        );
}
