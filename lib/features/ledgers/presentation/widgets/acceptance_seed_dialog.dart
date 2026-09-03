/// 首页 debug 入口的验收数据选项弹窗。
///
/// 仅 debug 构建调用：弹出五个验收数据生成选项，点击返回对应枚举值，
/// 生成逻辑由调用方（HomePage）经 providers 门面执行。文案为 debug
/// 专用硬编码中文，不进 l10n（与生产文案隔离）。
library;

import 'package:flutter/material.dart';

import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 验收数据生成选项。
enum AcceptanceSeedOption {
  /// 一键填充账单（近 12 个月）。
  fillBills,

  /// 新建本地账本。
  createLocalLedger,

  /// 新建云账本（未登录时由调用方跳过）。
  createCloudLedger,

  /// 新建 AA 分摊账单。
  createAaBills,

  /// 新建虚拟用户。
  createVirtualUsers,
}

/// 弹出验收数据选项弹窗；用户取消时返回 null。
Future<AcceptanceSeedOption?> showAcceptanceSeedDialog(BuildContext context) {
  return showDialog<AcceptanceSeedOption>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('验收数据'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _option(
            ctx,
            AcceptanceSeedOption.fillBills,
            AppIcons.autoAwesome,
            '一键填充账单（近 12 个月）',
          ),
          _option(
            ctx,
            AcceptanceSeedOption.createLocalLedger,
            AppIcons.cloudOff,
            '新建本地账本',
          ),
          _option(
            ctx,
            AcceptanceSeedOption.createCloudLedger,
            AppIcons.cloud,
            '新建云账本',
          ),
          _option(
            ctx,
            AcceptanceSeedOption.createAaBills,
            AppIcons.pieChart,
            '新建 AA 分摊账单',
          ),
          _option(
            ctx,
            AcceptanceSeedOption.createVirtualUsers,
            AppIcons.personAdd,
            '新建虚拟用户（3 个）',
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
