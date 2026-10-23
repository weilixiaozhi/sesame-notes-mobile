import 'private_book.dart';
import 'package:sesame_notes/utils/wire_timestamp.dart';
import 'package:sesame_notes/utils/text_validation.dart';
import 'day_event.dart';

/// 名称规范化与数据库约束共用 Unicode White_Space 加 BOM 字符集。
/// 规范化本名和记录名，按 Unicode 码点计数，保留名称内部空白。
String normalizeDayName(String value) {
  try {
    return normalizeName(value);
  } on FormatException {
    throw const DayDateException('invalid_name');
  }
}

/// 日子本的纯展示及身份快照，不引用数据库或财务账本。
class DayBook extends PrivateBook {
  final String? sourceDayBookId;
  const DayBook({
    required super.id,
    required super.name,
    required super.createdAt,
    required super.updatedAt,
    super.storageMode,
    super.scopeAccountId,
    super.syncId,
    super.serverRevision,
    super.fullCursor,
    super.deletedAt,
    super.pendingLocalDelete,
    super.isStale,
    super.isHidden,
    super.sourceAccountId,
    this.sourceDayBookId,
    super.sourceOperationId,
  });

  // 日子协议由服务端维护修改时间，不把通用模型的更新时间写入载荷。
  @override
  Map<String, Object?> get payload => {
    'name': name,
    'created_at': wireTimestamp(createdAt),
  };
}

/// 收据只在所属本内重映射；来源文件与来源条目标识保持稳定。
typedef DayBackupReceipt = ({
  String exportId,
  String sourceEntryId,
  String? localEventId,
  DateTime importedAt,
});
