/// 测试辅助：注册真实云备份 adapter（等价于 main.dart 的 Composition Root）。
///
/// 云服务页的第三方备份入口来自注册表，测试必须显式注册后端才能渲染入口，
/// 因此把三步注册收敛到本文件，避免各测试重复 import adapter 包。
library;

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_cloud_backup_s3/sesame_cloud_backup_s3.dart';
import 'package:sesame_cloud_backup_supabase/sesame_cloud_backup_supabase.dart';
import 'package:sesame_cloud_backup_webdav/sesame_cloud_backup_webdav.dart';

/// 三个真实后端的 ID，与 adapter 自注册时提交的 [CloudBackend.id] 一致。
const realCloudBackendIds = ['supabase', 'webdav', 's3'];

/// 注册全部真实后端，返回注销函数（tearDown 用）。
void Function() registerRealCloudBackends() {
  registerSupabaseBackend();
  registerWebDavBackend();
  registerS3Backend();
  return () {
    for (final id in realCloudBackendIds) {
      CloudProviderRegistry.unregister(id);
    }
  };
}
