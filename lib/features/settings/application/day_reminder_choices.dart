import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';

/// 每个选项保留所属本名，便于区分不同本中的同名纪念日。
typedef DayReminderChoice = ({String bookName, DayEvent event});

/// 提醒关闭时也能选择事项；只汇集当前账号可访问且日期可读的记录。
final dayReminderChoicesProvider =
    Provider.autoDispose<AsyncValue<List<DayReminderChoice>>>((ref) {
      try {
        final books = ref.watch(dayBooksProvider);
        if (books.isLoading) return const AsyncLoading();
        if (books.hasError) {
          Error.throwWithStackTrace(books.error!, books.stackTrace!);
        }
        final choices = <DayReminderChoice>[];
        var loading = false;
        for (final book in books.requireValue) {
          if (book.isStale || book.deletedAt != null || book.isHidden) continue;
          final events = ref.watch(dayEventsProvider(book.id));
          if (events.hasError) {
            Error.throwWithStackTrace(events.error!, events.stackTrace!);
          }
          loading |= events.isLoading;
          if (events.isLoading) continue;
          for (final event in events.requireValue) {
            if (event.deletedAt == null &&
                !event.hasUnreadableDate &&
                event.definition.category != DayCategory.stage) {
              choices.add((bookName: book.name, event: event));
            }
          }
        }
        // 必须等全部本加载完成后再确认，避免把暂未加载的已选项误当作删除。
        if (loading) return const AsyncLoading();
        choices.sort((left, right) {
          final bookOrder = left.bookName.compareTo(right.bookName);
          return bookOrder != 0
              ? bookOrder
              : left.event.definition.name.compareTo(
                  right.event.definition.name,
                );
        });
        return AsyncData(choices);
      } catch (error, stack) {
        logger.error('DayReminderChoices', '读取每日提醒可选纪念日失败', error, stack);
        return AsyncError(error, stack);
      }
    });
