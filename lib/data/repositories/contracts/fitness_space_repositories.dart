import '../../models/private_book.dart';

/// 健身空间的可访问目录与目标验证端口。
abstract interface class FitnessSpaceQueryRepository {
  /// 当前身份由装配层提供，异步查询前后读取同一个事实来源。
  String? Function() get accountIdGetter;

  /// 当前会话代次用于拒绝旧会话迟到结果。
  int Function() get generationGetter;

  /// 读取当前账号可访问的本子集合。
  Future<List<FitnessSpace>> getBooks({String? accountId});

  /// 提供当前用例所需的 watchBooks 能力，身份与事务由实现维护。
  Stream<List<FitnessSpace>> watchBooks({String? accountId});

  /// 读取当前账号可访问的指定本子。
  Future<FitnessSpace?> getBook(String id, {String? accountId});

  /// 固定操作目标的账号、会话代次与云端绑定。
  Future<PrivateBookTarget> target(String id);

  /// 重新验证固定目标仍属于当前会话。
  Future<FitnessSpace> requireTarget(PrivateBookTarget target);
}

/// 健身空间创建、改名与确认所需的数据端口。
abstract interface class FitnessSpaceBookRepository {
  /// 多次读写共用一个事务；实现记录失败并保留原始异常。
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// 读取当前账号可访问的指定本子。
  Future<FitnessSpace?> getBook(String id, {String? accountId});

  /// 固定操作目标的账号、会话代次与云端绑定。
  Future<PrivateBookTarget> target(String id);

  /// 创建具有稳定身份的本子并原子登记必要同步意图。
  Future<FitnessSpace> createBook({
    required String id,
    required String name,
    String storageMode = 'local',
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  /// 在固定绑定仍有效时更新本子名称。
  Future<void> renameBook(PrivateBookTarget target, String name);
}

/// 账号退出只取得健身空间本机副本保护能力。
abstract interface class FitnessSpaceAccountRepository {
  /// 退出账号前幂等保留原账号的本机副本。
  Future<String> copyToLocalForAccountExit(String id, String operationId);
}
