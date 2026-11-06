import 'package:sesame_notes/shared/providers/current_private_book_provider.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/clock/local_clock.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/day_repository_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';
import 'package:sesame_notes/shared/providers/read_provider_future.dart';

/// 日期派生统一依赖当地今天，系统时区变化会使展示重新计算。
final dayTodayProvider = Provider<DateOnly>(
  (ref) => DateOnly.fromDateTime(ref.watch(localTodayProvider)),
);

/// 可访问本列表只包含本机及当前账号，父本空记录时仍保留。
final dayBooksProvider = StreamProvider<List<DayBook>>((ref) {
  return ref
      .watch(dayQueryRepositoryProvider)
      .watchBooks(accountId: ref.watch(currentAccountIdProvider));
});

/// 没有缓存时必须等目录发现完成；网络失败不能展示成从未创建过本子。
final dayBooksForDisplayProvider = Provider<AsyncValue<List<DayBook>>>(
  (ref) => privateBooksForDisplay(
    ref.watch(dayBooksProvider),
    ref.watch(currentAccountIdProvider),
    ref.watch(dayDirectoryStatusProvider),
  ),
);

/// 当前日子本选择按本机或账号分别保存，不影响财务账本。
final currentDayBookIdProvider =
    AsyncNotifierProvider<CurrentDayBookNotifier, String?>(
      CurrentDayBookNotifier.new,
    );

/// 启动解析、删除回落与显式选择使用同一个本子身份入口。
class CurrentDayBookNotifier extends CurrentPrivateBookNotifier {
  @override
  String get preferencePrefix => 'current_day_book_id';

  /// 身份依赖与选择读取同一目录版本，等待期间的新帧不能被旧快照覆盖。
  @override
  List<DayBook> watchDirectory() {
    ref.watch(dayBooksProvider.select((value) => privateBookIds(value.value)));
    return ref.read(dayBooksProvider).requireValue;
  }

  /// 选本复用目录流首帧，账号隔离由目录 Provider 的依赖维护。
  @override
  Future<void> waitForDirectory() async {
    await readProviderFutureFromRef(ref, dayBooksProvider.future);
  }

  @override
  Future<PrivateBookTarget> target(String id) =>
      ref.read(dayQueryRepositoryProvider).target(id);

  @override
  Future<DayBook> requireTarget(PrivateBookTarget target) =>
      ref.read(dayQueryRepositoryProvider).requireTarget(target);
}

/// UI 只接收纯模型，不依赖 Drift 行或网络 DTO。
final currentDayBookProvider = Provider<AsyncValue<DayBook?>>(
  (ref) => selectedPrivateBook(
    ref.watch(dayBooksForDisplayProvider),
    ref.watch(currentDayBookIdProvider),
  ),
);

/// 所有记录流按显式目标本和当前账号查询。
final dayEventsProvider = StreamProvider.autoDispose
    .family<List<DayEvent>, String>((ref, id) {
      return ref
          .watch(dayQueryRepositoryProvider)
          .watchEvents(id, accountId: ref.watch(currentAccountIdProvider));
    });

/// 编辑器打开时固定本子、账号和绑定，提交不跟随外部切本。
class DayEditorArgs {
  /// 记录编辑器打开时的本子与会话，异步保存不能换到新的身份。
  const DayEditorArgs({
    required this.book,
    required this.accountId,
    required this.generation,
    this.event,
    this.initialDate,
  });
  final DayBook book;
  final String? accountId;
  final int generation;
  final DayEvent? event;
  final DateOnly? initialDate;
}
