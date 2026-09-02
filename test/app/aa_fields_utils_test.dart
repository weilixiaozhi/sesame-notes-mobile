/// AA 字段统一工具测试。
///
/// 锁定关系表(transaction_splits)与 UI 编辑模型之间的双向转换：
/// 1. aaRowsToEditModel:关系表行 → 参与人列表 + 指定金额映射(空行 → 全部成员语义);
/// 2. aaEditModelToSplitInputs:UI 模型 → 关系表写入行(虚拟用户归属区分、
///    非指定分摊返回 null 由调用方清空);
/// 3. 历史 JSON 兜底解析函数保持原语义。
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:sesame_notes/shared/aa/aa_fields_utils.dart';
import 'package:sesame_notes/data/models/transaction_metadata_display.dart';

void main() {
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
        aaEditModelToSplitInputs(
          aaMode: 0,
          splits: {'u1': '50.00'},
          virtualUserIds: const {},
        ),
        isEmpty,
      );
    });

    test('aaMode null(账本未开启 AA)返回 null 不更新', () {
      expect(
        aaEditModelToSplitInputs(
          aaMode: null,
          splits: null,
          virtualUserIds: const {},
        ),
        isNull,
      );
    });

    test('指定分摊按虚拟用户集合区分归属', () {
      final inputs = aaEditModelToSplitInputs(
        aaMode: 2,
        splits: {'u1': '60.00', 'v1': '40.00'},
        virtualUserIds: const {'v1'},
      )!;
      expect(inputs, hasLength(2));
      final byKey = {for (final s in inputs) s.memberId: s};
      expect(byKey['u1']!.memberId, 'u1');
      expect(byKey['v1']!.memberId, 'v1');
    });

    test('指定分摊空映射返回空列表(调用方清空关系表)', () {
      expect(
        aaEditModelToSplitInputs(
          aaMode: 2,
          splits: const {},
          virtualUserIds: const {},
        ),
        isEmpty,
      );
    });
  });

  group('parseAaParticipantIds(历史 JSON 兜底)', () {
    test('null / 空串 / 解析失败返回 null(全部成员)', () {
      expect(parseAaParticipantIds(null), isNull);
      expect(parseAaParticipantIds(''), isNull);
      expect(parseAaParticipantIds('not-json'), isNull);
    });

    test('合法 JSON 数组解析为参与人列表', () {
      expect(parseAaParticipantIds('["u1","u2"]'), ['u1', 'u2']);
    });
  });

  group('parseAaSplits(历史 JSON 兜底)', () {
    test('null / 空串 / 解析失败返回 null', () {
      expect(parseAaSplits(null), isNull);
      expect(parseAaSplits(''), isNull);
      expect(parseAaSplits('not-json'), isNull);
    });

    test('合法 JSON 对象解析为金额映射', () {
      expect(parseAaSplits('{"u1":"60.00"}'), {'u1': '60.00'});
    });
  });
}
