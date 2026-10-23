import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/data/models/sync_issue.dart';
import 'package:sesame_notes/data/repositories/contracts/day_repositories.dart';
import 'package:sesame_notes/shared/application/support/account_snapshot_query.dart';
import 'package:sesame_notes/shared/application/support/action_error_boundary.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';
import 'day_editor_actions.dart';
import 'day_providers.dart';

/// 日子编辑和导航用例，仓储装配与跨本查询不进入展示层。
class DayActions {
  /// 绑定具有当前账号和会话验证能力的仓储。
  DayActions(this._repository, this._lifecycle);
  final DayEntryRepository _repository;
  final DataLifecycleActions _lifecycle;

  /// 读取前后复核身份，查询过程中切号即丢弃结果。
  Future<T> _query<T>(String? accountId, Future<T> Function() read) =>
      readAccountSnapshot(
        area: 'DayActions',
        accountId: accountId,
        currentAccountId: _repository.accountIdGetter,
        currentGeneration: _repository.generationGetter,
        read: read,
      );

  /// 为选本和同步中心取得账号可见的日子本。
  Future<DayBook?> getBook(String id, {required String? accountId}) =>
      _query(accountId, () => _repository.getBook(id, accountId: accountId));

  /// 删除确认前固定父本、账号、会话代次和已知云绑定。
  Future<PrivateBookTarget> target(String bookId) =>
      _query(_repository.accountIdGetter(), () => _repository.target(bookId));

  /// 删除沿用打开确认框时的目标，最终身份校验与记录、队列删除同事务提交。
  Future<void> deleteEvent(DayEvent event, PrivateBookTarget target) =>
      runApplicationAction('DayActions', '删除日子', () async {
        if (event.dayBookId != target.bookId) {
          throw StateError('DAY_TARGET_CHANGED');
        }
        await _lifecycle.deleteTarget(
          SyncTarget('day_event', event.id, parentId: target.bookId),
          fixedTarget: target,
        );
      });

  /// 编辑参数绑定打开时的本子、账号和会话代次。
  Future<DayEditorArgs> prepareEditor(
    DayBook book, {
    DayEvent? event,
    DateOnly? initialDate,
  }) => _query(_repository.accountIdGetter(), () async {
    final target = await _repository.target(book.id);
    final current = await _repository.requireTarget(target);
    if ((book.syncId != null && book.syncId != current.syncId) ||
        book.storageMode != current.storageMode ||
        (event != null && event.dayBookId != book.id)) {
      throw StateError('DAY_TARGET_CHANGED');
    }
    return DayEditorArgs(
      book: current,
      accountId: target.accountId,
      generation: target.generation,
      event: event,
      initialDate: initialDate,
    );
  });

  /// 表单只提交值对象，实际仓储与当前身份由应用层提供。
  Future<DayEventDefinition> saveEditor({
    required DayEditorArgs args,
    required Set<String> unconfirmedDates,
    required DayEditorDraft draft,
    required String eventId,
    required DateTime createdAt,
  }) => runApplicationAction(
    'DayActions',
    '保存日子',
    () => saveDayEditorEvent(
      repository: _repository,
      args: args,
      currentAccountId: _repository.accountIdGetter(),
      unconfirmedDates: unconfirmedDates,
      draft: draft,
      eventId: eventId,
      createdAt: createdAt,
    ),
  );

  /// 跨本定位日子记录，页面不持有仓储或遍历数据库查询。
  Future<({DayBook book, DayEvent event})?> findEvent(String id) =>
      _query(_repository.accountIdGetter(), () async {
        final account = _repository.accountIdGetter();
        for (final book in await _repository.getBooks(accountId: account)) {
          final event = (await _repository.getEvents(
            book.id,
            accountId: account,
          )).where((event) => event.id == id).firstOrNull;
          if (event != null) return (book: book, event: event);
        }
        return null;
      });
}

/// 日子界面的所有持久化操作通过应用用例进入数据层。
final dayActionsProvider = Provider<DayActions>(
  (ref) => DayActions(
    ref.watch(dayEntryRepositoryProvider),
    ref.read(dataLifecycleProvider),
  ),
);
