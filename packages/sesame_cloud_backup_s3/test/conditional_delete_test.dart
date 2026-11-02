import 'package:sesame_cloud_backup_s3/src/s3_client.dart';
import 'package:sesame_cloud_backup_s3/src/s3_storage_service.dart';

import '../../sesame_cloud_backup/test/utils/conditional_delete_contract.dart';

/// S3 条件请求经过真实 SigV4 与 XML 解析验证，不访问远端存储。
void main() {
  conditionalDeleteContract(
    webDav: false,
    createStorage: (endpoint) => S3StorageService(
      S3Client(
          endpoint: endpoint.host,
          port: endpoint.port,
          useSSL: false,
          region: 'test',
          accessKey: 'test',
          secretKey: 'test'),
      'bucket',
    ),
    closeStorage: (storage) => (storage as S3StorageService).client.dispose(),
  );
}
