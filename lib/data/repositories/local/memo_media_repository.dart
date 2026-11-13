import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' as d;

import '../../../core/logging/logger_service.dart';
import '../../db.dart';
import '../../mappers/memo_mapper.dart';
import '../../models/memo_media_item.dart';

/// 图片格式只由字节签名判断，文件名和客户端声明不可信。
String? memoMediaMimeOf(Uint8List bytes) {
  bool startsWith(List<int> signature) =>
      bytes.length >= signature.length &&
      Iterable<int>.generate(
        signature.length,
      ).every((index) => bytes[index] == signature[index]);
  if (startsWith(const [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])) {
    return 'image/png';
  }
  if (startsWith(const [0xff, 0xd8, 0xff])) return 'image/jpeg';
  if (bytes.length >= 12 &&
      ascii.decode(bytes.sublist(0, 4), allowInvalid: true) == 'RIFF' &&
      ascii.decode(bytes.sublist(8, 12), allowInvalid: true) == 'WEBP') {
    return 'image/webp';
  }
  return null;
}

/// 服务端与本地共用的内容摘要。
String memoMediaSha256(Uint8List bytes) => sha256.convert(bytes).toString();

/// 备忘录图片的本地存储：字节随数据库快照一起备份，账号域决定清理范围。
class MemoMediaRepository {
  MemoMediaRepository(this.db);

  final SesameDatabase db;

  /// 写入图片并返回落库结果；同一标识重复写入按幂等覆盖同一份字节。
  Future<MemoMediaItem> upsert({
    required String id,
    required String? entryId,
    required String? scopeAccountId,
    required String mime,
    required Uint8List bytes,
    required String sha256,
    required String uploadState,
  }) async {
    try {
      final createdAt = DateTime.now().toUtc();
      await db
          .into(db.memoMedia)
          .insertOnConflictUpdate(
            MemoMediaCompanion.insert(
              id: id,
              scopeAccountId: d.Value(scopeAccountId),
              entryId: d.Value(entryId),
              mime: mime,
              byteSize: bytes.length,
              sha256: sha256,
              bytes: bytes,
              uploadState: uploadState,
              createdAt: createdAt,
            ),
          );
      return MemoMediaItem(
        id: id,
        entryId: entryId,
        mime: mime,
        bytes: bytes,
        sha256: sha256,
        uploadState: uploadState,
        createdAt: createdAt,
      );
    } catch (error, stackTrace) {
      logger.error('MemoMedia', '保存备忘录图片失败', error, stackTrace);
      rethrow;
    }
  }

  Future<MemoMediaItem?> byId(String id) async {
    final row = await (db.select(
      db.memoMedia,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    return _item(row);
  }

  /// 更新上传状态；行已被删除时按已结束处理。
  Future<void> setUploadState(String id, String state) async {
    await (db.update(db.memoMedia)..where((row) => row.id.equals(id))).write(
      MemoMediaCompanion(uploadState: d.Value(state)),
    );
  }

  /// 打开笔记时补投未完成的云端图片，已确认或本机图片不重复上传。
  Future<List<MemoMediaItem>> pendingUploads(String entryId) async {
    final rows =
        await (db.select(db.memoMedia)..where(
              (row) =>
                  row.entryId.equals(entryId) &
                  row.uploadState.isIn(const ['pending', 'failed']),
            ))
            .get();
    return rows.map(_item).whereType<MemoMediaItem>().toList();
  }

  /// 笔记正文不再引用且超过宽限期的图片才回收；仍被其他笔记引用时保留。
  Future<void> cleanupForEntry(String entryId, Set<String> referenced) async {
    try {
      final cutoff = DateTime.now()
          .toUtc()
          .subtract(const Duration(days: 1))
          .millisecondsSinceEpoch;
      final rows =
          await (db.select(db.memoMedia)..where(
                (row) =>
                    row.entryId.equals(entryId) &
                    row.createdAt.isSmallerThanValue(cutoff),
              ))
              .get();
      for (final row in rows) {
        if (referenced.contains(row.id)) continue;
        if (await _referencedAnywhere(row.id)) continue;
        await (db.delete(
          db.memoMedia,
        )..where((candidate) => candidate.id.equals(row.id))).go();
      }
    } catch (error, stackTrace) {
      logger.error('MemoMedia', '清理未引用图片失败', error, stackTrace);
    }
  }

  /// 按正文引用扫描其他笔记，避免删除仍被冲突副本或复制本使用的图片。
  Future<bool> _referencedAnywhere(String id) async {
    final rows = await db
        .customSelect(
          'SELECT 1 AS found FROM memo_entries WHERE body LIKE ? LIMIT 1',
          variables: [d.Variable("%$id%")],
        )
        .get();
    return rows.isNotEmpty;
  }

  MemoMediaItem? _item(MemoMediaRow? row) =>
      row == null ? null : memoMediaFromRow(row);
}
