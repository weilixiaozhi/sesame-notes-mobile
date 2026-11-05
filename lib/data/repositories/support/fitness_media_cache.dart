import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../../core/logging/logger_service.dart';

/// 媒体缓存只回收已确认有随包替身的副本，未知或唯一离线媒体始终保留。
class FitnessMediaCache {
  /// 注入所属目录和可安全回收的文件身份，测试使用独占目录与较小预算。
  FitnessMediaCache({
    required this.directory,
    required this.reclaimableKeys,
    required this.verifyReclaimable,
    this.maxBytes = 256 * 1024 * 1024,
  }) {
    if (maxBytes <= 0) throw ArgumentError.value(maxBytes, 'maxBytes');
  }

  final Future<Directory> Function() directory;
  final Future<Set<String>> Function() reclaimableKeys;
  final Future<bool> Function(String key, File file) verifyReclaimable;
  final int maxBytes;
  static final _fileName = RegExp(r'^([0-9a-f]{64})\.gif$');
  static final _directories = <String, _DirectoryState>{};

  /// 同目录的读写与回收串行执行，多个仓储实例不会同时通过容量检查。
  Future<T> _exclusive<T>(
    Future<T> Function(Directory root, _DirectoryState state) action,
  ) async {
    final folder = await directory();
    await folder.create(recursive: true);
    final canonical = await folder.resolveSymbolicLinks();
    final identity = Platform.isWindows ? canonical.toLowerCase() : canonical;
    final state = _directories.putIfAbsent(identity, _DirectoryState.new);
    final operation = state.pending.then(
      (_) => action(Directory(canonical), state),
    );
    // 排队尾部吸收失败只用于释放后续操作，原始错误仍由 operation 返回给当前调用方。
    state.pending = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  /// 只读取普通缓存文件；读取完毕即拥有独立字节，后续安全回收不会截断图片解码。
  Future<Uint8List?> read(
    String key, {
    required int maxFileBytes,
    required bool Function(Uint8List bytes) valid,
  }) async {
    try {
      return await _exclusive((root, state) async {
        if (!state.observed) {
          _report(await _inventory(root), state);
          state.observed = true;
        }
        final target = _target(root, key);
        final type = await FileSystemEntity.type(
          target.path,
          followLinks: false,
        );
        if (type != FileSystemEntityType.file) return null;
        final size = await target.length();
        if (size > maxFileBytes) return null;
        final bytes = await target.readAsBytes();
        return valid(bytes) ? bytes : null;
      });
    } catch (error, stack) {
      logger.error(
        'FitnessMediaCache',
        '动作图片缓存暂时无法读取，尝试在线获取',
        safeErrorSummary(error),
        stack,
      );
      return null;
    }
  }

  /// 在预算内原子保存；预算被受保护的旧文件占满时继续展示网络图片，但不增加磁盘用量。
  Future<bool> write(String key, Uint8List bytes) async {
    try {
      return await _exclusive((root, state) async {
        final target = _target(root, key);
        final type = await FileSystemEntity.type(
          target.path,
          followLinks: false,
        );
        // 链接、目录等未知对象不属于缓存写入器，不能覆盖或借它们访问其他位置。
        if (type != FileSystemEntityType.notFound &&
            type != FileSystemEntityType.file) {
          throw StateError('FITNESS_MEDIA_CACHE_TARGET_UNSAFE');
        }
        var inventory = await _inventory(root);
        // 原子替换期间旧文件与临时文件会短暂共存，两者都计入准入预算。
        if (inventory.bytes + bytes.length > maxBytes) {
          inventory = await _reclaim(root, inventory, key, bytes.length, state);
        }
        if (inventory.bytes + bytes.length > maxBytes) {
          state.rejectedWrites++;
          _report(inventory, state, full: true);
          return false;
        }
        // 临时文件仅在取得目录写入权后创建，其他缓存实例不会把在途写入当成回收对象。
        final work = await root.createTemp('download-');
        try {
          final temporary = File(
            '${work.path}${Platform.pathSeparator}media.gif',
          );
          await temporary.writeAsBytes(bytes, flush: true);
          await temporary.rename(target.path);
          _report(await _inventory(root), state);
          return true;
        } finally {
          try {
            // 临时目录的释放也在同一临界区内，下一次盘点不会与本次失败清理交错。
            if (await work.exists()) await work.delete(recursive: true);
          } catch (error, stack) {
            logger.error(
              'FitnessMediaCache',
              '清理本次图片缓存临时文件失败',
              safeErrorSummary(error),
              stack,
            );
          }
        }
      });
    } catch (error, stack) {
      logger.error(
        'FitnessMediaCache',
        '动作图片缓存暂时无法保存，本次图片仍可查看',
        safeErrorSummary(error),
        stack,
      );
      return false;
    }
  }

  /// 文件名只能由调用方的摘要身份构成，禁止路径或目录穿越。
  File _target(Directory root, String key) {
    if (!_fileName.hasMatch('$key.gif')) throw ArgumentError.value(key, 'key');
    return File('${root.path}${Platform.pathSeparator}$key.gif');
  }

  /// 统计缓存目录中的全部普通文件，旧临时文件和未知文件也计入准入预算，但不删除。
  Future<_Inventory> _inventory(Directory root) async {
    var bytes = 0;
    var files = 0;
    final candidates = <File, FileStat>{};
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final stat = await entity.stat();
      if (stat.type != FileSystemEntityType.file || stat.size < 0) continue;
      bytes += stat.size;
      files++;
      if (entity.parent.path == root.path &&
          _fileName.hasMatch(entity.uri.pathSegments.last)) {
        candidates[entity] = stat;
      }
    }
    return _Inventory(bytes, files, candidates);
  }

  /// 仅回收清单中已证明存在随包 GIF 的旧副本，唯一远端媒体和无法识别的历史文件不参与淘汰。
  Future<_Inventory> _reclaim(
    Directory root,
    _Inventory inventory,
    String writingKey,
    int growth,
    _DirectoryState state,
  ) async {
    final safe = await reclaimableKeys();
    final candidates = inventory.candidates.entries.toList()
      ..sort(
        (left, right) => left.value.modified.compareTo(right.value.modified),
      );
    var remaining = inventory.bytes;
    for (final candidate in candidates) {
      if (remaining + growth <= maxBytes) break;
      final key = _fileName
          .firstMatch(candidate.key.uri.pathSegments.last)!
          .group(1)!;
      if (key == writingKey || !safe.contains(key)) continue;
      try {
        if (await FileSystemEntity.type(
              candidate.key.path,
              followLinks: false,
            ) !=
            FileSystemEntityType.file) {
          continue;
        }
        if (!await verifyReclaimable(key, candidate.key)) continue;
        final size = await candidate.key.length();
        await candidate.key.delete();
        remaining -= size;
        state.reclaimedFiles++;
      } catch (error, stack) {
        // 在用文件或平台拒绝删除时保留原文件，容量不足仍由准入检查安全拒绝。
        logger.error(
          'FitnessMediaCache',
          '暂时无法回收可替代图片副本，已保留文件',
          safeErrorSummary(error),
          stack,
        );
      }
    }
    return _inventory(root);
  }

  /// 容量诊断只包含计数，日志中不记录服务器地址、路径、媒体身份或用户内容。
  void _report(
    _Inventory inventory,
    _DirectoryState state, {
    bool full = false,
  }) {
    final statistics = {
      'bytes': inventory.bytes,
      'files': inventory.files,
      'limit_bytes': maxBytes,
      'reclaimed_files': state.reclaimedFiles,
      'rejected_writes': state.rejectedWrites,
    };
    if (full) {
      logger.warning(
        'FitnessMediaCache',
        '图片缓存空间已满，本次图片仅在线展示，已有离线图片保留',
        statistics,
      );
    } else {
      logger.info('FitnessMediaCache', '图片缓存容量', statistics);
    }
  }
}

/// 同一个实际目录共享操作队列和本次进程的容量诊断计数。
class _DirectoryState {
  Future<void> pending = Future.value();
  bool observed = false;
  int rejectedWrites = 0;
  int reclaimedFiles = 0;
}

/// 缓存目录的当前占用与可识别的顶层媒体文件，不包含符号链接指向的外部内容。
class _Inventory {
  /// 保留扫描时的修改时间，只有证明可替代的候选才按时间顺序回收。
  const _Inventory(this.bytes, this.files, this.candidates);
  final int bytes;
  final int files;
  final Map<File, FileStat> candidates;
}
