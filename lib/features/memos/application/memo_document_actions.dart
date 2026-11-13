import 'package:sesame_notes/data/models/private_book.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/memo.dart';
import '../../../data/models/memo_delta.dart';
import '../../../data/repositories/local/memo_media_repository.dart';
import '../../../shared/providers/memo_media_providers.dart';
import '../../../shared/providers/memo_repository_provider.dart';
import '../infrastructure/memo_document.dart';
import '../infrastructure/memo_document_style.dart';
import 'memo_providers.dart';
import '../infrastructure/memo_image.dart';
import '../../../core/logging/logger_service.dart';

export '../infrastructure/memo_image.dart' show MemoImageTooLarge;

enum MemoDocumentFormat { pdf, docx, md, png }

/// 一个任务固定本子、所选记录和完整正文，交付前验证快照仍然有效。
class MemoDocumentJob {
  final PrivateBookTarget target;
  final MemoEntry entry;
  final MemoBook book;
  final MemoDocumentFormat format;
  final int selectionGeneration;
  final List<MemoEntry> entries;
  final bool credentials;
  final String countLabel;
  bool cancelled = false;
  Directory? directory;
  MemoDocumentJob(
    this.target,
    this.book,
    this.entry,
    this.format,
    this.selectionGeneration, {
    List<MemoEntry>? entries,
    this.credentials = false,
    this.countLabel = '',
  }) : entries = List.unmodifiable(entries ?? [entry]);

  /// 清理失败只记录错误类型，不泄漏文件名或账号字段。
  Future<void> dispose() async {
    cancelled = true;
    final dir = directory;
    try {
      if (dir != null && await dir.exists()) await dir.delete(recursive: true);
      directory = null;
    } catch (error, stack) {
      logger.warning('MemoExport', '清理导出文件失败: ${error.runtimeType}', stack);
    }
  }
}

final memoDocumentActionsProvider = Provider<MemoDocumentActions>((ref) {
  final actions = MemoDocumentActions(ref);
  String? selected = ref.read(currentMemoBookIdProvider).value;
  ref.listen(currentMemoBookIdProvider, (_, next) {
    if (!next.hasValue) return;
    if (selected != next.value) actions.selectionGeneration++;
    selected = next.value;
  });
  String? credential = ref.read(currentCredentialBookIdProvider).value;
  ref.listen(currentCredentialBookIdProvider, (_, next) {
    if (!next.hasValue) return;
    if (credential != next.value) actions.credentialGeneration++;
    credential = next.value;
  });
  return actions;
});

class MemoDocumentActions {
  final Ref ref;
  int selectionGeneration = 0;
  int credentialGeneration = 0;
  MemoDocumentActions(this.ref);

  /// 按当前普通本捕获单篇已保存笔记。
  Future<MemoDocumentJob> capture(
    String entryId,
    MemoDocumentFormat format,
  ) async {
    final repository = ref.read(memoEntryRepositoryProvider);
    final selected = ref.read(currentMemoBookIdProvider).value;
    if (selected == null) throw StateError('MEMO_TARGET_CHANGED');
    final generation = selectionGeneration;
    return repository.runInTransaction(() async {
      final target = await repository.target(selected);
      final book = await repository.requireTarget(target);
      final entry = await repository.getEntry(entryId, target);
      if (entry == null) {
        throw StateError('MEMO_DOCUMENT_UNAVAILABLE');
      }
      final job = MemoDocumentJob(target, book, entry, format, generation);
      _checkSelection(job);
      return job;
    });
  }

  /// 在同一数据库快照中按本内顺序捕获勾选账号，缺失记录不得静默省略。
  Future<MemoDocumentJob> captureCredentials(
    String bookId,
    Set<String> ids,
    MemoDocumentFormat format, {
    required String countLabel,
  }) async {
    final selectedIds = Set<String>.of(ids);
    if (selectedIds.isEmpty ||
        ref.read(currentCredentialBookIdProvider).value != bookId) {
      throw StateError('MEMO_TARGET_CHANGED');
    }
    final generation = credentialGeneration;
    final repo = ref.read(memoEntryRepositoryProvider);
    return repo.runInTransaction(() async {
      final target = await repo.target(bookId);
      final book = await repo.requireTarget(target);
      if (book.type != memoBookTypeCredentials ||
          !book.isComplete ||
          book.isStale) {
        throw StateError('MEMO_DOCUMENT_UNAVAILABLE');
      }
      final entries = await repo.getEntriesByIds(selectedIds, target);
      if (entries.length != selectedIds.length) {
        throw StateError('MEMO_DOCUMENT_UNAVAILABLE');
      }
      final job = MemoDocumentJob(
        target,
        book,
        entries.first,
        format,
        generation,
        entries: entries,
        credentials: true,
        countLabel: countLabel,
      );
      _checkSelection(job);
      return job;
    });
  }

  /// 选择和取消状态在读取前后核对，跨越异步边界时不能交付旧任务。
  void _checkSelection(MemoDocumentJob job) {
    if (job.cancelled ||
        job.selectionGeneration !=
            (job.credentials ? credentialGeneration : selectionGeneration) ||
        (job.credentials
                ? ref.read(currentCredentialBookIdProvider).value
                : ref.read(currentMemoBookIdProvider).value) !=
            job.book.id) {
      throw StateError('MEMO_EXPORT_CANCELLED');
    }
  }

  /// 在同一数据库快照中批量验证所选内容和身份，任何变化都拒绝交付旧快照。
  Future<void> validate(MemoDocumentJob job) async {
    try {
      _checkSelection(job);
      final repo = ref.read(memoEntryRepositoryProvider);
      await repo.runInTransaction(() async {
        final book = await repo.requireTarget(job.target);
        if (!book.isComplete || book.isStale || book.name != job.book.name) {
          throw StateError('MEMO_EXPORT_VERSION_CHANGED');
        }
        final entries = await repo.getEntriesByIds(
          job.entries.map((entry) => entry.id),
          job.target,
        );
        final byId = {for (final entry in entries) entry.id: entry};
        for (final snapshot in job.entries) {
          final entry = byId[snapshot.id];
          if (entry == null ||
              entry.updatedAt != snapshot.updatedAt ||
              entry.bodyJson != snapshot.bodyJson ||
              entry.title != snapshot.title ||
              entry.orderKey != snapshot.orderKey) {
            throw StateError('MEMO_EXPORT_VERSION_CHANGED');
          }
        }
        _checkSelection(job);
      });
    } catch (error, stackTrace) {
      logger.error(
        'MemoExport',
        '复核导出快照失败',
        safeErrorSummary(error),
        stackTrace,
      );
      rethrow;
    }
  }

  /// 收集正文引用的图片并解码尺寸；下载或解码失败时保留占位，不阻断导出。
  Future<Map<String, MemoDocumentMedia>> _loadMedia(
    List<MemoEntry> entries,
  ) async {
    final ids = <String>{};
    for (final entry in entries) {
      final bodyJson = entry.bodyJson;
      if (bodyJson == null) continue;
      try {
        final body = jsonDecode(bodyJson);
        if (body is Map && body['ops'] is List) {
          for (final op in body['ops'] as List) {
            final id = memoImageIdOf(op);
            if (id != null) ids.add(id);
          }
        }
      } catch (_) {
        // 单条正文损坏不阻断其他记录的导出。
        continue;
      }
    }
    if (ids.isEmpty) return const {};
    final service = ref.read(memoMediaServiceProvider);
    final result = <String, MemoDocumentMedia>{};
    for (final id in ids) {
      final bytes = await service.bytesOf(id);
      if (bytes == null) continue;
      final mime = memoMediaMimeOf(bytes);
      // Word/PDF 只可靠承载 PNG 与 JPEG，其余格式按占位输出。
      if (mime == null || mime == 'image/webp') continue;
      final size = await _imageSize(bytes);
      if (size == null) continue;
      result[id] = MemoDocumentMedia(
        bytes: bytes,
        width: size.$1,
        height: size.$2,
        extension: mime == 'image/png' ? 'png' : 'jpg',
      );
    }
    return result;
  }

  /// 导出只需要像素尺寸，解码后立即释放位图。
  Future<(int, int)?> _imageSize(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      try {
        final frame = await codec.getNextFrame();
        try {
          return (frame.image.width, frame.image.height);
        } finally {
          frame.image.dispose();
        }
      } finally {
        codec.dispose();
      }
    } catch (_) {
      return null;
    }
  }

  /// PNG 在主隔离区使用引擎排版，文档格式在后台生成；写盘前后复核快照。
  Future<File> generate(MemoDocumentJob job, {required String untitled}) async {
    try {
      await validate(job);
      final regular = job.format == MemoDocumentFormat.pdf
          ? await rootBundle.load(MemoDocumentStyle.fontAsset)
          : null;
      final emoji = job.format == MemoDocumentFormat.pdf
          ? await rootBundle.load(MemoDocumentStyle.emojiAsset)
          : null;
      // 导出前把正文字节加载到内存：云端图片缺失时会即时下载，失败降级为占位。
      final media = await _loadMedia(
        job.credentials ? job.entries : [job.entry],
      );
      final bytes = job.format == MemoDocumentFormat.png
          ? await MemoImage.render(
              job.credentials
                  ? MemoDocument.fromEntries(
                      job.book,
                      job.entries,
                      job.countLabel,
                      media: media,
                    )
                  : MemoDocument.fromEntry(job.book, job.entry, media: media),
              isCancelled: () => job.cancelled,
            )
          : await compute(_renderMemo, (
              job.book,
              job.entry,
              job.format,
              regular,
              emoji,
              job.credentials,
              job.entries,
              job.countLabel,
              media,
            ));
      await validate(job);
      job.directory ??= await Directory(
        p.join(
          (await getTemporaryDirectory()).path,
          'memo_${const Uuid().v4()}',
        ),
      ).create();
      final base = memoDocumentFilename(
        job.credentials
            ? job.book.name
            : job.entry.title.isEmpty
            ? untitled
            : job.entry.title,
      );
      var file = File(p.join(job.directory!.path, '$base.${job.format.name}'));
      for (var n = 2; await file.exists(); n++) {
        file = File(
          p.join(job.directory!.path, '$base ($n).${job.format.name}'),
        );
      }
      await file.writeAsBytes(bytes, flush: true);
      await validate(job);
      return file;
    } catch (error, stack) {
      logger.warning('MemoExport', '生成导出文件失败: ${error.runtimeType}', stack);
      if (error is MemoImageTooLarge) rethrow;
      // 不把底层 writer、文件内容或卡片字段带入通用错误边界。
      throw StateError(
        job.cancelled ? 'MEMO_EXPORT_CANCELLED' : 'MEMO_EXPORT_FAILED',
      );
    }
  }
}

/// 保留文档内部真实标题；文件名限制按字符而非 UTF-16 单元截断。
String memoDocumentFilename(String title) {
  var name = title
      .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_')
      .trim()
      .replaceAll(RegExp(r'[. ]+$'), '');
  // 最多 192 个 UTF-8 字节，为文件扩展名与消歧后缀保留跨平台余量。
  name = String.fromCharCodes(
    name.runes.take(48),
  ).replaceAll(RegExp(r'[. ]+$'), '');
  if (name.isEmpty) name = 'memo';
  if (RegExp(
    r'^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(?:\.|$)',
    caseSensitive: false,
  ).hasMatch(name)) {
    name = '_$name';
  }
  return name;
}

/// 后台文档输出与 PNG 共用同一内容模型。
Future<Uint8List> _renderMemo(
  (
    MemoBook,
    MemoEntry,
    MemoDocumentFormat,
    ByteData?,
    ByteData?,
    bool,
    List<MemoEntry>,
    String,
    Map<String, MemoDocumentMedia>,
  )
  input,
) async {
  final (
    book,
    entry,
    format,
    regular,
    emoji,
    credentials,
    entries,
    countLabel,
    media,
  ) = input;
  final document = credentials
      ? MemoDocument.fromEntries(book, entries, countLabel, media: media)
      : MemoDocument.fromEntry(book, entry, media: media);
  return switch (format) {
    MemoDocumentFormat.md => Uint8List.fromList(
      utf8.encode(document.markdown()),
    ),
    MemoDocumentFormat.docx => document.docx(),
    MemoDocumentFormat.pdf => document.pdf(regular!, emoji!),
    MemoDocumentFormat.png => throw StateError('MEMO_PNG_REQUIRES_UI_ISOLATE'),
  };
}
