import 'dart:convert';
import 'dart:io';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';

/// 将快照逐块编码为 Base64 隔离文件，再按条件创建上传。
Future<void> uploadBackupSnapshot(
  CloudStorageService storage,
  File source,
  String path, {
  bool Function()? isCurrent,
}) async {
  const metadata = {
    'app': 'sesame_notes',
    'format': 'snbak',
    'encoding': 'base64',
  };
  final directory = await source.parent.createTemp('.cloud-upload-');
  try {
    final encoded = File('${directory.path}/payload');
    await writeCloudFile(
      encoded,
      source.openRead().transform(base64.encoder).transform(utf8.encoder),
    );
    if (isCurrent != null && !isCurrent()) {
      throw StateError('BACKUP_SESSION_CHANGED');
    }
    await storage.uploadFile(path: path, file: encoded, metadata: metadata);
  } finally {
    await directory.delete(recursive: true);
  }
}

/// 云端 Base64 载荷逐块解码成快照，失败删除半文件。
Future<bool> downloadBackupSnapshot(
  CloudStorageService storage,
  String path,
  File destination,
) async {
  final encoded = File('${destination.path}.encoded');
  try {
    if (!await storage.downloadFile(path: path, destination: encoded)) {
      return false;
    }
    await writeCloudFile(
      destination,
      encoded.openRead().transform(utf8.decoder).transform(base64.decoder),
    );
    return true;
  } catch (_) {
    if (await destination.exists()) await destination.delete();
    rethrow;
  } finally {
    if (await encoded.exists()) await encoded.delete();
  }
}
