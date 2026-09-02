// 零碎 provider 补充测试。
//
// 覆盖：
//   - recordEditHistoryProvider：按 recordId 读取编辑历史。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';
import 'package:sesame_notes/data/repositories/local/local_repository.dart';
import 'package:sesame_notes/shared/providers/database_providers.dart';
import 'package:sesame_notes/features/statistics/application/record_history_providers.dart';

import '../helpers/test_isolation.dart';

class _MockRepo extends Mock implements LocalRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => resetGlobalTestState());

  test('recordEditHistoryProvider 按 recordId 返回历史列表', () async {
    final repo = _MockRepo();
    when(() => repo.getEditHistories(any())).thenAnswer(
      (_) async => [
        RecordEditHistory(
          id: 2,
          recordId: '7',
          version: 2,
          operatorMemberId: 'u1',
          summary: '改金额',
          createdAt: DateTime(2026, 8, 8),
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final histories = await container.read(
      recordEditHistoryProvider('7').future,
    );
    expect(histories.single.summary, '改金额');
    expect(histories.single.version, 2);
    expect(histories.single, isA<RecordEditHistoryDisplay>());
    verify(() => repo.getEditHistories('7')).called(1);
  });
}
