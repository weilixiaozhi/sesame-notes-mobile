import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/settings/application/cloud_backup_actions.dart';
import 'package:sesame_notes/features/settings/presentation/cloud_backend_config_dialog.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/shared/widgets/app_sheet.dart';

/// 凭据的首尾空格属于输入原文，保存配置不能静默改变认证材料。
void main() {
  testWidgets('配置弹窗只修整普通字段，密码原样返回', (tester) async {
    Map<String, dynamic>? saved;
    const backend = CloudBackupBackendDisplay(
      id: 'webdav',
      displayName: 'WebDAV',
      fields: [
        CloudBackupFieldDisplay(
          key: 'username',
          labelKey: 'cloudBackupUsernameLabel',
          type: CloudBackupFieldType.text,
          defaultValue: null,
          isRequired: true,
        ),
        CloudBackupFieldDisplay(
          key: 'password',
          labelKey: 'cloudBackupPasswordLabel',
          type: CloudBackupFieldType.secret,
          defaultValue: null,
          isRequired: true,
        ),
      ],
      isConfigured: false,
      isActive: false,
      lastSuccessAt: null,
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                saved = await showAppSheetTop<Map<String, dynamic>>(
                  context: context,
                  child: const CloudBackendConfigDialog(backend: backend),
                );
              },
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '  account  ');
    await tester.enterText(
      find.byType(TextField).at(1),
      '  password with spaces  ',
    );
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(saved, {
      'username': 'account',
      'password': '  password with spaces  ',
    });
  });
}
