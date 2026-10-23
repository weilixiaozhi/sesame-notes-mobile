import 'package:sesame_notes/utils/text_validation.dart';
import 'package:sesame_notes/utils/wire_timestamp.dart';
import 'private_book.dart';
import 'dart:convert';
import 'memo_delta.dart';
import 'memo_fields.dart';

/// 备忘录本类型：普通笔记与账号密码卡片各自成组，本子管理与当前本选择都按类型区分。
const memoBookTypeNormal = 'normal';
const memoBookTypeCredentials = 'credentials';

/// 备忘录本字段校验统一应用本类型规则。
void validateMemoBookDefinition(String name, String type) {
  if (!isValidName(name) || !['normal', 'credentials'].contains(type)) {
    throw const FormatException('MEMO_BOOK_FIELDS');
  }
}

class MemoBook extends PrivateBook {
  final String type;
  final String? sourceMemoBookId;
  final int entryCount;
  const MemoBook({
    required super.id,
    required super.name,
    required this.type,
    required super.createdAt,
    required super.updatedAt,
    super.storageMode,
    super.scopeAccountId,
    super.syncId,
    super.fullCursor,
    super.serverRevision,
    super.deletedAt,
    super.isStale,
    super.isHidden,
    super.pendingLocalDelete,
    super.sourceAccountId,
    super.sourceOperationId,
    this.sourceMemoBookId,
    this.entryCount = 0,
  });
  @override
  Map<String, Object?> get payload => {...super.payload, 'type': type};
}

/// 内容模型保持原始字段与原始内容时间；列表查询可以只映射摘要而不解析正文。
class MemoEntry {
  final String id, memoBookId, bookType, title;

  /// 列表查询附带的纯文字预览，不参与持久化和同步载荷。
  final String? previewText;
  final bool isSummary;
  final String? bodyJson, sourceEntryId, sourceConflictId;
  final int? orderKey, serverRevision;
  final DateTime createdAt, updatedAt;
  final DateTime? deletedAt;
  const MemoEntry({
    required this.id,
    required this.memoBookId,
    required this.bookType,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.bodyJson,
    this.previewText,
    this.isSummary = false,
    this.orderKey,
    this.serverRevision,
    this.deletedAt,
    this.sourceEntryId,
    this.sourceConflictId,
  });
  bool get isCard => bookType == 'credentials';
  Object? get body => bodyJson == null ? null : jsonDecode(bodyJson!);

  /// 卡片字段列表；摘要读取不解析正文，普通笔记始终为空。
  List<MemoField> get fields =>
      isCard && !isSummary && bodyJson != null ? memoFieldsOf(body) : const [];

  /// 校验完整正文与本子类型，摘要模型不能用于写入。
  void validate() {
    if (isSummary) throw const FormatException('MEMO_SUMMARY_READ_ONLY');
    if (!isWellFormedText(title)) {
      throw const FormatException('MEMO_INVALID_UNICODE');
    }
    if (!['normal', 'credentials'].contains(bookType)) {
      throw const FormatException('MEMO_TYPE');
    }
    if (isCard) {
      if (bodyJson == null || (orderKey != null && orderKey! < 0)) {
        throw const FormatException('MEMO_CARD_FIELDS');
      }
      // 字段结构始终校验；标题与字段都为空时才额外拒绝整张空卡片。
      final fields = memoFieldsOf(body);
      if (!hasVisibleText(title) && fields.isEmpty) {
        throw const FormatException('MEMO_CARD_FIELDS');
      }
    } else {
      if (orderKey != null) throw const FormatException('MEMO_NOTE_FIELDS');
      try {
        validateMemoDelta(body);
      } catch (_) {
        throw const FormatException('INVALID_MEMO_DELTA');
      }
    }
  }

  Map<String, Object?> get payload => {
    'book_type': bookType,
    'title': title,
    'body_format': isCard ? 'fields_v1' : 'delta_v1',
    'body': body,
    'order_key': orderKey?.toString(),
    'created_at': wireTimestamp(createdAt),
    'updated_at': wireTimestamp(updatedAt),
  };
}
