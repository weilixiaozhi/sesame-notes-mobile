import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/shared/providers/language_provider.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/shared/widgets/widgets.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/icons/app_icons.dart';

class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTokens.scaffoldBackground(context),
      body: Column(
        children: [
          PrimaryHeader(title: l10n.languageTitle, showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppDimens.p16),
              children: [
                // 跟随系统
                _LanguageOption(
                  title: l10n.languageSystemDefault,
                  locale: null,
                  currentLanguage: currentLanguage,
                  onTap: () {
                    ref.read(languageProvider.notifier).setLanguage(null);
                  },
                ),
                const SizedBox(height: AppDimens.p8),

                // 简体中文
                _LanguageOption(
                  title: l10n.languageChinese,
                  locale: const Locale('zh'),
                  currentLanguage: currentLanguage,
                  onTap: () {
                    ref
                        .read(languageProvider.notifier)
                        .setLanguage(const Locale('zh'));
                  },
                ),
                const SizedBox(height: AppDimens.p8),

                // 繁體中文
                _LanguageOption(
                  title: '繁體中文',
                  locale: const Locale('zh', 'TW'),
                  currentLanguage: currentLanguage,
                  onTap: () {
                    ref
                        .read(languageProvider.notifier)
                        .setLanguage(const Locale('zh', 'TW'));
                  },
                ),
                const SizedBox(height: AppDimens.p8),

                // 英语
                _LanguageOption(
                  title: l10n.languageEnglish,
                  locale: const Locale('en'),
                  currentLanguage: currentLanguage,
                  onTap: () {
                    ref
                        .read(languageProvider.notifier)
                        .setLanguage(const Locale('en'));
                  },
                ),
                const SizedBox(height: AppDimens.p8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final Locale? locale;
  final Locale? currentLanguage;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.locale,
    required this.currentLanguage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected =
        (locale == null && currentLanguage == null) ||
        (locale != null &&
            currentLanguage != null &&
            locale!.languageCode == currentLanguage!.languageCode &&
            locale!.countryCode == currentLanguage!.countryCode);

    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: AppTokens.textPrimary(context),
        ),
      ),
      trailing: isSelected
          ? Icon(
              AppIcons.checkCircle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}
