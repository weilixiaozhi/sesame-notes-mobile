import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_notes/data/models/day_book.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/repositories/contracts/day_repositories.dart';
import 'package:sesame_notes/data/repositories/contracts/fitness_repositories.dart';
import 'package:sesame_notes/data/repositories/contracts/memo_repositories.dart';
import 'package:sesame_notes/features/days/application/day_actions.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/features/memos/application/memo_actions.dart';
import 'package:sesame_notes/shared/providers/data_lifecycle_provider.dart';

/// 用例替身只实现公开端口，不依赖数据库结构或具体仓储。
class _Days extends Mock implements DayEntryRepository {}

/// 笔记保存只替换编辑端口，删除流程保持独立。
class _Memos extends Mock implements MemoEntryRepository {}

/// 训练查询与写入可分别替换，以验证编辑不会覆盖运行状态。
class _FitnessQueries extends Mock implements FitnessQueryRepository {}

/// 只接收训练状态写入，不向测试提供模板或偏好写能力。
class _FitnessWorkouts extends Mock implements FitnessWorkoutRepository {}

/// 本组不触发模板或计划操作。
class _FitnessLibrary extends Mock implements FitnessLibraryWriteRepository {}

/// 本组不触发偏好写入。
class _FitnessPreferences extends Mock
    implements FitnessPreferencesRepository {}

/// 本组不执行删除，不需装配跨域生命周期。
class _Lifecycle extends Mock implements DataLifecycleActions {}

/// 在不导入 Drift 或本地仓储的情况下验证应用用例的身份与编辑语义。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const workout = FitnessWorkout(
    id: 'workout',
    name: '原名称',
    scheduledDate: '2026-10-13',
    status: 'in_progress',
  );

  setUpAll(() => registerFallbackValue(workout));
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('日子查询通过端口复核代次，旧会话迟到结果不能发布', () async {
    final repository = _Days();
    var generation = 1;
    final pending = Completer<DayBook?>();
    when(() => repository.accountIdGetter).thenReturn(() => 'account');
    when(() => repository.generationGetter).thenReturn(() => generation);
    when(
      () => repository.getBook('book', accountId: 'account'),
    ).thenAnswer((_) => pending.future);
    final result = DayActions(
      repository,
      _Lifecycle(),
    ).getBook('book', accountId: 'account');
    final assertion = expectLater(result, throwsStateError);
    generation++;
    pending.complete(null);
    await assertion;
  });

  test('笔记保存固定父本，目标不一致时不能调用写端口', () async {
    final repository = _Memos();
    final entry = MemoEntry(
      id: 'entry',
      memoBookId: 'original',
      bookType: 'normal',
      title: '正文',
      createdAt: DateTime.utc(2026, 10, 13),
      updatedAt: DateTime.utc(2026, 10, 13),
    );
    const target = (
      bookId: 'other',
      accountId: null,
      generation: 0,
      syncId: null,
    );
    final actions = MemoActions(repository, _Lifecycle());
    await expectLater(actions.saveEntry(entry, target), throwsStateError);
    verifyNever(() => repository.saveEntry(entry, target));
  });

  test('训练编辑分别使用查询和写端口，保留最新运行状态', () async {
    final queries = _FitnessQueries();
    final workouts = _FitnessWorkouts();
    when(() => queries.getWorkout('workout')).thenAnswer((_) async => workout);
    when(() => workouts.saveWorkout(any())).thenAnswer(
      (invocation) async =>
          invocation.positionalArguments.single as FitnessWorkout,
    );
    final actions = FitnessActions(
      queryPort: queries,
      workoutPort: workouts,
      libraryPort: _FitnessLibrary(),
      preferencesPort: _FitnessPreferences(),
    );
    final saved = await actions.saveWorkoutDraft(
      workout.copyWith(name: '已编辑', status: 'scheduled'),
    );
    expect(saved.name, '已编辑');
    expect(saved.status, 'in_progress');
    verify(() => queries.getWorkout('workout')).called(1);
    verify(() => workouts.saveWorkout(any())).called(1);
  });
}
