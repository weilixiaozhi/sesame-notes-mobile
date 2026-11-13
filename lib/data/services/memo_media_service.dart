import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../core/logging/logger_service.dart';
import '../../infrastructure/media/memo_media_api.dart';
import '../models/memo_delta.dart';
import '../models/memo_media_item.dart';
import '../repositories/local/memo_media_repository.dart';

/// 备忘录图片编排：选择后的落库、云端上传、按需下载与孤儿回收。
///
/// 本机本的图片只有本地一份；云端本以服务端为权威，本地副本用于离线渲染。
class MemoMediaService {
  MemoMediaService({
    required this.repository,
    required this.api,
    required this.accountId,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final MemoMediaRepository repository;
  final MemoMediaApi api;
  final String? Function() accountId;
  final Uuid _uuid;
  final Map<String, Future<Uint8List?>> _loading = {};
  final Set<String> _attempted = {};

  /// 当前账号域；未登录时只能处理本机图片。
  String? get _account => accountId();

  bool get _cloudReady => api.configured && _account != null;

  /// 将选中的图片写入本机并异步上传；返回正文需要引用的图片标识。
  ///
  /// 只有云端本才把字节登记到账号域并上传，本机本的图片始终只属于本机。
  Future<MemoMediaItem> add({
    required String entryId,
    required Uint8List bytes,
    String? mime,
    bool cloud = false,
  }) async {
    final mediaMime = mime ?? memoMediaMimeOf(bytes);
    if (mediaMime == null) throw const FormatException('MEMO_MEDIA_FORMAT');
    final account = _account;
    final scope = cloud && account != null ? account : null;
    final id = _uuid.v4();
    final item = await repository.upsert(
      id: id,
      entryId: entryId,
      scopeAccountId: scope,
      mime: mediaMime,
      bytes: bytes,
      sha256: memoMediaSha256(bytes),
      uploadState: scope == null ? 'local' : 'pending',
    );
    if (scope != null) unawaited(upload(id));
    return item;
  }

  /// 上传单张云端图片；同一失败在本次会话只重试一次，避免反复请求。
  Future<void> upload(String id) async {
    final row = await repository.byId(id);
    if (row == null || row.uploadState == 'uploaded') return;
    if (row.uploadState == 'local' || !_cloudReady) return;
    if (row.uploadState == 'failed' && !_attempted.add(id)) return;
    try {
      await api.upload(id: id, mime: row.mime, bytes: row.bytes);
      await repository.setUploadState(id, 'uploaded');
    } catch (error, stackTrace) {
      await repository.setUploadState(id, 'failed');
      logger.error(
        'MemoMedia',
        '备忘录图片上传失败，稍后重试',
        safeErrorSummary(error),
        stackTrace,
      );
    }
  }

  /// 读取图片字节：本机优先，缺失的云端图片按需下载并缓存。
  Future<Uint8List?> bytesOf(String id) {
    final pending = _loading[id];
    if (pending != null) return pending;
    final future = _load(id);
    _loading[id] = future;
    future.whenComplete(() => _loading.remove(id));
    return future;
  }

  Future<Uint8List?> _load(String id) async {
    final row = await repository.byId(id);
    if (row != null) return row.bytes;
    if (!_cloudReady) return null;
    try {
      final bytes = await api.download(id);
      if (bytes == null) return null;
      final mime = memoMediaMimeOf(bytes);
      if (mime == null) return null;
      await repository.upsert(
        id: id,
        entryId: null,
        scopeAccountId: _account,
        mime: mime,
        bytes: bytes,
        sha256: memoMediaSha256(bytes),
        uploadState: 'uploaded',
      );
      return bytes;
    } catch (error, stackTrace) {
      logger.error(
        'MemoMedia',
        '备忘录图片下载失败，保留占位',
        safeErrorSummary(error),
        stackTrace,
      );
      return null;
    }
  }

  /// 打开笔记时补齐正文引用的图片并补投未完成的上传。
  Future<void> prepareEntry(String entryId, String? bodyJson) async {
    try {
      final referenced = <String>{};
      if (bodyJson != null) {
        final body = jsonDecode(bodyJson);
        if (body is Map && body['ops'] is List) {
          for (final op in body['ops'] as List) {
            final id = memoImageIdOf(op);
            if (id != null) referenced.add(id);
          }
        }
      }
      for (final id in referenced) {
        unawaited(bytesOf(id));
      }
      for (final pending in await repository.pendingUploads(entryId)) {
        unawaited(upload(pending.id));
      }
    } catch (error, stackTrace) {
      logger.error(
        'MemoMedia',
        '准备备忘录图片失败',
        safeErrorSummary(error),
        stackTrace,
      );
    }
  }

  /// 保存后回收该笔记不再引用的本地图片。
  Future<void> cleanupAfterSave(String entryId, String bodyJson) async {
    try {
      final referenced = <String>{};
      final body = jsonDecode(bodyJson);
      if (body is Map && body['ops'] is List) {
        for (final op in body['ops'] as List) {
          final id = memoImageIdOf(op);
          if (id != null) referenced.add(id);
        }
      }
      await repository.cleanupForEntry(entryId, referenced);
    } catch (error, stackTrace) {
      logger.error(
        'MemoMedia',
        '回收备忘录图片失败',
        safeErrorSummary(error),
        stackTrace,
      );
    }
  }
}
