import 'package:flutter_test/flutter_test.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/fitness_custom_exercise.dart';
import 'package:sesame_notes/features/fitness/presentation/fitness_exercise_editing.dart';

const _target = (
  bookId: 'space',
  accountId: 'account',
  syncId: 'sync',
  generation: 1,
);

const _existingDefinition = FitnessCustomExercise(
  id: 'custom:existing',
  name: 'Existing exercise',
  bodyPart: 'chest',
  equipment: 'barbell',
  icon: 'dumbbell',
);

/// 验证编辑偏好回执的版本选择和账号、空间、绑定隔离。
void main() {
  group('编辑偏好成功回执', () {
    test('旧版本与初始无版本流沿用回执，等版本流到达后接管', () {
      final editing = FitnessEditingPreferences();
      final old = FitnessPreferences(
        id: _target.bookId,
        exerciseWeightModes: {_existingDefinition.id: false},
        updatedAt: DateTime.utc(2026),
      );
      final receipt = old.copyWith(
        exerciseWeightModes: {_existingDefinition.id: true},
        updatedAt: DateTime.utc(2027),
      );
      editing.accept(_target, null);
      expect(editing.resolve(_target, old), same(old));
      editing.accept(_target, receipt);
      expect(editing.resolve(_target, old), same(receipt));
      expect(
        editing.resolve(_target, FitnessPreferences(id: _target.bookId)),
        same(receipt),
      );

      final caughtUp = receipt.copyWith(defaultRestSeconds: 180);
      expect(editing.resolve(_target, caughtUp), same(caughtUp));
      // 流追平后归还所有字段的控制权，确认回执不再覆盖后续订阅。
      final later = caughtUp.copyWith(
        exerciseWeightModes: {_existingDefinition.id: false},
        updatedAt: DateTime.utc(2028),
      );
      expect(editing.resolve(_target, later), same(later));
    });

    test('流直接超过回执时采用更新偏好，不等待相同版本回显', () {
      final editing = FitnessEditingPreferences();
      final receipt = FitnessPreferences(
        id: _target.bookId,
        exerciseWeightModes: {_existingDefinition.id: true},
        updatedAt: DateTime.utc(2027),
      );
      final later = receipt.copyWith(
        exerciseWeightModes: {_existingDefinition.id: false},
        updatedAt: DateTime.utc(2028),
      );
      editing.accept(_target, receipt);
      expect(editing.resolve(_target, later), same(later));
    });

    for (final boundary in ['space', 'account', 'generation', 'binding']) {
      test('$boundary变化时丢弃旧回执，回到原目标也不会重新启用', () {
        final editing = FitnessEditingPreferences();
        final receipt = FitnessPreferences(
          id: _target.bookId,
          exerciseWeightModes: {_existingDefinition.id: true},
          updatedAt: DateTime.utc(2027),
        );
        final target = (
          bookId: boundary == 'space' ? 'other-space' : _target.bookId,
          accountId: boundary == 'account'
              ? 'other-account'
              : _target.accountId,
          generation: boundary == 'generation' ? 2 : _target.generation,
          syncId: boundary == 'binding' ? 'other-sync' : _target.syncId,
        );
        final streamed = FitnessPreferences(id: target.bookId);
        editing.accept(_target, receipt);

        expect(editing.resolve(target, streamed), same(streamed));
        final original = FitnessPreferences(id: _target.bookId);
        expect(editing.resolve(_target, original), same(original));
      });
    }

    test('首次同步绑定完成后锁定时间线，后续重绑不携带旧回执', () {
      final editing = FitnessEditingPreferences();
      final unbound = (
        bookId: _target.bookId,
        accountId: _target.accountId,
        generation: _target.generation,
        syncId: null,
      );
      final receipt = FitnessPreferences(
        id: _target.bookId,
        updatedAt: DateTime.utc(2027),
      );
      final streamed = FitnessPreferences(id: _target.bookId);
      editing.accept(unbound, receipt);
      expect(editing.resolve(_target, streamed), same(receipt));
      expect(
        editing.resolve((
          bookId: _target.bookId,
          accountId: _target.accountId,
          generation: _target.generation,
          syncId: 'replacement-binding',
        ), streamed),
        same(streamed),
      );
    });

    test('无版本或其他空间的回执被拒绝，不覆盖当前偏好', () {
      final editing = FitnessEditingPreferences();
      final initial = FitnessPreferences(id: _target.bookId);
      final receipt = FitnessPreferences(
        id: _target.bookId,
        exerciseWeightModes: {_existingDefinition.id: true},
        updatedAt: DateTime.utc(2027),
      );
      editing.accept(_target, receipt);
      for (final invalid in [
        receipt.copyWith(updatedAt: null),
        receipt.copyWith(id: 'other-space'),
      ]) {
        expect(() => editing.accept(_target, invalid), throwsStateError);
        expect(editing.resolve(_target, initial), same(receipt));
      }
    });
  });
}
