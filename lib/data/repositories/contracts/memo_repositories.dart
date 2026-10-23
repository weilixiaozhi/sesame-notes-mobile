import '../../models/memo.dart';
import '../../models/memo_json.dart';
import '../../models/memo_import_preview.dart';
import '../../models/memo_order.dart';
import '../../models/private_book.dart';

/// 笔记目录、列表与日历只读查询端口。
abstract interface class MemoQueryRepository {
  /// 读取当前账号可访问的本子集合。
  Future<List<MemoBook>> getBooks({String? accountId});

  /// 提供当前用例所需的 watchBooks 能力，身份与事务由实现维护。
  Stream<List<MemoBook>> watchBooks({String? accountId});

  /// 读取当前账号可访问的指定本子。
  Future<MemoBook?> getBook(String id, {String? accountId});

  /// 固定操作目标的账号、会话代次与云端绑定。
  Future<PrivateBookTarget> target(String id);

  /// 重新验证固定目标仍属于当前会话。
  Future<MemoBook> requireTarget(PrivateBookTarget target);

  /// 读取完整条目；账号卡片按手动顺序，普通笔记按最近编辑排列。
  Future<List<MemoEntry>> getEntries(String id, {String? accountId});

  /// 在固定目标内读取条目并复核身份。
  Future<MemoEntry?> getEntry(String id, PrivateBookTarget target);

  /// 提供当前用例所需的 watchEntries 能力，身份与事务由实现维护。
  Stream<List<MemoEntry>> watchEntries(
    String id, {
    String? accountId,
    DateTime? date,
    int? limit = 100,
  });

  /// 提供当前用例所需的 watchCalendarCounts 能力，身份与事务由实现维护。
  Stream<Map<DateTime, int>> watchCalendarCounts(
    String bookId, {
    required DateTime start,
    required DateTime until,
    String? accountId,
  });

  /// 提供当前用例所需的 watchCredentialEntries 能力，身份与事务由实现维护。
  Stream<List<MemoEntry>> watchCredentialEntries({
    required String bookId,
    String? accountId,
    int? limit = 100,
    String search = '',
    CredentialSort sort = CredentialSort.manual,
  });
}

/// 笔记编辑与文档快照所需的端口，不公开数据库。
abstract interface class MemoEntryRepository {
  /// 当前身份由装配层提供，异步查询前后读取同一个事实来源。
  String? Function() get accountIdGetter;

  /// 当前会话代次用于拒绝旧会话迟到结果。
  int Function() get generationGetter;

  /// 多次读写共用一个事务；实现记录失败并保留原始异常。
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// 读取当前账号可访问的本子集合。
  Future<List<MemoBook>> getBooks({String? accountId});

  /// 读取当前账号可访问的指定本子。
  Future<MemoBook?> getBook(String id, {String? accountId});

  /// 固定操作目标的账号、会话代次与云端绑定。
  Future<PrivateBookTarget> target(String id);

  /// 重新验证固定目标仍属于当前会话。
  Future<MemoBook> requireTarget(PrivateBookTarget target);

  /// 读取完整条目；账号卡片按手动顺序，普通笔记按最近编辑排列。
  Future<List<MemoEntry>> getEntries(String id, {String? accountId});

  /// 在固定目标内读取条目并复核身份。
  Future<MemoEntry?> getEntry(String id, PrivateBookTarget target);

  /// 提供当前用例所需的 watchEntries 能力，身份与事务由实现维护。
  Stream<List<MemoEntry>> watchEntries(
    String id, {
    String? accountId,
    DateTime? date,
    int? limit = 100,
  });

  /// 在固定目标内原子保存条目与同步意图。
  Future<void> saveEntry(
    MemoEntry value,
    PrivateBookTarget target, {
    bool preserveTimes = false,
  });

  /// 验证可见快照，在固定本子内原子调整顺序并登记同步意图。
  Future<void> reorderCredentials(
    PrivateBookTarget target,
    List<MemoEntry> visibleEntries,
    List<String> reorderedIds,
  );
}

/// 笔记本创建、改名与确认所需的端口。
abstract interface class MemoBookRepository {
  /// 多次读写共用一个事务；实现记录失败并保留原始异常。
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// 读取当前账号可访问的指定本子。
  Future<MemoBook?> getBook(String id, {String? accountId});

  /// 固定操作目标的账号、会话代次与云端绑定。
  Future<PrivateBookTarget> target(String id);

  /// 创建具有稳定身份的本子并原子登记必要同步意图。
  Future<MemoBook> createBook({
    required String id,
    required String name,
    required String type,
    String storageMode = 'local',
    String? accountId,
    int? generation,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  /// 在固定绑定仍有效时更新本子名称。
  Future<void> renameBook(PrivateBookTarget target, String name);
}

/// 笔记标准交换格式与预览确认端口。
abstract interface class MemoTransferRepository {
  /// 固定操作目标的账号、会话代次与云端绑定。
  Future<PrivateBookTarget> target(String id);

  /// 重新验证固定目标仍属于当前会话。
  Future<MemoBook> requireTarget(PrivateBookTarget target);

  /// 读取同一本级快照并编码为标准交换文档。
  Future<MemoJsonDocument> exportJson(String id);

  /// 为固定导入目标捕获内容与数据库版本指纹。
  Future<MemoImportPreview> previewImport(
    MemoJsonDocument input,
    PrivateBookTarget fixed,
  );

  /// 验证预览指纹后原子导入内容、收据和同步意图。
  Future<({int imported, int skipped, bool pendingSync})> importJson(
    MemoImportPreview preview, {
    void Function(int, int)? onProgress,
  });
}

/// 账号退出只取得笔记本副本保护能力。
abstract interface class MemoAccountRepository {
  /// 退出账号前幂等保留原账号的本机副本。
  Future<String> copyToLocalForAccountExit(String id, String operationId);
}
