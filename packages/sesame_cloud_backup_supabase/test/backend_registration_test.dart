/// Supabase 后端的敏感字段和必要配置约束。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_supabase/sesame_cloud_backup_supabase.dart';

void main() {
  setUp(registerSupabaseBackend);
  tearDown(() => CloudProviderRegistry.unregister('supabase'));

  test('认证密钥和密码必须进入安全存储', () {
    final backend = CloudProviderRegistry.backendOf('supabase');

    expect(backend, isNotNull);
    expect(
      backend!.fields.where((f) => f.isSecret).map((f) => f.key),
      ['anonKey', 'password'],
      reason: 'anonKey 与 password 属凭据，必须进安全存储',
    );
  });

  test('必填项缺失时配置判定为不可用', () {
    expect(
      CloudProviderRegistry.isConfigValid(
        const CloudServiceConfig(
          backendId: 'supabase',
          settings: {'url': 'https://x.supabase.co'},
        ),
      ),
      isFalse,
    );
  });
}
