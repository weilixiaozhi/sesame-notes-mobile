import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/ui_state_providers.dart';
import 'package:sesame_notes/shared/widgets/app_primary_button.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 必需初始化完成前不挂载业务树，失败时提供可重试的本地说明。
class AppInitializationGate extends StatelessWidget {
  /// 初始化状态由应用编排提供，界面只负责内容隔离与重试入口。
  const AppInitializationGate({
    super.key,
    required this.state,
    required this.onRetry,
    required this.child,
  });

  final AppInitState state;
  final Future<void> Function() onRetry;
  final Widget child;

  /// 重试异常保留诊断信息，失败界面继续存在，不向框架抛出异步错误。
  Future<void> _retry() async {
    try {
      await onRetry();
    } catch (error, stackTrace) {
      logger.error('App', '启动重试暂未完成', safeErrorSummary(error), stackTrace);
    }
  }

  /// 正常业务只在 ready 时进入组件树，深层路由也不能绕过初始化门槛。
  @override
  Widget build(BuildContext context) {
    if (state == AppInitState.ready) return child;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.p16),
            child: state == AppInitState.failed
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.startupPreparationTitle,
                        style: AppTextTokens.strongTitle(context),
                      ),
                      const SizedBox(height: AppDimens.p16),
                      Text(
                        l10n.startupPreparationMessage,
                        style: AppTextTokens.body(context),
                      ),
                      const SizedBox(height: AppDimens.p16),
                      AppPrimaryButton(
                        label: l10n.commonRetry,
                        onPressed: () => unawaited(_retry()),
                      ),
                    ],
                  )
                : CircularProgressIndicator(
                    semanticsLabel: l10n.startupPreparing,
                  ),
          ),
        ),
      ),
    );
  }
}
