import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/shared/providers/cloud_capability_provider.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/infrastructure/api/api_client_provider.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/utils/text_validation.dart';
import 'support/action_error_boundary.dart';

/// 编辑本子所需的业务快照，不暴露数据库行或查询句柄。
typedef PrivateBookSnapshot = ({PrivateBook book, int count});

/// 各业务本子向应用用例提供的持久化端口。
abstract interface class PrivateBookStore {
  /// 对应同步目标的稳定类型。
  String get targetType;

  /// 在一次数据库事务内执行本子写入及身份复核。
  Future<T> transaction<T>(Future<T> Function() action);

  /// 读取账号可见的本子及当前内容数量。
  Future<PrivateBookSnapshot> load(String id, String? accountId);

  /// 创建固定身份的新本子，重试继续使用相同标识。
  Future<void> create(
    String id,
    String name,
    String? accountId,
    int generation,
    String storageMode,
  );

  /// 获取当前持久绑定，用于写入前验证目标没有被替换。
  Future<PrivateBookTarget> target(String id);

  /// 在固定目标下保存本子名称。
  Future<void> rename(PrivateBookTarget target, String name);
}

/// 本子表单的应用用例，集中账号验证、绑定检查、事务和同步串行边界。
class PrivateBookActions {
  /// 端口在各业务的应用层装配，展示层只获得本用例。
  PrivateBookActions(this._ref, this._store);

  final Ref _ref;
  final PrivateBookStore _store;

  /// 归属操作使用同一份业务目标类型。
  String get targetType => _store.targetType;

  /// 页面持有的账号和会话代次失效时停止执行后续操作。
  void verifySession(String? accountId, int generation) {
    if (!_ref.mounted ||
        _ref.read(currentAccountIdProvider) != accountId ||
        _ref.read(authIdentityGenerationProvider) != generation) {
      throw StateError('BOOK_SESSION_CHANGED');
    }
  }

  /// 返回固定本子的当前快照，已存在的云端绑定必须保持不变。
  Future<PrivateBookSnapshot> snapshot({
    required String id,
    required String? accountId,
    required int generation,
    PrivateBook? expected,
  }) => runApplicationAction(
    'PrivateBook',
    '读取本子',
    () => _snapshot(
      id: id,
      accountId: accountId,
      generation: generation,
      expected: expected,
    ),
  );

  /// 创建或改名与最终快照同事务提交，身份变化时全部回滚。
  Future<PrivateBook> save({
    required String id,
    required String name,
    required String? accountId,
    required int generation,
    PrivateBook? expected,
    String? storageMode,
  }) => runApplicationAction('PrivateBook', '保存本子', () async {
    verifySession(accountId, generation);
    final normalized = normalizeName(name);
    final String mode = storageMode ?? _ref.read(newBookStorageModeProvider);
    final config = _ref.read(apiConfigProvider);
    return _ref
        .read(syncCoordinatorProvider)
        .runDataMutation(
          () => _store.transaction(() async {
            verifySession(accountId, generation);
            if (expected == null) {
              if (mode == 'cloud' &&
                  !_ref.read(cloudCapabilityProvider).canUseCloudBooks) {
                throw StateError('云服务不可用，请创建本地本');
              }
              await _store.create(id, normalized, accountId, generation, mode);
              if (!identical(_ref.read(apiConfigProvider), config)) {
                throw StateError('服务配置已变化，请重试');
              }
            } else {
              final current = await _snapshot(
                id: id,
                accountId: accountId,
                generation: generation,
                expected: expected,
              );
              final target = await _store.target(id);
              if (target.syncId != current.book.syncId) {
                throw StateError('BOOK_TARGET_CHANGED');
              }
              await _store.rename(target, normalized);
            }
            final saved = await _snapshot(
              id: id,
              accountId: accountId,
              generation: generation,
              expected: expected,
            );
            verifySession(accountId, generation);
            return saved.book;
          }),
        );
  });

  /// 异步读取前后均复核账号，避免将迟到快照交给新会话。
  Future<PrivateBookSnapshot> _snapshot({
    required String id,
    required String? accountId,
    required int generation,
    PrivateBook? expected,
  }) async {
    verifySession(accountId, generation);
    if (expected != null && expected.id != id) {
      throw StateError('BOOK_TARGET_CHANGED');
    }
    final current = await _store.load(id, accountId);
    verifySession(accountId, generation);
    if (current.book.id != id) throw StateError('BOOK_TARGET_CHANGED');
    if (expected?.syncId != null && expected!.syncId != current.book.syncId) {
      throw StateError('BOOK_TARGET_CHANGED');
    }
    return current;
  }
}
