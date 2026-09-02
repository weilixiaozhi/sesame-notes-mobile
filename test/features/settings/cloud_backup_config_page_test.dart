/// 第三方备份配置表单页测试。
///
/// 需求锚点：表单字段完全来自 application 展示模型，本页不枚举后端；必填
/// 缺失提示不落库；保存成功经 CloudServiceStore 持久化并激活该后端；已有
/// 配置回填表单；凭据字段不落 SharedPreferences。
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_notes/features/settings/application/cloud_backup_actions.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/features/settings/presentation/cloud_backup_config_page.dart';

/// 测试后端：字段覆盖文本 / 密码 / 数字 / 开关四类。
final _testBackend = CloudBackend(
  id: 'testcloud',
  displayName: 'TestCloud',
  fields: const [
    CloudConfigField(
      key: 'url',
      labelKey: 'cloudBackupUrlLabel',
      isRequired: true,
    ),
    CloudConfigField(
      key: 'token',
      labelKey: 'cloudBackupSecretKeyLabel',
      kind: CloudConfigFieldKind.secret,
      isRequired: true,
    ),
    CloudConfigField(key: 'bucket', labelKey: 'cloudBackupBucketLabel'),
    CloudConfigField(
      key: 'port',
      labelKey: 'cloudBackupPortLabel',
      kind: CloudConfigFieldKind.number,
    ),
    CloudConfigField(
      key: 'useSSL',
      labelKey: 'cloudBackupSslLabel',
      kind: CloudConfigFieldKind.boolean,
      defaultValue: true,
    ),
  ],
  importLegacy: (json) => {
    'url': json['testUrl'],
    'token': json['testToken'],
    'bucket': json['testBucket'],
    'port': json['testPort'],
    'useSSL': json['testUseSSL'],
  },
);

/// 页面只消费 application 层的不可变字段模型。
const _testBackendDisplay = CloudBackupBackendDisplay(
  id: 'testcloud',
  displayName: 'TestCloud',
  fields: [
    CloudBackupFieldDisplay(
      key: 'url',
      labelKey: 'cloudBackupUrlLabel',
      type: CloudBackupFieldType.text,
      defaultValue: null,
    ),
    CloudBackupFieldDisplay(
      key: 'token',
      labelKey: 'cloudBackupSecretKeyLabel',
      type: CloudBackupFieldType.secret,
      defaultValue: null,
    ),
    CloudBackupFieldDisplay(
      key: 'bucket',
      labelKey: 'cloudBackupBucketLabel',
      type: CloudBackupFieldType.text,
      defaultValue: null,
    ),
    CloudBackupFieldDisplay(
      key: 'port',
      labelKey: 'cloudBackupPortLabel',
      type: CloudBackupFieldType.number,
      defaultValue: null,
    ),
    CloudBackupFieldDisplay(
      key: 'useSSL',
      labelKey: 'cloudBackupSslLabel',
      type: CloudBackupFieldType.boolean,
      defaultValue: true,
    ),
  ],
  isConfigured: false,
  isActive: false,
  lastSuccessAt: null,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    CloudProviderRegistry.register(
      _testBackend,
      (config) async =>
          (provider: _FakeCloudProvider(success: true), auth: null),
    );
  });

  tearDown(() => CloudProviderRegistry.unregister(_testBackend.id));

  Future<AppLocalizations> pump(WidgetTester tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProviderScope(
          child: CloudBackupConfigPage(backend: _testBackendDisplay),
        ),
      ),
    );
    await tester.pump();
    return l10n;
  }

  /// 按 label 填字段。
  Future<void> fill(WidgetTester tester, String label, String value) async {
    await tester.enterText(find.widgetWithText(TextFormField, label), value);
  }

  testWidgets('按后端描述符渲染全部字段（含开关与数字）', (tester) async {
    final l10n = await pump(tester);

    expect(
      find.widgetWithText(TextFormField, l10n.cloudBackupUrlLabel),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextFormField, l10n.cloudBackupSecretKeyLabel),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextFormField, l10n.cloudBackupBucketLabel),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(TextFormField, l10n.cloudBackupPortLabel),
      findsOneWidget,
    );
    expect(find.text(l10n.cloudBackupSslLabel), findsOneWidget);
  });

  testWidgets('保存即激活该后端', (tester) async {
    final l10n = await pump(tester);

    await fill(tester, l10n.cloudBackupUrlLabel, 'https://cloud.example.com');
    await fill(tester, l10n.cloudBackupSecretKeyLabel, 'tk-1');
    await fill(tester, l10n.cloudBackupBucketLabel, 'my-bucket');
    await tester.tap(find.text(l10n.cloudBackupSave));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final sp = await SharedPreferences.getInstance();
    expect(
      sp.getString(CloudServiceStore.configKeyFor(_testBackend.id)),
      isNotNull,
      reason: '配置必须落盘',
    );
    expect(
      sp.getString(CloudServiceStore.activeTypeKey),
      _testBackend.id,
      reason: '保存后激活该后端',
    );
    await tester.pump(const Duration(seconds: 2)); // 消化 toast timer
  });

  testWidgets('凭据字段不落 SharedPreferences', (tester) async {
    final l10n = await pump(tester);

    await fill(tester, l10n.cloudBackupUrlLabel, 'https://cloud.example.com');
    await fill(tester, l10n.cloudBackupSecretKeyLabel, 'super-secret-token');
    await tester.tap(find.text(l10n.cloudBackupSave));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final sp = await SharedPreferences.getInstance();
    expect(
      sp.getString(CloudServiceStore.configKeyFor(_testBackend.id)),
      isNot(contains('super-secret-token')),
      reason: '凭据字段必须进安全存储，不得明文落盘',
    );
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('必填缺失：提示且不落库', (tester) async {
    final l10n = await pump(tester);

    await fill(tester, l10n.cloudBackupUrlLabel, 'https://cloud.example.com');
    await tester.tap(find.text(l10n.cloudBackupSave));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.cloudBackupRequired), findsOneWidget);
    final sp = await SharedPreferences.getInstance();
    expect(
      sp.getString(CloudServiceStore.configKeyFor(_testBackend.id)),
      isNull,
      reason: '必填缺失不得落库',
    );
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('已有配置回填表单（含旧版扁平配置迁移）', (tester) async {
    SharedPreferences.setMockInitialValues({
      CloudServiceStore.activeTypeKey: _testBackend.id,
      CloudServiceStore.legacyConfigKeyFor(
        _testBackend.id,
      ): '{"type":"testcloud","testUrl":"https://old.example.com","testToken":"old-token","testPort":9000,"testUseSSL":false}',
    });
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const ProviderScope(
          child: CloudBackupConfigPage(backend: _testBackendDisplay),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('https://old.example.com'),
      findsOneWidget,
      reason: '旧版配置应迁移后回填',
    );
    expect(find.text('9000'), findsOneWidget, reason: '数字字段应回填');
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('测试连接：连通成功提示', (tester) async {
    final l10n = await pump(tester);
    await fill(tester, l10n.cloudBackupUrlLabel, 'https://cloud.example.com');
    await fill(tester, l10n.cloudBackupSecretKeyLabel, 'tk-1');
    await tester.tap(find.text(l10n.cloudBackupTestConnection));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text(l10n.cloudBackupTestOk),
      findsOneWidget,
      reason: '连通成功必须提示',
    );
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('测试连接：失败提示且不落库', (tester) async {
    CloudProviderRegistry.register(
      _testBackend,
      (config) async =>
          (provider: _FakeCloudProvider(success: false), auth: null),
    );

    final l10n = await pump(tester);
    await fill(tester, l10n.cloudBackupUrlLabel, 'https://cloud.example.com');
    await fill(tester, l10n.cloudBackupSecretKeyLabel, 'tk-1');
    await tester.tap(find.text(l10n.cloudBackupTestConnection));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(l10n.cloudBackupTestFailed), findsOneWidget);
    final sp = await SharedPreferences.getInstance();
    expect(
      sp.getString(CloudServiceStore.configKeyFor(_testBackend.id)),
      isNull,
      reason: '测试连接不落库',
    );
    await tester.pump(const Duration(seconds: 2));
  });
}

/// 测试用 fake provider：storage.list 按 [success] 决定成败。
class _FakeCloudProvider implements CloudProvider {
  final bool success;

  _FakeCloudProvider({required this.success});

  @override
  String get providerId => 'fake';

  @override
  String get providerName => 'Fake';

  @override
  CloudAuthService get auth => throw UnimplementedError();

  @override
  Future<void> initialize(Map<String, dynamic> config) async {}

  @override
  bool validateConfig(Map<String, dynamic> config) => true;

  @override
  Future<void> dispose() async {}

  @override
  CloudStorageService get storage => _FakeStorage(success);
}

class _FakeStorage implements CloudStorageService {
  final bool success;

  _FakeStorage(this.success);

  @override
  Future<List<CloudFile>> list({required String path}) async {
    if (!success) throw CloudSyncException('connection refused');
    return const [];
  }

  @override
  Future<void> upload({
    required String path,
    required String data,
    Map<String, String>? metadata,
  }) async {}
  @override
  Future<String?> download({required String path}) async => null;
  @override
  Future<void> delete({required String path}) async {}
  @override
  Future<bool> exists({required String path}) async => false;
  @override
  Future<CloudFile?> getMetadata({required String path}) async => null;
}
