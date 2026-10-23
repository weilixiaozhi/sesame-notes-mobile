import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/shared/aa/aa_fields_utils.dart';
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';

void main() {
  test('原币编辑回显只转换持久化本位币，拒绝合计不一致', () {
    expect(
      originalSplitAmounts(
        {'a': '43.5', 'b': '29'},
        amount: '10',
        nativeAmount: '72.5',
        payerMemberId: 'a',
      ),
      {'a': '6', 'b': '4'},
    );
    expect(
      () => originalSplitAmounts(
        {'a': '6', 'b': '4'},
        amount: '10',
        nativeAmount: '72.5',
        payerMemberId: 'a',
      ),
      throwsFormatException,
    );
  });

  TestWidgetsFlutterBinding.ensureInitialized();

  group('aaRowsToEditModel', () {
    test('空行返回 null(全部成员运行时展开)', () {
      final model = aaRowsToEditModel(const []);
      expect(model.participantIds, isNull);
      expect(model.splits, isNull);
    });

    test('关系表行转换为参与人列表与金额映射', () {
      final rows = [
        TransactionSplitDisplay(memberId: 'u1', amount: '60.00'),
        TransactionSplitDisplay(memberId: 'v1', amount: '40.00'),
      ];
      final model = aaRowsToEditModel(rows);
      expect(model.participantIds, containsAll(['u1', 'v1']));
      expect(model.splits, {'u1': '60.00', 'v1': '40.00'});
    });
  });

  group('aaEditModelToSplitInputs', () {
    test('非指定分摊(aaMode=0/1)返回空列表(调用方清空关系表)', () {
      expect(
        aaEditModelToSplitInputs(aaMode: 0, splits: {'u1': '50.00'}),
        isEmpty,
      );
    });

    test('aaMode null(账本未开启 AA)返回 null 不更新', () {
      expect(aaEditModelToSplitInputs(aaMode: null, splits: null), isNull);
    });

    test('指定分摊按虚拟用户集合区分归属', () {
      final inputs = aaEditModelToSplitInputs(
        aaMode: 2,
        splits: {'u1': '60.00', 'v1': '40.00'},
      )!;
      expect(inputs, hasLength(2));
      final byKey = {for (final s in inputs) s.memberId: s};
      expect(byKey['u1']!.memberId, 'u1');
      expect(byKey['v1']!.memberId, 'v1');
    });

    test('指定分摊空映射返回空列表(调用方清空关系表)', () {
      expect(aaEditModelToSplitInputs(aaMode: 2, splits: const {}), isEmpty);
    });
  });
}
