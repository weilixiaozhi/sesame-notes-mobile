import '../../models/day_book.dart';
import '../../models/day_event.dart';
import '../../models/private_book.dart';

/// 日子目录与事件只读查询端口，不公开数据库或写操作。
abstract interface class DayQueryRepository {
  /// 当前身份由装配层提供，异步查询前后读取同一个事实来源。
  String? Function() get accountIdGetter;

  /// 当前会话代次用于拒绝旧会话迟到结果。
  int Function() get generationGetter;

  /// 读取当前账号可访问的本子集合。
  Future<List<DayBook>> getBooks({String? accountId});

  /// 提供当前用例所需的 watchBooks 能力，身份与事务由实现维护。
  Stream<List<DayBook>> watchBooks({String? accountId});

  /// 读取当前账号可访问的指定本子。
  Future<DayBook?> getBook(String id, {String? accountId});

  /// 读取指定本子的日子记录。
  Future<List<DayEvent>> getEvents(String id, {String? accountId});

  /// 提供当前用例所需的 watchEvents 能力，身份与事务由实现维护。
  Stream<List<DayEvent>> watchEvents(String id, {String? accountId});

  /// 固定操作目标的账号、会话代次与云端绑定。
  Future<PrivateBookTarget> target(String id);

  /// 重新验证固定目标仍属于当前会话。
  Future<DayBook> requireTarget(PrivateBookTarget target);
}

/// 日子编辑与定位所需的最小数据端口。
abstract interface class DayEntryRepository {
  /// 当前身份由装配层提供，异步查询前后读取同一个事实来源。
  String? Function() get accountIdGetter;

  /// 当前会话代次用于拒绝旧会话迟到结果。
  int Function() get generationGetter;

  /// 读取当前账号可访问的本子集合。
  Future<List<DayBook>> getBooks({String? accountId});

  /// 读取当前账号可访问的指定本子。
  Future<DayBook?> getBook(String id, {String? accountId});

  /// 读取指定本子的日子记录。
  Future<List<DayEvent>> getEvents(String id, {String? accountId});

  /// 固定操作目标的账号、会话代次与云端绑定。
  Future<PrivateBookTarget> target(String id);

  /// 重新验证固定目标仍属于当前会话。
  Future<DayBook> requireTarget(PrivateBookTarget target);

  /// 在固定目标内原子保存日子记录与同步意图。
  Future<void> saveEventAtTarget(DayEvent value, PrivateBookTarget target);
}

/// 日子本创建、改名与确认数量所需的数据端口。
abstract interface class DayBookRepository {
  /// 多次读写共用一个事务；实现记录失败并保留原始异常。
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// 读取当前账号可访问的指定本子。
  Future<DayBook?> getBook(String id, {String? accountId});

  /// 读取指定本子的日子记录。
  Future<List<DayEvent>> getEvents(String id, {String? accountId});

  /// 固定操作目标的账号、会话代次与云端绑定。
  Future<PrivateBookTarget> target(String id);

  /// 创建具有稳定身份的本子并原子登记必要同步意图。
  Future<DayBook> createBook({
    required String id,
    required String name,
    String storageMode = 'local',
    String? accountId,
    int? generation,
  });

  /// 在固定绑定仍有效时更新本子名称。
  Future<void> renameBook(PrivateBookTarget target, String name);
}

/// 日子文件交换所需的快照、写权限及去重端口。
abstract interface class DayTransferRepository {
  /// 多次读写共用一个事务；实现记录失败并保留原始异常。
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// 判断固定本子是否仍有未上传内容或未解决的拉取错误。
  Future<bool> hasUnsettledChanges(String bookId);

  /// 读取当前账号可访问的指定本子。
  Future<DayBook?> getBook(String id, {String? accountId});

  /// 读取指定本子的日子记录。
  Future<List<DayEvent>> getEvents(String id, {String? accountId});

  /// 验证本子写权限及可选云端绑定。
  Future<DayBook> requireWritable(
    String id, {
    String? accountId,
    String? expectedSyncId,
  });

  /// 读取持久导入收据，已删除记录仍保留去重事实。
  Future<Set<String>> getImportReceipts(
    String targetDayBookId,
    String exportId, {
    String? accountId,
  });

  /// 同一事务写入日子、导入收据与同步意图。
  Future<({int imported, int skipped})> importIntoBook({
    required String targetDayBookId,
    required String exportId,
    required List<DayEvent> entries,
    String? accountId,
    String? expectedSyncId,
    DayBook? expectedBook,
    void Function()? validateContext,
    void Function(int, int)? onProgress,
  });
}

/// 账号退出只取得本机副本保护能力。
abstract interface class DayAccountRepository {
  /// 将原账号待保护内容保存为稳定身份的本机副本。
  Future<DayBook> copyToLocal(
    String id, {
    String? accountId,
    String? operationId,
    bool hidden = false,
  });
}
