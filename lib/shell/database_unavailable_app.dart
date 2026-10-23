import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/theme/app_theme.dart';
import 'package:sesame_notes/theme/colors.dart';
import 'package:sesame_notes/theme/dimens.dart';
import 'package:sesame_notes/theme/typography.dart';

/// 数据库无法安全打开时使用独立界面，不挂载任何业务或同步 Provider。
class DatabaseUnavailableApp extends StatelessWidget {
  const DatabaseUnavailableApp({super.key, this.locale});
  final Locale? locale;

  /// 使用既有主题与本地化，在无可用数据库时也能稳定呈现恢复说明。
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.lightTheme(),
    darkTheme: AppTheme.darkTheme(),
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          backgroundColor: AppTokens.scaffoldBackground(context),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimens.p16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.startupDatabaseTitle,
                      style: AppTextTokens.strongTitle(context),
                    ),
                    const SizedBox(height: AppDimens.p16),
                    Text(
                      l10n.startupDatabaseMessage,
                      style: AppTextTokens.body(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}
