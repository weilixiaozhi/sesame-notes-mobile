import 'package:sesame_cloud_backup_webdav/src/webdav_storage_service.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import '../../sesame_cloud_backup/test/utils/conditional_delete_contract.dart';

/// WebDAV 条件请求穿过现有认证和流式文件通道，不访问远端存储。
void main() {
  conditionalDeleteContract(
    webDav: true,
    createStorage: (endpoint) => WebDAVStorageService(
      webdav.newClient(endpoint.toString(), user: 'test', password: 'test'),
      '/root/',
    ),
    closeStorage: (_) {},
  );
}
