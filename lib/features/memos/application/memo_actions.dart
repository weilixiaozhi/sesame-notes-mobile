import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/repositories/contracts/memo_repositories.dart';
import 'package:sesame_notes/shared/application/support/account_snapshot_query.dart';
import 'package:sesame_notes/shared/application/support/action_error_boundary.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';
import 'package:sesame_notes/shared/providers/memo_repository_provider.dart';

/// 编辑器打开前一次取得本子、固定目标与可选正文。
typedef MemoEditorSnapshot = ({
  MemoBook book,
  PrivateBookTarget target,
  MemoEntry? entry,
});

/// 笔记应用用例持有仓储，页面只提交固定目标和用户输入。
class MemoActions {
  /// 删除统一走跨业务生命周期，普通编辑保留仓储的原子目标校验。
  MemoActions(this._repository, this._lifecycle);
  final MemoEntryRepository _repository;
  final DataLifecycleActions _lifecycle;

  /// 查询前后复核账号，防止迟到结果被后续会话消费。
  Future<T> _query<T>(String? accountId, Future<T> Function() read) =>
      readAccountSnapshot(
        area: 'MemoActions',
        accountId: accountId,
        currentAccountId: _repository.accountIdGetter,
        currentGeneration: _repository.generationGetter,
        read: read,
      );

  /// 导入和编辑请求使用仓储生成的完整父本身份。
  Future<PrivateBookTarget> target(String id) =>
      _query(_repository.accountIdGetter(), () => _repository.target(id));

  /// 重查固定本子，过期绑定与会话直接失败。
  Future<MemoBook> requireTarget(PrivateBookTarget target) =>
      _query(target.accountId, () => _repository.requireTarget(target));

  /// 为导航或导入取得当前账号可见的本子。
  Future<MemoBook?> getBook(String id, {required String? accountId}) =>
      _query(accountId, () => _repository.getBook(id, accountId: accountId));

  /// 读取固定本子内的条目，删除后的空值由调用方处理。
  Future<MemoEntry?> getEntry(String id, PrivateBookTarget target) =>
      _query(target.accountId, () => _repository.getEntry(id, target));

  /// 本子、绑定和正文使用同一账号快照，打开已有条目时不接受内容缺失。
  Future<MemoEditorSnapshot> prepareEditor(
    String bookId, {
    String? entryId,
    PrivateBookTarget? fixedTarget,
  }) => _query(
    fixedTarget == null ? _repository.accountIdGetter() : fixedTarget.accountId,
    () async {
      final target = fixedTarget ?? await _repository.target(bookId);
      if (target.bookId != bookId) throw StateError('MEMO_TARGET_CHANGED');
      final book = await _repository.requireTarget(target);
      final entry = entryId == null
          ? null
          : await _repository.getEntry(entryId, target);
      if (entryId != null && entry == null) {
        throw StateError('MEMO_ENTRY_CHANGED');
      }
      return (book: book, target: target, entry: entry);
    },
  );

  /// 自动保存始终写入编辑器固定的原本，不跟随当前本或登录账号切换。
  Future<void> saveEntry(MemoEntry entry, PrivateBookTarget target) =>
      runApplicationAction('MemoActions', '保存笔记', () async {
        if (entry.memoBookId != target.bookId) {
          throw StateError('MEMO_TARGET_CHANGED');
        }
        await _repository.saveEntry(entry, target);
      });

  /// 手势使用原列表快照，仓储在同一事务中校验身份、内容版本与同步队列。
  Future<void> reorderCredentials(
    PrivateBookTarget target,
    List<MemoEntry> visibleEntries,
    List<String> reorderedIds,
  ) => runApplicationAction('MemoActions', '保存卡片顺序', () async {
    await _repository.reorderCredentials(target, visibleEntries, reorderedIds);
  });

  /// 确认删除时再次验证原目标，云端确认与本地意图共用统一删除入口。
  Future<void> deleteEntry(MemoEntry entry, PrivateBookTarget target) =>
      runApplicationAction('MemoActions', '删除笔记', () async {
        if (entry.memoBookId != target.bookId) {
          throw StateError('MEMO_TARGET_CHANGED');
        }
        await _lifecycle.deleteTarget(
          SyncTarget('memo_entry', entry.id, parentId: target.bookId),
          validate: () => _repository.requireTarget(target),
        );
      });

  /// 同步中心按当前账号查找条目，跨本搜索不放在页面中执行。
  Future<MemoEntry?> findEntry(String id) =>
      _query(_repository.accountIdGetter(), () async {
        final account = _repository.accountIdGetter();
        for (final book in await _repository.getBooks(accountId: account)) {
          final target = await _repository.target(book.id);
          final entry = await _repository.getEntry(id, target);
          if (entry != null) return entry;
        }
        return null;
      });

  /// 刷新本地列表与当前筛选结果，不把数据库流或仓储交给页面。
  Future<void> refreshLocalSnapshot({
    required String? accountId,
    String? bookId,
    DateTime? date,
    int limit = 100,
  }) => _query(accountId, () async {
    await _repository.getBooks(accountId: accountId);
    if (bookId != null) {
      await _repository
          .watchEntries(bookId, accountId: accountId, date: date, limit: limit)
          .first;
    }
  });
}

/// 笔记界面与其他业务入口统一消费应用能力。
final memoActionsProvider = Provider<MemoActions>(
  (ref) => MemoActions(
    ref.watch(memoEntryRepositoryProvider),
    ref.read(dataLifecycleProvider),
  ),
);
