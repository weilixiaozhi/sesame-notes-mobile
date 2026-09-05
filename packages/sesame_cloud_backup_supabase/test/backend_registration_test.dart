/// Supabase adapter 自注册契约测试。
///
/// 需求锚点：字段声明与旧版扁平配置的迁移规则归 adapter 所有，核心包不保存
/// 任何 Supabase 字段名；注册后核心即可按描述符存取配置。
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_supabase/sesame_cloud_backup_supabase.dart';

void main() {
  setUp(registerSupabaseBackend);
  tearDown(() => CloudProviderRegistry.unregister('supabase'));

  test('注册后核心可取得后端描述符', () {
    final backend = CloudProviderRegistry.backendOf('supabase');

    expect(backend, isNotNull);
    expect(backend!.displayName, 'Supabase');
    expect(
      backend.fields.map((f) => f.key),
      ['url', 'anonKey', 'bucket', 'account', 'password'],
    );
    expect(
      backend.fields.where((f) => f.isSecret).map((f) => f.key),
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

  test('旧版扁平配置迁移为新版 settings', () {
    final backend = CloudProviderRegistry.backendOf('supabase')!;

    expect(
      backend.importLegacy({
        'type': 'supabase',
        'name': 'Supabase',
        'supabaseUrl': 'https://x.supabase.co',
        'supabaseAnonKey': 'anon',
        'supabaseBucket': 'bkt',
        'supabaseEmail': 'a@b.com',
      }),
      {
        'url': 'https://x.supabase.co',
        'anonKey': 'anon',
        'bucket': 'bkt',
        'account': 'a@b.com',
      },
    );
  });
}
