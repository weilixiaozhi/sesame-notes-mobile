import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/fitness_custom_exercise.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/data/repositories/contracts/fitness_repositories.dart';
import 'package:sesame_notes/shared/application/support/action_error_boundary.dart';
import 'package:sesame_notes/shared/providers/fitness_repository_provider.dart';

/// 健身页面的操作边界，固定仓储目标并在写入前组合当前持久状态。
class FitnessActions {
  /// 绑定已按账号、会话代次和空间隔离的仓储。
  FitnessActions({
    required FitnessQueryRepository queryPort,
    required FitnessWorkoutRepository workoutPort,
    required FitnessLibraryWriteRepository libraryPort,
    required FitnessPreferencesRepository preferencesPort,
  }) : _queries = queryPort,
       _workouts = workoutPort,
       _library = libraryPort,
       _preferences = preferencesPort;

  final FitnessQueryRepository _queries;
  final FitnessWorkoutRepository _workouts;
  final FitnessLibraryWriteRepository _library;
  final FitnessPreferencesRepository _preferences;

  /// 编辑器保留此目标，切本或换号时不会把草稿转交给新空间。
  PrivateBookTarget get target => _workouts.target;

  /// 统一保留领域错误类型，页面只负责把错误映射为本地化文案。
  Future<T> _run<T>(String operation, Future<T> Function() action) =>
      runApplicationAction('FitnessActions', operation, action);

  /// 刷新日程和三个列表快照，页面只处理一轮刷新的结果。
  Future<void> refreshLocalSnapshot() => _run('刷新本地健身快照', () async {
    await _workouts.refreshSchedule();
    await _queries.getWorkouts();
    await _queries.getPlans();
    await _queries.getTemplates();
  });

  /// 读取当前空间的健身偏好。
  Future<FitnessPreferences> getPreferences() =>
      _run('读取当前空间的健身偏好', () => _queries.getPreferences());

  /// 读取指定训练的最新状态。
  Future<FitnessWorkout?> getWorkout(String id) =>
      _run('读取指定训练的最新状态', () => _queries.getWorkout(id));

  /// 保存用户编辑的模板并登记同步意图。
  Future<FitnessTemplate> saveTemplate(FitnessTemplate template) =>
      _run('保存用户编辑的模板并登记同步意图', () => _library.saveTemplate(template));

  /// 复制或复用官方模板到当前空间。
  Future<FitnessTemplate> importCatalogTemplate(
    FitnessTemplate official, {
    String? reuseTemplateId,
  }) => _run(
    '复制或复用官方模板到当前空间',
    () => _library.importCatalogTemplate(
      official,
      reuseTemplateId: reuseTemplateId,
    ),
  );

  /// 原子保存官方计划及其使用的模板副本。
  Future<FitnessPlan> importCatalogPlan(
    FitnessPlan draft,
    Map<String, FitnessTemplate> officialTemplates, {
    Map<String, String> reusableTemplateIds = const {},
  }) => _run(
    '原子保存官方计划及其使用的模板副本',
    () => _library.importCatalogPlan(
      draft,
      officialTemplates,
      reusableTemplateIds: reusableTemplateIds,
    ),
  );

  /// 在当前空间复制模板并保持新身份。
  Future<FitnessTemplate> copyTemplate(String id, {String? name}) =>
      _run('在当前空间复制模板并保持新身份', () => _library.copyTemplate(id, name: name));

  /// 保存计划并按用户选择处理日程重建。
  Future<FitnessPlan> savePlan(FitnessPlan plan, {String? restartDate}) => _run(
    '保存计划并按用户选择处理日程重建',
    () => _library.savePlan(plan, restartDate: restartDate),
  );

  /// 创建未开始的训练供编辑。
  Future<FitnessWorkout> createBlankWorkout({
    String name = '训练',
    String? id,
    DateTime? scheduledDate,
  }) => _run(
    '创建未开始的训练供编辑',
    () => _workouts.createBlankWorkout(
      name: name,
      id: id,
      scheduledDate: scheduledDate,
    ),
  );

  /// 按已保存模板开始训练。
  Future<FitnessWorkout> startFromTemplate(String templateId) =>
      _run('按已保存模板开始训练', () => _workouts.startFromTemplate(templateId));

  /// 开始或继续指定训练。
  Future<FitnessWorkout> startWorkout(String id) =>
      _run('开始或继续指定训练', () => _workouts.startWorkout(id));

  /// 暂停训练并保存已累计时长。
  Future<FitnessWorkout> pauseWorkout(String id) =>
      _run('暂停训练并保存已累计时长', () => _workouts.pauseWorkout(id));

  /// 统一修改所选动作的休息设置。
  Future<FitnessPreferences> setExerciseRestSettings(
    Iterable<String> exerciseIds,
    FitnessExerciseRest setting,
  ) => _run(
    '统一修改所选动作的休息设置',
    () => _preferences.setExerciseRestSettings(exerciseIds, setting),
  );

  /// 修改动作的左右重量口径。
  Future<FitnessPreferences> setExerciseSideWeight(
    String exerciseId,
    bool enabled,
  ) => _run(
    '修改动作的左右重量口径',
    () => _preferences.setExerciseSideWeight(exerciseId, enabled),
  );

  /// 完成训练并结算运行与休息状态。
  Future<FitnessWorkout> finishWorkout(String id) =>
      _run('完成训练并结算运行与休息状态', () => _workouts.finishWorkout(id));

  /// 使用已保存训练更新来源模板。
  Future<FitnessTemplate> updateWorkoutTemplate(String workoutId) =>
      _run('使用已保存训练更新来源模板', () => _library.updateWorkoutTemplate(workoutId));

  /// 将已保存训练另存为新模板。
  Future<FitnessTemplate> saveWorkoutAsTemplate(
    String id, {
    required String name,
  }) => _run(
    '将已保存训练另存为新模板',
    () => _library.saveWorkoutAsTemplate(id, name: name),
  );

  /// 更新训练组完成状态并应用休息规则。
  Future<FitnessWorkout> setGroupCompleted(
    String workoutId,
    String exerciseId,
    String setId,
    bool completed,
  ) => _run(
    '更新训练组完成状态并应用休息规则',
    () => _workouts.setGroupCompleted(workoutId, exerciseId, setId, completed),
  );

  /// 开始指定时长的休息。
  Future<FitnessWorkout> startRest(String id, {required int seconds}) =>
      _run('开始指定时长的休息', () => _workouts.startRest(id, seconds: seconds));

  /// 暂停当前休息计时。
  Future<FitnessWorkout> pauseRest(String id) =>
      _run('暂停当前休息计时', () => _workouts.pauseRest(id));

  /// 继续当前休息计时。
  Future<FitnessWorkout> resumeRest(String id) =>
      _run('继续当前休息计时', () => _workouts.resumeRest(id));

  /// 结束当前休息。
  Future<FitnessWorkout> skipRest(String id) =>
      _run('结束当前休息', () => _workouts.skipRest(id));

  /// 调整当前休息剩余时长。
  Future<FitnessWorkout> adjustRest(String id, int deltaSeconds) =>
      _run('调整当前休息剩余时长', () => _workouts.adjustRest(id, deltaSeconds));

  /// 保存自定义动作定义到当前空间。
  Future<void> saveCustomExercise(FitnessCustomExercise exercise) =>
      _run('保存自定义动作定义到当前空间', () => _preferences.saveCustomExercise(exercise));

  /// 保存自定义动作的删除标记并清理置顶和休息偏好，历史训练保留动作引用。
  Future<void> deleteCustomExercise(String id) =>
      _run('删除自定义动作', () => _preferences.deleteCustomExercise(id));

  /// 保存当前空间的健身偏好。
  Future<FitnessPreferences> savePreferences(FitnessPreferences preferences) =>
      _run('保存当前空间的健身偏好', () => _preferences.savePreferences(preferences));

  /// 只覆盖可编辑字段，保留同步或休息计时刚写入的运行状态。
  Future<FitnessWorkout> saveWorkoutDraft(FitnessWorkout draft) =>
      _run('保存训练草稿', () async {
        final current = await _queries.getWorkout(draft.id);
        if (current == null) throw StateError('FITNESS_WORKOUT_MISSING');
        return _workouts.saveWorkout(
          current.copyWith(
            name: draft.name,
            scheduledDate: draft.scheduledDate,
            exercises: draft.exercises,
          ),
        );
      });

  /// 改名基于最新持久状态，不覆盖编辑器之外推进的计时与完成状态。
  Future<FitnessWorkout> renameWorkout(String id, String name) =>
      _run('修改训练名称', () async {
        final current = await _queries.getWorkout(id);
        if (current == null) throw StateError('FITNESS_WORKOUT_MISSING');
        return _workouts.saveWorkout(current.copyWith(name: name));
      });
}

/// 页面只消费应用操作；仓储及其数据库句柄不进入展示层。
final fitnessActionsProvider = Provider<FitnessActions>(
  (ref) => FitnessActions(
    queryPort: ref.watch(fitnessQueryRepositoryProvider),
    workoutPort: ref.watch(fitnessWorkoutRepositoryProvider),
    libraryPort: ref.watch(fitnessLibraryWriteRepositoryProvider),
    preferencesPort: ref.watch(fitnessPreferencesRepositoryProvider),
  ),
);
