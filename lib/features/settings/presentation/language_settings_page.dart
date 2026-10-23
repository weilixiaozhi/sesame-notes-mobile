import 'package:sesame_notes/providers/product_analytics_providers.dart';
import 'package:sesame_notes/domain/analytics/product_analytics_actions.dart';
import 'package:flutter/material.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/features/settings/presentation/widgets/settings_selection.dart';
import 'package:sesame_notes/shared/providers/language_provider.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';

/// 语言设置页，展示系统语言与应用支持的语言。
class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  /// 保存后的实际语言与选择一致才记录完成，失败保留当前设置并提示重试。
  Future<void> _changeLanguage(
    BuildContext context,
    WidgetRef ref,
    Locale? locale,
  ) async {
    if (ref.read(languageProvider) == locale) return;
    final analyticsContext = ref
        .read(productAnalyticsControllerProvider)
        .captureContext();
    try {
      await ref.read(languageProvider.notifier).setLanguage(locale);
      if (!context.mounted) return;
      if (ref.read(languageProvider) != locale) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
        return;
      }
      ref
          .read(productAnalyticsControllerProvider)
          .trackAction(
            pageId: 'settings.language',
            action: ProductAction.settingsLanguageChanged,
            context: analyticsContext,
          );
    } catch (error, stackTrace) {
      logger.error('LanguageSettings', '语言设置暂时无法保存', error, stackTrace);
      if (context.mounted) {
        showToast(context, AppLocalizations.of(context).commonOperationFailed);
      }
    }
  }

  /// 使用统一单选页展示语言，选择后由语言提供者保存。
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return SettingsSelection<Locale?>(
      title: l10n.languageTitle,
      options: {
        null: l10n.languageSystemDefault,
        const Locale('zh'): l10n.languageChinese,
        const Locale('zh', 'TW'): '繁體中文',
        const Locale('en'): l10n.languageEnglish,
      },
      selectedValue: ref.watch(languageProvider),
      onChanged: (locale) => _changeLanguage(context, ref, locale),
    );
  }
}
