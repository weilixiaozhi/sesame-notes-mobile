import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/features/auth/application/welcome_onboarding.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';
import 'package:sesame_notes/theme/colors.dart';

/// 首次启动介绍四个常驻业务入口，完成初始化后进入应用。
class WelcomePage extends ConsumerStatefulWidget {
  const WelcomePage({super.key});
  @override
  ConsumerState<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends ConsumerState<WelcomePage> {
  bool _isInitializing = false;

  /// 内容可滚动，完成按钮常驻，窄屏和大字号下仍可继续。
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimens.domainPageInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: AppLogo(size: AppDimens.welcomeLogoSize),
                      ),
                      const SizedBox(height: AppDimens.p20),
                      Text(
                        l.welcomeDomainsTitle,
                        style: AppTextTokens.domainTitle(context),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimens.p20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: AppDimens.p16,
                        runSpacing: AppDimens.p12,
                        children: [
                          for (final item in [
                            (AppIcons.book, l.shellMoney),
                            (AppIcons.calendar, l.shellDays),
                            (AppIcons.memo, l.shellMemos),
                            (AppIcons.fitness, l.shellFitness),
                          ])
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(item.$1, size: AppDimens.icon20),
                                const SizedBox(width: AppDimens.p8),
                                Text(item.$2),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.domainPageInset),
              child: SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  fullWidth: false,
                  label: l.commonFinish,
                  busy: _isInitializing,
                  onPressed: _isInitializing ? null : _finishWelcome,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 初始化成功后进入应用，失败显示原因并恢复完成按钮以便重试。
  Future<void> _finishWelcome() async {
    if (_isInitializing) return;
    setState(() => _isInitializing = true);
    try {
      await ref
          .read(welcomeOnboardingProvider)
          .complete(l10n: AppLocalizations.of(context));
    } catch (error, stack) {
      logger.error('Welcome', '首次初始化失败', error, stack);
      if (mounted) {
        await AppDialog.error(
          context,
          title: AppLocalizations.of(context).commonFailed,
          message: AppLocalizations.of(context).commonOperationFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }
}
