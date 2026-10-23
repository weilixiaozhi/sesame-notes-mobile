import 'memo_json.dart';
import 'private_book.dart';

/// 单本导入固定目标与预览版本，确认期间内容变化时拒绝覆盖。
class MemoImportPreview {
  /// 保存经过标准格式验证的文档和本级内容指纹。
  const MemoImportPreview(this.document, this.target, this.fingerprint);

  final MemoJsonDocument document;
  final PrivateBookTarget target;
  final String fingerprint;
}
