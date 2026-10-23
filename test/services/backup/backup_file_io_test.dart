import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/settings/domain/backup_manifest.dart';
import 'package:sesame_notes/features/settings/infrastructure/backup_file_io.dart';

void main() {
  late Directory dir;
  setUp(() async {
    dir = await Directory('Temp').createTemp('backup-file-io-');
  });
  tearDown(() async {
    await dir.delete(recursive: true);
  });
  test('流式写入与 v1 黄金帧一致，提取不修改原件', () async {
    final manifest = Uint8List.fromList(utf8.encode('{"name":"备份😀"}'));
    final data = Uint8List.fromList(List.generate(1024 * 1024, (i) => i % 256));
    final sqlite = await File('${dir.path}/source.sqlite').writeAsBytes(data);
    final chunks = await backupFileChunks(manifest, sqlite).toList();
    expect(chunks.length, greaterThan(3));
    expect(chunks.every((c) => c.length < data.length), isTrue);
    final bytes = Uint8List.fromList(chunks.expand((c) => c).toList());
    expect(bytes, BackupPayloadCodec.encode(manifest, data));
    final file = await File('${dir.path}/backup.snbak').writeAsBytes(bytes);
    final frame = await readBackupFileFrame(file);
    expect(frame.manifestJson, manifest);
    expect(frame.sqliteLength, data.length);
    final destination = File('${dir.path}/restored.sqlite');
    await extractBackupSqlite(file, destination, frame);
    expect(await destination.readAsBytes(), data);
    expect(await file.readAsBytes(), bytes);
    await expectLater(
      extractBackupSqlite(file, destination, frame),
      throwsA(isA<FileSystemException>()),
    );
    expect(await destination.readAsBytes(), data);
  });
  test('损坏长度和超大清单在分配或提取前拒绝', () async {
    final file = await File('${dir.path}/bad.snbak').writeAsBytes([1, 2, 3]);
    await expectLater(
      readBackupFileFrame(file),
      throwsA(isA<BackupFormatException>()),
    );
    final header = ByteData(8)
      ..setUint32(0, maxBackupManifestBytes + 1)
      ..setUint32(4, 0);
    final handle = await file.open(mode: FileMode.write);
    await handle.writeFrom(header.buffer.asUint8List());
    await handle.truncate(8 + maxBackupManifestBytes + 1);
    await handle.close();
    await expectLater(
      readBackupFileFrame(file),
      throwsA(
        isA<BackupFormatException>().having(
          (e) => e.reason,
          'reason',
          BackupOpenError.invalidManifest,
        ),
      ),
    );
  });
  test('预览后的源文件截断，提取失败清理半成品', () async {
    final file = await File('${dir.path}/backup.snbak').writeAsBytes(
      BackupPayloadCodec.encode(
        Uint8List.fromList([123, 125]),
        Uint8List(1024),
      ),
    );
    final frame = await readBackupFileFrame(file);
    final handle = await file.open(mode: FileMode.append);
    await handle.truncate(100);
    await handle.close();
    final destination = File('${dir.path}/partial.sqlite');
    await expectLater(
      extractBackupSqlite(file, destination, frame),
      throwsA(isA<BackupFormatException>()),
    );
    expect(await destination.exists(), isFalse);
    expect(await file.length(), 100);
  });
}
