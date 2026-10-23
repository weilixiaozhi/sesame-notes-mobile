import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/features/days/application/day_providers.dart';
import 'package:sesame_notes/shared/providers/account_state_provider.dart';
import 'package:sesame_notes/shared/providers/sync_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('零缓存目录未完成时保持加载，失败可重试，ready才是真空态', () async {
    final container = ProviderContainer(
      overrides: [
        currentAccountIdProvider.overrideWithValue('account-a'),
        dayBooksProvider.overrideWithValue(const AsyncData([])),
        currentDayBookIdProvider.overrideWith(_NoBook.new),
      ],
    );
    addTearDown(container.dispose);
    await container.read(currentDayBookIdProvider.future);
    expect(container.read(currentDayBookProvider).isLoading, isTrue);
    container
        .read(dayDirectoryStatusProvider.notifier)
        .setStatus(BookDirectoryStatus.failed);
    expect(container.read(currentDayBookProvider).hasError, isTrue);
    container
        .read(dayDirectoryStatusProvider.notifier)
        .setStatus(BookDirectoryStatus.ready);
    expect(container.read(currentDayBookProvider).value, isNull);
    expect(container.read(currentDayBookProvider).isLoading, isFalse);
  });
}

/// 目录展示验收固定当前无选择，避免混入偏好加载流程。
class _NoBook extends CurrentDayBookNotifier {
  @override
  Future<String?> build() async => null;
}
