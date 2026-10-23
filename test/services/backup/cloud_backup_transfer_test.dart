import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_cloud_backup/sesame_cloud_backup.dart';
import 'package:sesame_notes/infrastructure/backup/cloud_backup_transfer.dart';

/// 使用文件流完成真正传输，存储层直接实现统一文件接口。
class _FileStorage extends Fake implements CloudStorageService {
  /// 本地文件模拟隔离的远程对象，保留条件创建语义。
  _FileStorage(this.remote);
  final File remote;
  Map<String, String>? uploadedMetadata;

  /// 同名对象必须拒绝覆盖，正文使用流写入测试远端文件。
  @override
  Future<void> uploadFile({
    required String path,
    required File file,
    Map<String, String>? metadata,
  }) async {
    if (await remote.exists()) throw const CloudFileAlreadyExistsException();
    uploadedMetadata = metadata;
    final sink = remote.openWrite();
    try {
      await sink.addStream(file.openRead());
    } finally {
      await sink.close();
    }
  }

  /// 缺失对象返回 false，存在时通过真实文件复制传给解码流程。
  @override
  Future<bool> downloadFile({
    required String path,
    required File destination,
  }) async {
    if (!await remote.exists()) return false;
    await remote.copy(destination.path);
    return true;
  }
}

/// 验证跨分块 Base64 编解码保持旧协议字节，并清理临时中间文件。
void main() {
  test('大文件上传下载逐块编码并保留原始字节', () async {
    final dir = await Directory('Temp').createTemp('stream-backup-');
    try {
      final source = File('${dir.path}/source.snbak');
      final sink = source.openWrite();
      try {
        for (var i = 0; i < 129; i++) {
          sink.add(List.generate(8191, (j) => (i + j) % 256));
        }
      } finally {
        await sink.close();
      }
      final remote = File('${dir.path}/remote');
      final storage = _FileStorage(remote);
      await uploadBackupSnapshot(storage, source, 'backup');
      expect(storage.uploadedMetadata, {
        'app': 'sesame_notes',
        'format': 'snbak',
        'encoding': 'base64',
      });
      final output = File('${dir.path}/restored.snbak');
      expect(await downloadBackupSnapshot(storage, 'backup', output), isTrue);
      expect(await output.readAsBytes(), await source.readAsBytes());
      expect(
        base64Decode(await remote.readAsString()),
        await source.readAsBytes(),
      );
      final originalRemote = await remote.readAsBytes();
      await expectLater(
        uploadBackupSnapshot(storage, source, 'backup'),
        throwsA(isA<CloudFileAlreadyExistsException>()),
      );
      expect(await remote.readAsBytes(), originalRemote, reason: '同名备份不得被覆盖');
      expect(dir.listSync().whereType<Directory>(), isEmpty);
      expect(await File('${output.path}.encoded').exists(), isFalse);
      await remote.writeAsString('bad!base64');
      await expectLater(
        downloadBackupSnapshot(storage, 'backup', output),
        throwsFormatException,
      );
      expect(await output.exists(), isFalse);
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('缺失对象返回 false，身份失效不上传并清理编码中间文件', () async {
    final dir = await Directory('Temp').createTemp('stream-backup-boundary-');
    try {
      final source = File('${dir.path}/source.snbak');
      await source.writeAsBytes([0, 1, 2, 255]);
      final remote = File('${dir.path}/remote');
      final storage = _FileStorage(remote);
      final output = File('${dir.path}/restored.snbak');
      expect(await downloadBackupSnapshot(storage, 'missing', output), isFalse);
      expect(await output.exists(), isFalse);
      expect(await File('${output.path}.encoded').exists(), isFalse);
      await expectLater(
        uploadBackupSnapshot(storage, source, 'backup', isCurrent: () => false),
        throwsStateError,
      );
      expect(await remote.exists(), isFalse);
      expect(dir.listSync().whereType<Directory>(), isEmpty);
    } finally {
      await dir.delete(recursive: true);
    }
  });
}
