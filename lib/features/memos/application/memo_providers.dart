import '../../../shared/providers/current_private_book_provider.dart';
import '../../../data/models/private_book.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/memo.dart';
import '../../../data/models/memo_order.dart';
import '../infrastructure/memo_name_order.dart';
import '../../../infrastructure/api/api_client_provider.dart';
import '../../../shared/providers/account_state_provider.dart';
import '../../../shared/providers/memo_repository_provider.dart';
import '../../../shared/providers/simple_state_notifier.dart';
import '../../../shared/providers/sync_providers.dart';
import '../../../shared/application/support/action_error_boundary.dart';

/// 会话失效时留在内存的草稿按原账号与条目隔离，不写入日志或其他账号。
final memoProtectedDraftsProvider =
    NotifierProvider<
      SimpleStateNotifier<Map<String, MemoEntry>>,
      Map<String, MemoEntry>
    >(() => SimpleStateNotifier((ref) => {}));
String memoDraftKey(String? account, String entryId) =>
    '${account ?? 'local'}:$entryId';

final memoBooksProvider = StreamProvider<List<MemoBook>>(
  (ref) => ref
      .watch(memoQueryRepositoryProvider)
      .watchBooks(accountId: ref.watch(currentAccountIdProvider)),
);

/// 按本子类型取分组：本子管理分组标题、当前本与新增目标共用同一口径。
final memoBooksByTypeProvider =
    Provider.family<AsyncValue<List<MemoBook>>, String>(
      (ref, type) => ref
          .watch(memoBooksProvider)
          .whenData(
            (values) => values.where((book) => book.type == type).toList(),
          ),
    );

/// 备忘录本与账号密码本并存，管理页按类型分成两个分组展示。
final memoNormalBooksProvider = Provider<AsyncValue<List<MemoBook>>>(
  (ref) => ref.watch(memoBooksByTypeProvider(memoBookTypeNormal)),
);

final memoCredentialBooksProvider = Provider<AsyncValue<List<MemoBook>>>(
  (ref) => ref.watch(memoBooksByTypeProvider(memoBookTypeCredentials)),
);

/// 账号密码条目的列表查询：当前本 + 关键词，关键词在 SQL 内过滤。
typedef CredentialEntriesQuery = ({
  String bookId,
  int limit,
  String search,
  CredentialSort sort,
});

/// 中文名称比较只接收卡片名称和身份，可在测试中注入系统排序器。
final memoNameOrderProvider = Provider<MemoNameOrder>((ref) => MemoNameOrder());

/// 账号密码列表只展示当前选中的账号密码本。
final memoCredentialEntriesProvider = StreamProvider.autoDispose
    .family<List<MemoEntry>, CredentialEntriesQuery>(
      (ref, query) => ref
          .watch(memoQueryRepositoryProvider)
          .watchCredentialEntries(
            bookId: query.bookId,
            accountId: ref.watch(currentAccountIdProvider),
            limit: query.sort == CredentialSort.title ? null : query.limit,
            search: query.search,
            sort: query.sort,
          )
          .asyncMap((entries) async {
            if (query.sort != CredentialSort.title) return entries;
            final sorted = await ref.read(memoNameOrderProvider).sort(entries);
            return sorted.take(query.limit).toList();
          }),
    );

/// 两类本子各有自己的当前本，偏好 key 与目录监听互不影响；无本时不隐式创建。
abstract class CurrentMemoBookNotifierBase extends CurrentPrivateBookNotifier {
  /// 只在本类型内选本：普通笔记与账号密码卡片不会互相抢占当前本。
  String get bookType;

  @override
  void watchDirectory() {
    ref.watch(
      memoBooksByTypeProvider(
        bookType,
      ).select((value) => privateBookIds(value.value)),
    );
  }

  @override
  Future<List<MemoBook>> loadBooks(String? account) async =>
      (await ref
              .watch(memoQueryRepositoryProvider)
              .getBooks(accountId: account))
          .where((book) => book.type == bookType)
          .toList();
  @override
  Future<PrivateBookTarget> target(String id) =>
      ref.read(memoQueryRepositoryProvider).target(id);

  /// 选择前后同时复核所属类型，两种本子的当前偏好不能互相写入。
  @override
  Future<MemoBook> requireTarget(PrivateBookTarget target) =>
      runApplicationAction('MemoBookSelection', '校验选本类型', () async {
        final book = await ref
            .read(memoQueryRepositoryProvider)
            .requireTarget(target);
        if (book.type != bookType) throw StateError('MEMO_BOOK_TYPE_CHANGED');
        return book;
      });
}

/// 备忘录本当前选择：只服务普通笔记列表、日历与工具页。
class CurrentMemoBookNotifier extends CurrentMemoBookNotifierBase {
  @override
  String get bookType => memoBookTypeNormal;
  @override
  String get preferencePrefix => 'current_memo_book_id';
}

/// 账号密码本当前选择：首页置顶入口与新增卡片都落在这一本上。
class CurrentCredentialBookNotifier extends CurrentMemoBookNotifierBase {
  @override
  String get bookType => memoBookTypeCredentials;
  @override
  String get preferencePrefix => 'current_credential_book_id';
}

final currentMemoBookIdProvider =
    AsyncNotifierProvider<CurrentMemoBookNotifier, String?>(
      CurrentMemoBookNotifier.new,
    );

final currentCredentialBookIdProvider =
    AsyncNotifierProvider<CurrentCredentialBookNotifier, String?>(
      CurrentCredentialBookNotifier.new,
    );

final currentMemoBookProvider = Provider<AsyncValue<MemoBook?>>(
  (ref) => selectedPrivateBook(
    privateBooksForDisplay(
      ref.watch(memoNormalBooksProvider),
      ref.watch(currentAccountIdProvider),
      ref.watch(memoDirectoryStatusProvider),
    ),
    ref.watch(currentMemoBookIdProvider),
  ),
);

final currentCredentialBookProvider = Provider<AsyncValue<MemoBook?>>(
  (ref) => selectedPrivateBook(
    privateBooksForDisplay(
      ref.watch(memoCredentialBooksProvider),
      ref.watch(currentAccountIdProvider),
      ref.watch(memoDirectoryStatusProvider),
    ),
    ref.watch(currentCredentialBookIdProvider),
  ),
);

/// 手势开始时固定完整会话和本子身份，同一本机本跨账号也属于不同操作目标。
final credentialOrderTargetProvider = Provider<PrivateBookTarget?>((ref) {
  final book = ref.watch(currentCredentialBookProvider).value;
  final accountId = ref.watch(currentAccountIdProvider);
  final generation = ref.watch(authIdentityGenerationProvider);
  if (book == null) return null;
  return (
    bookId: book.id,
    accountId: accountId,
    generation: generation,
    syncId: book.syncId,
  );
});

typedef MemoListQuery = ({String bookId, DateTime? date, int limit});

/// 导出选择读取全本摘要，避免默认全选只覆盖列表首屏。
final memoExportEntriesProvider = StreamProvider.autoDispose
    .family<List<MemoEntry>, String>(
      (ref, id) => ref
          .watch(memoQueryRepositoryProvider)
          .watchEntries(
            id,
            accountId: ref.watch(currentAccountIdProvider),
            limit: null,
          ),
    );

final memoEntriesProvider = StreamProvider.autoDispose
    .family<List<MemoEntry>, MemoListQuery>(
      (ref, query) => ref
          .watch(memoQueryRepositoryProvider)
          .watchEntries(
            query.bookId,
            accountId: ref.watch(currentAccountIdProvider),
            date: query.date,
            limit: query.limit,
          ),
    );
