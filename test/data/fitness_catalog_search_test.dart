import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/fitness_catalog.dart';
import 'package:sesame_notes/features/settings/infrastructure/fitness_table_transfer.dart';

/// 搜索与表格导入共享正式名称，旧缓存中的附加字段不会变成匹配入口。
void main() {
  final definition = FitnessExerciseDefinition.fromJson({
    'id': '0025',
    'name_zh': '杠铃卧推',
    'name_zh_hant': '槓鈴臥推',
    'name_en': 'barbell bench press',
    'body_part': 'chest',
    'target': 'pectorals',
    'equipment': 'barbell',
    'gif_asset': '',
    'aliases': ['平板卧推'],
    'secondary_muscles': <String>[],
    'instructions_zh': <String>[],
    'instructions_zh_hant': <String>[],
    'instructions_en': <String>[],
  });

  test('查询正式中英繁体名称，不使用旧目录的附加名称', () {
    for (final name in ['杠铃卧推', '槓鈴臥推', 'BARBELL press']) {
      expect(definition.matchesSearch(name), isTrue, reason: name);
    }
    expect(definition.matchesSearch('平板卧推'), isFalse);
  });

  test('表格动作自动匹配正式名称，未匹配名称仍可由用户手动指定', () {
    final converter = FitnessTableConverter(
      [definition],
      {'手动指定动作': '0025'},
      DateTime.utc(2026, 10, 10),
      'fitness-space',
    );
    for (final name in ['杠铃卧推', '槓鈴臥推', 'BARBELL BENCH PRESS']) {
      expect(converter.detectExercise(name), '0025', reason: name);
    }
    expect(converter.detectExercise('平板卧推'), isNull);
    expect(() => converter.exerciseId('平板卧推'), throwsFormatException);
    expect(converter.exerciseId('手动指定动作'), '0025');
  });
}
