import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/shared/providers/account_reminder_invalidation_provider.dart';

/// 验证身份失效事件由各提醒业务独立确认，并保留未处理的新事件。
void main() {
  test('没有明确失效事件时，首次订阅不要求清理系统提醒', () {
    final container = ProviderContainer();
    try {
      final state = container.read(accountReminderInvalidationProvider);
      expect(state.generation, 0);
      for (final kind in AccountReminderKind.values) {
        expect(state.isPending(kind), isFalse);
      }
    } finally {
      container.dispose();
    }
  });

  test('纪念日和健身分别确认自己的成功结果', () {
    final container = ProviderContainer();
    try {
      final notifier = container.read(
        accountReminderInvalidationProvider.notifier,
      );
      notifier.invalidateReminders();
      notifier.acknowledge(AccountReminderKind.days, 1);
      final state = container.read(accountReminderInvalidationProvider);
      expect(state.isPending(AccountReminderKind.days), isFalse);
      expect(state.isPending(AccountReminderKind.fitness), isTrue);
      notifier.acknowledge(AccountReminderKind.fitness, 1);
      expect(
        container
            .read(accountReminderInvalidationProvider)
            .isPending(AccountReminderKind.fitness),
        isFalse,
      );
    } finally {
      container.dispose();
    }
  });

  test('迟到、重复或越界确认不能消费新的身份失效事件', () {
    final container = ProviderContainer();
    try {
      final notifier = container.read(
        accountReminderInvalidationProvider.notifier,
      );
      notifier.invalidateReminders();
      notifier.invalidateReminders();
      notifier.acknowledge(AccountReminderKind.days, 1);
      notifier.acknowledge(AccountReminderKind.days, 0);
      notifier.acknowledge(AccountReminderKind.days, 3);
      final state = container.read(accountReminderInvalidationProvider);
      expect(state.generation, 2);
      expect(state.handledGeneration(AccountReminderKind.days), 1);
      expect(state.isPending(AccountReminderKind.days), isTrue);
    } finally {
      container.dispose();
    }
  });
}
