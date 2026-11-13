import 'dart:typed_data';

/// 备忘录内联图片的本地副本；字节与上传状态由媒体仓储维护。
class MemoMediaItem {
  final String id;
  final String? entryId;
  final String mime;
  final Uint8List bytes;
  final String sha256;
  final String uploadState;
  final DateTime createdAt;

  const MemoMediaItem({
    required this.id,
    required this.entryId,
    required this.mime,
    required this.bytes,
    required this.sha256,
    required this.uploadState,
    required this.createdAt,
  });

  /// 图片已在本机可用（本机本）或已上传（云端本可由任意设备获取）。
  bool get isAvailable => uploadState == 'local' || uploadState == 'uploaded';
}
