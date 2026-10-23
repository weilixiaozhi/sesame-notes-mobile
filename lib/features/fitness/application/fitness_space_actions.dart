import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/data/repositories/contracts/fitness_space_repositories.dart';
import 'package:sesame_notes/shared/application/private_book_actions.dart';
import 'package:sesame_notes/shared/providers/fitness_space_provider.dart';

/// 为本子编辑用例装配当前业务的存储端口。
final fitnessSpaceActionsProvider = Provider<PrivateBookActions>(
  (ref) => PrivateBookActions(
    ref,
    _FitnessSpaceBookStore(ref.watch(fitnessSpaceBookRepositoryProvider)),
  ),
);

/// 只在应用层适配仓储差异，数据库句柄不交给页面。
class _FitnessSpaceBookStore implements PrivateBookStore {
  /// 固定当前仓储实例。
  _FitnessSpaceBookStore(this._repository);
  final FitnessSpaceBookRepository _repository;

  /// 同步目标使用业务协议中的稳定名称。
  @override
  String get targetType => 'fitness_space';

  /// 本子写入与应用层的最终身份校验共用同一事务。
  @override
  Future<T> transaction<T>(Future<T> Function() action) =>
      _repository.runInTransaction(action);

  /// 只返回当前账号可见的本子与用于确认的内容数量。
  @override
  Future<PrivateBookSnapshot> load(String id, String? accountId) async {
    final book = await _repository.getBook(id, accountId: accountId);
    if (book == null) throw StateError('BOOK_UNAVAILABLE');
    return (book: book, count: book.entityCount);
  }

  /// 新建本子按当前账号归属，调用方固定标识以保证重试幂等。
  @override
  Future<void> create(
    String id,
    String name,
    String? accountId,
    int generation,
    String storageMode,
  ) async {
    await _repository.createBook(id: id, name: name, storageMode: storageMode);
  }

  /// 将仓储的固定绑定传给应用用例再次比较。
  @override
  Future<PrivateBookTarget> target(String id) => _repository.target(id);

  /// 只对已经验证的固定本子更新名称。
  @override
  Future<void> rename(PrivateBookTarget target, String name) =>
      _repository.renameBook(target, name);
}
