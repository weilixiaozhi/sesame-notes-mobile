import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/models/day_event.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/features/settings/application/day_reminder_choices.dart';
import 'package:sesame_notes/shared/models/reminder_settings.dart';
import 'package:sesame_notes/shared/providers/reminder_settings_provider.dart';

/// 验证多选来源完整性，避免异步加载过程误清理已经选择的事项。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final stamp = DateTime.utc(2026, 10, 10);
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(logger.clear);

  /// 创建可独立控制可见性与删除状态的父本。
  DayBook book(
    String id, {
    String? name,
    bool stale = false,
    bool hidden = false,
    bool deleted = false,
  }) => DayBook(
    id: id,
    name: name ?? id,
    createdAt: stamp,
    updatedAt: stamp,
    isStale: stale,
    isHidden: hidden,
    deletedAt: deleted ? stamp : null,
  );

  /// 创建指定所属本、日期可读性与分类的事项快照。
  DayEvent event(
    String id,
    String bookId, {
    String? name,
    String category = DayCategory.anniversary,
    bool deleted = false,
    bool unreadable = false,
  }) => DayEvent(
    id: id,
    dayBookId: bookId,
    definition: DayEventDefinition(
      category: category,
      name: name ?? id,
      repeatType: DayRepeatType.yearly,
      statisticType: DayStatisticType.year,
      event: OriginalDate.solar(DateOnly(2020, 10, 10)),
    ),
    createdAt: stamp,
    updatedAt: stamp,
    deletedAt: deleted ? stamp : null,
    hasUnreadableDate: unreadable,
  );

  /// 隔离目录和事项流，让真实选择来源处理给定的异步状态。
  ProviderContainer container(
    AsyncValue<List<DayBook>> books,
    Map<String, AsyncValue<List<DayEvent>>> events,
  ) {
    final result = ProviderContainer(
      overrides: [
        dayBooksProvider.overrideWithValue(books),
        for (final entry in events.entries)
          dayEventsProvider(entry.key).overrideWithValue(entry.value),
        reminderSettingsProvider.overrideWith(_DisabledSettings.new),
      ],
    );
    addTearDown(result.dispose);
    return result;
  }

  test('通知关闭时仍汇集多个本中的可选事项，并保留同名事项身份', () {
    final value = container(
      AsyncData([book('second', name: 'B本'), book('first', name: 'A本')]),
      {
        'second': AsyncData([event('second-event', 'second', name: '同名')]),
        'first': AsyncData([event('first-event', 'first', name: '同名')]),
      },
    );
    expect(value.read(reminderSettingsProvider).notificationsEnabled, isFalse);
    expect(value.read(reminderSettingsProvider).daysEnabled, isFalse);
    final choices = value.read(dayReminderChoicesProvider).requireValue;
    expect(choices.map((choice) => choice.event.id), [
      'first-event',
      'second-event',
    ]);
    expect(choices.map((choice) => choice.bookName), ['A本', 'B本']);
  });

  test('排除失效、隐藏和删除父本及已删除、日期不可读和阶段事项', () {
    final unavailable = AsyncError<List<DayEvent>>(
      StateError('不可访问的父本不应读取事项'),
      StackTrace.current,
    );
    final value = container(
      AsyncData([
        book('valid'),
        book('stale', stale: true),
        book('hidden', hidden: true),
        book('deleted', deleted: true),
      ]),
      {
        'valid': AsyncData([
          event('anniversary', 'valid'),
          event('birthday', 'valid', category: DayCategory.birthday),
          event('countdown', 'valid', category: DayCategory.countdown),
          event('deleted-event', 'valid', deleted: true),
          event('unreadable', 'valid', unreadable: true),
          event('stage', 'valid', category: DayCategory.stage),
        ]),
        'stale': unavailable,
        'hidden': unavailable,
        'deleted': unavailable,
      },
    );
    expect(
      value
          .read(dayReminderChoicesProvider)
          .requireValue
          .map((choice) => choice.event.id),
      ['anniversary', 'birthday', 'countdown'],
    );
  });

  for (final failed in [false, true]) {
    test('目录${failed ? '失败' : '刷新'}时不返回缓存的旧选择', () {
      final error = StateError('目录读取失败');
      final state = _withPrevious<List<DayBook>>(
        failed ? AsyncError(error, StackTrace.current) : const AsyncLoading(),
        AsyncData([book('old')]),
      );
      final value = container(state, {
        'old': AsyncData([event('old-event', 'old')]),
      });
      final choices = value.read(dayReminderChoicesProvider);
      expect(choices.hasValue, isFalse);
      expect(choices.isLoading, !failed);
      expect(choices.hasError, failed);
      if (failed) expect(choices.error, same(error));
    });

    test('任一本事项${failed ? '失败' : '刷新'}时不返回部分或缓存选择', () {
      final error = StateError('事项读取失败');
      final pending = _withPrevious<List<DayEvent>>(
        failed ? AsyncError(error, StackTrace.current) : const AsyncLoading(),
        AsyncData([event('old-event', 'second')]),
      );
      final value = container(AsyncData([book('first'), book('second')]), {
        'first': AsyncData([event('available', 'first')]),
        'second': pending,
      });
      final choices = value.read(dayReminderChoicesProvider);
      expect(choices.hasValue, isFalse);
      expect(choices.isLoading, !failed);
      expect(choices.hasError, failed);
      if (failed) expect(choices.error, same(error));
    });
  }

  test('完整加载且没有可选事项时才返回成功空列表', () {
    final value = container(AsyncData([book('empty')]), {
      'empty': const AsyncData([]),
    });
    final choices = value.read(dayReminderChoicesProvider);
    expect(choices.isLoading, isFalse);
    expect(choices.hasError, isFalse);
    expect(choices.requireValue, isEmpty);
  });
}

/// 构造 Riverpod 刷新期间携带旧值的快照，检查旧值不会作为完整选择发布。
AsyncValue<T> _withPrevious<T>(AsyncValue<T> state, AsyncValue<T> previous) {
  // ignore: invalid_use_of_internal_member
  return state.copyWithPrevious(previous);
}

/// 固定通知关闭，避免测试依赖设备通知权限或真实偏好加载。
class _DisabledSettings extends ReminderSettingsNotifier {
  /// 提供已加载且全部提醒关闭的设置。
  @override
  ReminderSettings build() =>
      const ReminderSettings(isEnabled: false, hour: 21, minute: 0);
}
