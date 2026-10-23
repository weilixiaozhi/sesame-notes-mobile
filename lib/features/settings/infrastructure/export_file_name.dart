import 'package:intl/intl.dart';

/// 导出文件命名：`sesame_notes_<业务>_<内容>_<类型>_<yyyyMMdd_HHmmss>[_<分片>].<扩展名>`。
///
/// 设计意图：系统分享面板与文件管理器只展示文件名，导出文件在重新导入时
/// 必须能一眼看出属于哪个业务、哪个本子（备忘录还要看出普通本还是账号密码本），
/// 因此业务名、本名与类型都参与命名，并对非法字符与超长名称做收敛。
String exportFileName({
  required String business,
  required String extension,
  required DateTime exportedAt,
  String? content,
  String? variant,
  int? part,
}) {
  final segments = <String>[];
  for (final value in <String?>[
    'sesame_notes',
    business,
    content,
    variant,
    DateFormat('yyyyMMdd_HHmmss').format(exportedAt),
    if (part != null) '${part + 1}',
  ]) {
    if (value == null) continue;
    final segment = _sanitizeSegment(value);
    // 相邻两段同名时只留一段：本名本身就是「账号密码本」时类型段不再重复。
    if (segment.isEmpty || segment == segments.lastOrNull) continue;
    segments.add(segment);
  }
  return '${segments.join('_')}.$extension';
}

/// 去掉文件系统非法字符与控制字符，合并空白并按 Unicode 码点限制单段长度。
String _sanitizeSegment(String value) {
  final cleaned = value
      .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return String.fromCharCodes(cleaned.runes.take(40));
}
