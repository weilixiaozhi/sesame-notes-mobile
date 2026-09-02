/// 云连接测试服务（P2）。
///
/// 设计意图：备份配置保存前先做一次真实连通性探测——通过注册表构建对应
/// 后端 provider（builder 内部完成初始化），再对存储根路径做一次 list，
/// 能列出（含空列表）即视为连接成功；任何异常（配置错/网络不通/鉴权失败）
/// 统一向上抛，由 UI 层提示用户检查配置。
library;

import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

/// 云连接测试服务。
class CloudConnectionTester {
  CloudConnectionTester._();

  /// 探测 [config] 指向的后端连通性；失败抛异常（含 [CloudConfigurationException]）。
  static Future<void> test(CloudServiceConfig config) async {
    final services = await createCloudServices(config);
    final provider = services.provider;
    if (provider == null) {
      throw CloudConfigurationException('配置无效或后端未注册，无法测试连接');
    }
    try {
      // 根路径 list：空列表也代表连接成功（bucket/目录可达）。
      await provider.storage.list(path: '');
    } finally {
      await provider.dispose();
    }
  }
}
