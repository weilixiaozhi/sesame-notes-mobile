import 'day_book.dart';

/// 按纪念日本汇总未确认数量，供本列表与退出账号的数据保护提示使用。
class DayBookSyncStatus {
  const DayBookSyncStatus({
    required this.dayBookId,
    this.book,
    required this.pendingCount,
    required this.rejectedCount,
    required this.conflictCount,
  });
  final String dayBookId;
  final DayBook? book;
  final int pendingCount;
  final int rejectedCount;
  final int conflictCount;
}
