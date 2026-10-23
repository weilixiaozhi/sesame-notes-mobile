import 'dart:io';
import 'dart:typed_data';
import '../domain/backup_manifest.dart';

// 清单只有本子元数据，先限制声明长度，避免损坏帧诱发巨量分配。
const maxBackupManifestBytes = 16 * 1024 * 1024;
typedef BackupFileFrame = ({
  Uint8List manifestJson,
  int sqliteOffset,
  int sqliteLength,
});

Future<BackupFileFrame> readBackupFileFrame(File source) async {
  final file = await source.open();
  try {
    final header = await file.read(8);
    if (header.length != 8) {
      throw const BackupFormatException(BackupOpenError.corrupt, '载荷帧过短');
    }
    final fields = ByteData.sublistView(header);
    final manifestLength = fields.getUint32(0),
        sqliteLength = fields.getUint32(4);
    if (8 + manifestLength + sqliteLength != await file.length()) {
      throw const BackupFormatException(BackupOpenError.corrupt, '载荷帧长度字段损坏');
    }
    if (manifestLength > maxBackupManifestBytes) {
      throw const BackupFormatException(
        BackupOpenError.invalidManifest,
        '备份清单超过处理上限',
      );
    }
    final manifest = await file.read(manifestLength);
    if (manifest.length != manifestLength) {
      throw const BackupFormatException(BackupOpenError.corrupt, '清单被截断');
    }
    return (
      manifestJson: manifest,
      sqliteOffset: 8 + manifestLength,
      sqliteLength: sqliteLength,
    );
  } finally {
    await file.close();
  }
}

/// 保持 v1 分帧字节完全一致，SQLite 体按文件流发送，不分配整库缓冲。
Stream<List<int>> backupFileChunks(Uint8List manifest, File sqlite) async* {
  if (manifest.length > maxBackupManifestBytes) {
    throw const BackupFormatException(
      BackupOpenError.invalidManifest,
      '备份清单超过处理上限',
    );
  }
  final size = await sqlite.length();
  if (size > 0xffffffff) {
    throw const BackupFormatException(BackupOpenError.corrupt, '备份超过当前格式上限');
  }
  final header = ByteData(8)
    ..setUint32(0, manifest.length)
    ..setUint32(4, size);
  yield header.buffer.asUint8List();
  yield manifest;
  var copied = 0;
  await for (final chunk in sqlite.openRead()) {
    copied += chunk.length;
    yield chunk;
  }
  if (copied != size) {
    throw const BackupFormatException(BackupOpenError.corrupt, '备份快照在读取期间变化');
  }
}

/// 仅写调用方创建的隔离目标；失败清除半文件，原备份不修改。
Future<void> extractBackupSqlite(
  File source,
  File destination,
  BackupFileFrame frame,
) async {
  if (source.absolute.path == destination.absolute.path) {
    throw ArgumentError('隔离目标不能是原备份');
  }
  await destination.create(exclusive: true);
  try {
    final output = await destination.open(mode: FileMode.write);
    try {
      var copied = 0;
      await for (final chunk in source.openRead(
        frame.sqliteOffset,
        frame.sqliteOffset + frame.sqliteLength,
      )) {
        await output.writeFrom(chunk);
        copied += chunk.length;
      }
      if (copied != frame.sqliteLength ||
          await source.length() != frame.sqliteOffset + frame.sqliteLength) {
        throw const BackupFormatException(BackupOpenError.corrupt, '备份在读取期间变化');
      }
      await output.flush();
    } finally {
      await output.close();
    }
  } catch (_) {
    if (await destination.exists()) await destination.delete();
    rethrow;
  }
}
