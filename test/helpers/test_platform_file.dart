import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

/// 为文件选择页面测试返回预设结果，不触发原生平台通道。
class TestFilePicker extends FilePickerPlatform {
  /// 创建一个始终返回 [result] 的文件选择器。
  TestFilePicker(this.result);

  final PlatformFile? result;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => result;
}

/// 为文件读取与选择测试提供不依赖平台通道的文件对象。
base class TestPlatformFile extends PlatformFile {
  /// 创建一个由内存字节或测试路径表示的平台文件。
  TestPlatformFile({
    required this.name,
    String? path,
    List<int> bytes = const [],
  }) : _bytes = Uint8List.fromList(bytes),
       uri = path == null ? Uri.dataFromBytes(bytes) : Uri.file(path);

  @override
  final String name;

  final Uint8List _bytes;

  @override
  final Uri uri;

  @override
  get xFile => throw UnsupportedError('测试文件不提供 XFile');

  @override
  int lengthSync() => _bytes.length;

  @override
  Future<int> length() async => _bytes.length;

  @override
  Future<Uint8List> readAsBytes() async => _bytes;

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(_bytes);
}
