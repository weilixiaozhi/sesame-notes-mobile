import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

/// 测试准备复用产品保存及激活入口，禁止将无效配置当作已连接状态。
Future<void> activateTestCloudConfig(
  CloudServiceStore store,
  CloudServiceConfig config,
) async {
  try {
    await store.saveOnly(config);
    if (!await store.activate(config.backendId)) {
      throw StateError('测试云备份配置不完整：${config.backendId}');
    }
  } catch (error, stack) {
    Error.throwWithStackTrace(error, stack);
  }
}
