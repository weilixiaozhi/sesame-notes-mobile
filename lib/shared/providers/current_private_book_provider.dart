import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/private_book.dart';
import '../../infrastructure/api/api_client_provider.dart';
import '../application/support/action_error_boundary.dart';
import 'account_state_provider.dart';
import 'package:sesame_notes/core/storage/shared_preferences_provider.dart';

/// 私有本当前选择按身份保存；列表变化只回落选择，不隐式创建或搬迁数据。
abstract class CurrentPrivateBookNotifier extends AsyncNotifier<String?> {
  /// 内存选择只属于同一账号和会话，无有效偏好时保留仍有效的当前本。
  ({String? account, int generation, String? id})? _selection;

  Future<String?> currentSelection() => future;
  String get preferencePrefix;
  void watchDirectory();
  Future<List<PrivateBook>> loadBooks(String? account);
  Future<PrivateBookTarget> target(String id);
  Future<PrivateBook> requireTarget(PrivateBookTarget target);
  String _key(String? account) => '${preferencePrefix}_${account ?? 'local'}';

  /// 身份和目录变化时恢复有效偏好，缺少偏好才沿用当前本或回落首本。
  @override
  Future<String?> build() =>
      runApplicationAction('PrivateBookSelection', '恢复当前本', () async {
        // 固定本轮 Ref，已失效的异步查询不能覆盖新一轮选择。
        final buildRef = ref;
        final account = buildRef.watch(currentAccountIdProvider);
        final generation = buildRef.watch(authIdentityGenerationProvider);
        watchDirectory();
        final prefs = await buildRef.read(sharedPreferencesProvider.future);
        if (!buildRef.mounted) return null;
        final books = await loadBooks(account);
        if (!buildRef.mounted) return null;

        final previous = _selection;
        final current =
            previous?.account == account && previous?.generation == generation
            ? previous?.id
            : null;
        final saved = prefs.getString(_key(account));
        // 已保存的手选本可能晚于其他本子到位，下载完成后仍应恢复用户偏好。
        final selected = books.any((book) => book.id == saved)
            ? saved
            : books.any((book) => book.id == current)
            ? current
            : books.firstOrNull?.id;
        _selection = (account: account, generation: generation, id: selected);
        return selected;
      });

  /// 显式选本完成身份复核与偏好保存后，同步更新当前会话的内存选择。
  Future<void> select(String id) =>
      runApplicationAction('PrivateBookSelection', '选择当前本', () async {
        final account = ref.read(currentAccountIdProvider);
        final fixed = await target(id);
        final prefs = await ref.read(sharedPreferencesProvider.future);
        await requireTarget(fixed);
        if (!await prefs.setString(_key(account), id)) {
          throw StateError('BOOK_SELECTION_FAILED');
        }
        await requireTarget(fixed);
        if (ref.mounted) {
          // 最后一次异步校验完成后再同步核对身份，旧会话的选择不能覆盖新账号。
          if (ref.read(currentAccountIdProvider) != fixed.accountId ||
              ref.read(authIdentityGenerationProvider) != fixed.generation) {
            throw StateError('BOOK_SELECTION_FAILED');
          }
          _selection = (account: account, generation: fixed.generation, id: id);
          state = AsyncData(id);
        }
      });
}

/// 仅父本集合变化才重算选择，条目数量和同步回写不重置当前本。
String? privateBookIds(List<PrivateBook>? books) {
  final ids = books?.map((book) => book.id).toList();
  ids?.sort();
  return ids?.join(',');
}

/// 目录发现与身份过滤只维护一次，所有私有本共享加载、失败和空态判断。
AsyncValue<List<T>> privateBooksForDisplay<T extends PrivateBook>(
  AsyncValue<List<T>> source,
  String? account,
  BookDirectoryStatus status,
) {
  final books = source.whenData(
    (values) => values
        .where((book) => !book.isCloud || book.scopeAccountId == account)
        .toList(),
  );
  if (account == null || books.value?.isNotEmpty == true || books.hasError) {
    return books;
  }
  return switch (status) {
    BookDirectoryStatus.ready => books,
    BookDirectoryStatus.failed => AsyncError(
      StateError('BOOK_DIRECTORY_FAILED'),
      StackTrace.current,
    ),
    _ => const AsyncLoading(),
  };
}

AsyncValue<T?> selectedPrivateBook<T extends PrivateBook>(
  AsyncValue<List<T>> books,
  AsyncValue<String?> id,
) {
  if ((!books.hasValue && books.isLoading) || books.hasError) {
    return books.whenData((_) => null);
  }
  return id.whenData(
    (value) => books.value?.where((book) => book.id == value).firstOrNull,
  );
}
