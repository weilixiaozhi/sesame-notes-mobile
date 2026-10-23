import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/providers/theme_providers.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/shared/widgets/app_status_banner.dart';
import 'package:sesame_notes/theme/app_visual_theme.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

/// 视觉主题与显示模式独立选择，预览卡只覆盖自己的外观。
class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  /// 只有明确选择且实际保存成功才记录完成，恢复偏好与重建不进入此入口。
  Future<void> _changeTheme(
    BuildContext context,
    WidgetRef ref,
    VoidCallback apply,
  ) async {
    try {
      final analytics = ref.read(productAnalyticsControllerProvider);
      final completed = analytics.captureCompletion(
        pageId: 'settings.theme',
        context: analytics.captureContext(),
      );
      apply();
      final pending = ref.read(themePreferenceWriteResultProvider)();
      if (await pending) completed(ProductAction.settingsThemeChanged);
    } catch (error, stackTrace) {
      logger.error(
        'ThemeSettings',
        '外观偏好暂时无法保存',
        error.runtimeType,
        stackTrace,
      );
      if (context.mounted) {
        showToast(
          context,
          AppLocalizations.of(context).appearanceThemeSaveFailed,
        );
      }
    }
  }

  /// 重试确实保存全部待写选择后记录一次成功，空重试和失败不计数。
  Future<void> _retryTheme(BuildContext context, WidgetRef ref) async {
    try {
      final analytics = ref.read(productAnalyticsControllerProvider);
      final completed = analytics.captureCompletion(
        pageId: 'settings.theme',
        context: analytics.captureContext(),
      );
      if (await ref.read(retryThemePreferencesProvider)()) {
        completed(ProductAction.settingsThemeChanged);
      }
    } catch (error, stackTrace) {
      logger.error('ThemeSettings', '重试外观偏好失败', error.runtimeType, stackTrace);
      if (context.mounted) {
        showToast(
          context,
          AppLocalizations.of(context).appearanceThemeSaveFailed,
        );
      }
    }
  }

  /// 展示主题选项，选择后即时更新当前主题。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final preset = ref.watch(themePresetProvider);
    final mode = ref.watch(themeModeProvider);
    final unsaved = ref.watch(themePreferenceUnsavedProvider);
    final retrying = ref.watch(themePreferenceRetryingProvider);
    ref.watch(themeModeInitProvider);
    ref.watch(themePresetInitProvider);
    ref.listen(themePreferenceFailureProvider, (previous, next) {
      if (next != previous) showToast(context, l10n.appearanceThemeSaveFailed);
    });
    final modes = {
      ThemeMode.system: l10n.appearanceThemeModeSystem,
      ThemeMode.light: l10n.appearanceThemeModeLight,
      ThemeMode.dark: l10n.appearanceThemeModeDark,
    };
    final themes = {
      AppThemePreset.classic: (
        l10n.appearanceThemeClassic,
        l10n.appearanceThemeClassicDescription,
      ),
      AppThemePreset.minimal: (
        l10n.appearanceThemeMinimal,
        l10n.appearanceThemeMinimalDescription,
      ),
      AppThemePreset.journal: (
        l10n.appearanceThemeJournal,
        l10n.appearanceThemeJournalDescription,
      ),
    };
    return Scaffold(
      body: Column(
        children: [
          PrimaryHeader(title: l10n.appearanceThemeTitle, showBack: true),
          Expanded(
            child: ListView(
              key: const PageStorageKey('appearance-settings-scroll'),
              padding: const EdgeInsets.all(AppDimens.p16),
              children: [
                if (unsaved.isNotEmpty) ...[
                  AppStatusBanner(
                    icon: AppIcons.warning,
                    message: l10n.appearanceThemeSaveFailed,
                    action: TextButton(
                      key: const ValueKey('theme-preference-retry'),
                      onPressed: retrying
                          ? null
                          : () => _retryTheme(context, ref),
                      child: Text(l10n.commonRetry),
                    ),
                  ),
                  const SizedBox(height: AppDimens.p16),
                ],
                Text(
                  l10n.appearanceThemeIntro,
                  style: AppTextTokens.label(context),
                ),
                const SizedBox(height: AppDimens.p12),
                RadioGroup<AppThemePreset>(
                  groupValue: preset,
                  onChanged: (value) {
                    if (value != null && value != preset) {
                      unawaited(
                        _changeTheme(
                          context,
                          ref,
                          () =>
                              ref.read(themePresetProvider.notifier).set(value),
                        ),
                      );
                    }
                  },
                  child: Column(
                    children: [
                      for (final entry in themes.entries)
                        _ThemePreviewCard(
                          preset: entry.key,
                          title: entry.value.$1,
                          description: entry.value.$2,
                          selected: entry.key == preset,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.p16),
                Text(
                  l10n.appearanceThemeMode,
                  style: AppTextTokens.strongTitle(context),
                ),
                const SizedBox(height: AppDimens.p12),
                CapsuleSwitcher<ThemeMode>(
                  key: const ValueKey('appearance-mode-segments'),
                  selectedValue: mode,
                  height: AppDimens.actionButtonMinHeight + AppDimens.p8,
                  borderRadius: BorderRadius.circular(
                    AppTokens.inputRadius(context),
                  ),
                  segmentBorderRadius: BorderRadius.circular(
                    AppTokens.modeSegmentRadius(context),
                  ),
                  selectedShadows: AppTokens.modeSelectionShadow(),
                  backgroundColor: AppTokens.surfaceSecondary(context),
                  selectedBackgroundColor: AppTokens.surface(context),
                  selectedTextColor: AppTokens.textPrimary(context),
                  unselectedTextColor: AppTokens.textSecondary(context),
                  options: [
                    for (final entry in modes.entries)
                      CapsuleOption(value: entry.key, label: entry.value),
                  ],
                  onChanged: (value) {
                    if (value != mode) {
                      unawaited(
                        _changeTheme(
                          context,
                          ref,
                          () => ref.read(themeModeProvider.notifier).set(value),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: AppDimens.p12),
                Text(
                  l10n.appearanceThemeNote,
                  style: AppTextTokens.label(context).copyWith(height: 1.8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 选项卡外观跟随当前主题，色样与缩略图展示被预览的皮肤。
class _ThemePreviewCard extends StatelessWidget {
  /// 每张预览只替换样例颜色，不覆盖整张选项卡的选中反馈。
  const _ThemePreviewCard({
    required this.preset,
    required this.title,
    required this.description,
    required this.selected,
  });
  final AppThemePreset preset;
  final String title;
  final String description;
  final bool selected;

  /// 标题行沿用分组单选的读屏与键盘操作，缩略图占满其下方区域。
  @override
  Widget build(BuildContext context) {
    final sample = AppVisualTheme.resolve(preset, Theme.of(context).brightness);
    final border = BorderSide(
      color: selected ? AppTokens.primary(context) : AppTokens.divider(context),
    );
    return CardTheme(
      data: CardTheme.of(context).copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.cardRadius(context)),
          side: selected
              ? border.copyWith(width: AppDimens.selectionIndicatorWidth)
              : border,
        ),
      ),
      child: SectionCard(
        key: ValueKey('theme-preview-${preset.name}'),
        showShadow: false,
        textured: false,
        margin: const EdgeInsets.only(bottom: AppDimens.p12),
        padding: EdgeInsets.zero,
        child: AppRadioTile<AppThemePreset>.grouped(
          value: preset,
          title: title,
          leading: ExcludeSemantics(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radius8),
              child: SizedBox(
                width: AppDimens.p32,
                height: AppDimens.p32,
                child: Row(
                  children: [
                    for (final role in [
                      AppThemeColor.page,
                      AppThemeColor.action,
                      AppThemeColor.surface,
                    ])
                      Expanded(
                        child: ColoredBox(
                          color: sample.color(role),
                          child: const SizedBox.expand(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          subtitle: Text(description, style: AppTextTokens.label(context)),
          bottom: ExcludeSemantics(child: _ThemeMiniature(sample: sample)),
        ),
      ),
    );
  }
}

/// 缩略图使用页背景、内容卡、文字线与动作色块，不展示虚构业务数据。
class _ThemeMiniature extends StatelessWidget {
  /// 只读样例取自与应用完全相同的六份视觉配置。
  const _ThemeMiniature({required this.sample});
  final AppVisualTheme sample;

  /// 三套皮肤以相同尺寸比较表面层次与按钮圆角。
  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey('theme-miniature-${sample.preset.name}'),
    height: AppDimens.themePreviewHeight,
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimens.p12,
      vertical: AppDimens.p8,
    ),
    decoration: BoxDecoration(
      color: sample.color(AppThemeColor.page),
      border: Border.all(color: sample.color(AppThemeColor.line)),
      borderRadius: BorderRadius.circular(AppDimens.themePreviewRadius),
    ),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: AppDimens.p32,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.p8,
              vertical: AppDimens.p5,
            ),
            decoration: BoxDecoration(
              color: sample.color(AppThemeColor.surface),
              border: Border.all(color: sample.color(AppThemeColor.line)),
              borderRadius: BorderRadius.circular(
                sample.radius(AppThemeRadius.button),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.65,
                  child: Container(
                    height: AppDimens.p3,
                    color: sample
                        .color(AppThemeColor.text)
                        .withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: AppDimens.p5),
                FractionallySizedBox(
                  widthFactor: 0.9,
                  child: Container(
                    height: AppDimens.p3,
                    color: sample
                        .color(AppThemeColor.text)
                        .withValues(alpha: 0.16),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppDimens.p8),
        Container(
          width: AppDimens.p32,
          height: AppDimens.themePreviewActionHeight,
          decoration: BoxDecoration(
            color: sample.color(AppThemeColor.action),
            borderRadius: BorderRadius.circular(
              sample.radius(AppThemeRadius.button),
            ),
          ),
        ),
      ],
    ),
  );
}
