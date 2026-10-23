import 'dart:io';

import 'package:meta/meta.dart';

/// 云端存储中的文件。
@immutable
class CloudFile {
  /// 文件名。
  final String name;

  /// 相对于当前存储范围的逻辑路径，可直接传给下载与删除。
  final String path;

  /// 文件大小（字节，可选）。
  final int? size;

  /// 最后修改时间（可选）。
  final DateTime? lastModified;

  /// 后端原生对象属性（可选）。
  ///
  /// 可包含内容类型、存储标识或对象版本等信息。
  final Map<String, dynamic>? metadata;

  const CloudFile({
    required this.name,
    required this.path,
    this.size,
    this.lastModified,
    this.metadata,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudFile &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() => 'CloudFile(name: $name, path: $path, size: $size)';
}

/// 云备份文件存储能力；文件正文必须逐块传输，不把整份备份载入内存。
abstract class CloudStorageService {
  /// 条件创建文件；同名对象抛出 CloudFileAlreadyExistsException，绝不覆盖。
  /// 可选属性由支持的后端原生保存，不要求额外表或旁路文件。
  Future<void> uploadFile({
    required String path,
    required File file,
    Map<String, String>? metadata,
  });

  /// 下载到调用方的隔离文件；不存在返回 false，失败不得留下半文件。
  Future<bool> downloadFile({required String path, required File destination});

  /// 从云端存储删除文件。
  ///
  /// [path] - 文件路径。
  ///
  /// 删除失败时抛出 [CloudStorageException]。
  /// 应具备幂等性（文件不存在时不报错）。
  Future<void> delete({required String path});

  /// 列出目录下的文件。
  ///
  /// [path] - 目录路径（如 'users/123/'），空字符串表示配置存储范围的根目录。
  ///
  /// 返回目录及其子目录内的文件列表，不包含目录本身。
  /// 失败时抛出 [CloudStorageException]。
  Future<List<CloudFile>> list({required String path});
}
