import '../../models/fitness.dart';
import '../../models/fitness_custom_exercise.dart';
import '../../models/private_book.dart';

/// 固定健身空间的列表、训练与偏好只读查询端口。
abstract interface class FitnessQueryRepository {
  /// 提供当前用例所需的 getTemplates 能力，身份与事务由实现维护。
  Future<List<FitnessTemplate>> getTemplates();

  /// 提供当前用例所需的 watchTemplates 能力，身份与事务由实现维护。
  Stream<List<FitnessTemplate>> watchTemplates();

  /// 提供当前用例所需的 getPlans 能力，身份与事务由实现维护。
  Future<List<FitnessPlan>> getPlans({bool includeDeleted = false});

  /// 提供当前用例所需的 watchPlans 能力，身份与事务由实现维护。
  Stream<List<FitnessPlan>> watchPlans({bool includeDeleted = false});

  /// 提供当前用例所需的 getWorkouts 能力，身份与事务由实现维护。
  Future<List<FitnessWorkout>> getWorkouts();

  /// 提供当前用例所需的 watchWorkout 能力，身份与事务由实现维护。
  Stream<FitnessWorkout?> watchWorkout(String id);

  /// 提供当前用例所需的 watchRunningWorkout 能力，身份与事务由实现维护。
  Stream<FitnessWorkout?> watchRunningWorkout();

  /// 提供当前用例所需的 watchRecentExerciseIds 能力，身份与事务由实现维护。
  Stream<List<String>> watchRecentExerciseIds();

  /// 提供当前用例所需的 watchWorkoutsInRange 能力，身份与事务由实现维护。
  Stream<List<FitnessWorkout>> watchWorkoutsInRange(
    DateTime start,
    DateTime until, {
    bool calendar = false,
  });

  /// 提供当前用例所需的 watchWorkoutBounds 能力，身份与事务由实现维护。
  Stream<({DateTime? earliest, DateTime? latest})> watchWorkoutBounds();

  /// 提供当前用例所需的 watchExerciseHistory 能力，身份与事务由实现维护。
  Stream<List<FitnessWorkout>> watchExerciseHistory(
    String exerciseId, {
    int limit = 50,
  });

  /// 读取当前固定空间的健身偏好。
  Future<FitnessPreferences> getPreferences();

  /// 提供当前用例所需的 watchPreferences 能力，身份与事务由实现维护。
  Stream<FitnessPreferences> watchPreferences();

  /// 提供当前用例所需的 getWorkout 能力，身份与事务由实现维护。
  Future<FitnessWorkout?> getWorkout(String id);
}

/// 训练与休息状态流转端口，所有写入保留原有事务。
abstract interface class FitnessWorkoutRepository {
  /// 固定操作目标的账号、会话代次与云端绑定。
  PrivateBookTarget get target;

  /// 按固定空间的计划原子更新训练日程。
  Future<void> refreshSchedule();

  /// 提供当前用例所需的 createBlankWorkout 能力，身份与事务由实现维护。
  Future<FitnessWorkout> createBlankWorkout({
    String name = '训练',
    String? id,
    DateTime? scheduledDate,
  });

  /// 提供当前用例所需的 startFromTemplate 能力，身份与事务由实现维护。
  Future<FitnessWorkout> startFromTemplate(String templateId);

  /// 提供当前用例所需的 startWorkout 能力，身份与事务由实现维护。
  Future<FitnessWorkout> startWorkout(String id);

  /// 提供当前用例所需的 pauseWorkout 能力，身份与事务由实现维护。
  Future<FitnessWorkout> pauseWorkout(String id);

  /// 提供当前用例所需的 finishWorkout 能力，身份与事务由实现维护。
  Future<FitnessWorkout> finishWorkout(String id);

  /// 提供当前用例所需的 saveWorkout 能力，身份与事务由实现维护。
  Future<FitnessWorkout> saveWorkout(FitnessWorkout workout);

  /// 提供当前用例所需的 setGroupCompleted 能力，身份与事务由实现维护。
  Future<FitnessWorkout> setGroupCompleted(
    String workoutId,
    String exerciseId,
    String setId,
    bool completed,
  );

  /// 提供当前用例所需的 startRest 能力，身份与事务由实现维护。
  Future<FitnessWorkout> startRest(String id, {required int seconds});

  /// 提供当前用例所需的 pauseRest 能力，身份与事务由实现维护。
  Future<FitnessWorkout> pauseRest(String id);

  /// 提供当前用例所需的 resumeRest 能力，身份与事务由实现维护。
  Future<FitnessWorkout> resumeRest(String id);

  /// 提供当前用例所需的 skipRest 能力，身份与事务由实现维护。
  Future<FitnessWorkout> skipRest(String id);

  /// 提供当前用例所需的 adjustRest 能力，身份与事务由实现维护。
  Future<FitnessWorkout> adjustRest(String id, int deltaSeconds);
}

/// 模板与计划编辑、官方内容复制及训练归档到模板的端口。
abstract interface class FitnessLibraryWriteRepository {
  /// 提供当前用例所需的 saveTemplate 能力，身份与事务由实现维护。
  Future<FitnessTemplate> saveTemplate(FitnessTemplate template);

  /// 提供当前用例所需的 importCatalogTemplate 能力，身份与事务由实现维护。
  Future<FitnessTemplate> importCatalogTemplate(
    FitnessTemplate official, {
    String? reuseTemplateId,
  });

  /// 提供当前用例所需的 importCatalogPlan 能力，身份与事务由实现维护。
  Future<FitnessPlan> importCatalogPlan(
    FitnessPlan draft,
    Map<String, FitnessTemplate> officialTemplates, {
    Map<String, String> reusableTemplateIds = const {},
  });

  /// 提供当前用例所需的 copyTemplate 能力，身份与事务由实现维护。
  Future<FitnessTemplate> copyTemplate(String id, {String? name});

  /// 提供当前用例所需的 savePlan 能力，身份与事务由实现维护。
  Future<FitnessPlan> savePlan(FitnessPlan plan, {String? restartDate});

  /// 提供当前用例所需的 updateWorkoutTemplate 能力，身份与事务由实现维护。
  Future<FitnessTemplate> updateWorkoutTemplate(String workoutId);

  /// 提供当前用例所需的 saveWorkoutAsTemplate 能力，身份与事务由实现维护。
  Future<FitnessTemplate> saveWorkoutAsTemplate(
    String id, {
    required String name,
  });
}

/// 健身偏好与自定义动作写入端口。
abstract interface class FitnessPreferencesRepository {
  /// 提供当前用例所需的 setExerciseRestSettings 能力，身份与事务由实现维护。
  Future<FitnessPreferences> setExerciseRestSettings(
    Iterable<String> exerciseIds,
    FitnessExerciseRest setting,
  );

  /// 提供当前用例所需的 setExerciseSideWeight 能力，身份与事务由实现维护。
  Future<FitnessPreferences> setExerciseSideWeight(
    String exerciseId,
    bool enabled,
  );

  /// 提供当前用例所需的 saveCustomExercise 能力，身份与事务由实现维护。
  Future<void> saveCustomExercise(FitnessCustomExercise exercise);

  /// 提供当前用例所需的 deleteCustomExercise 能力，身份与事务由实现维护。
  Future<void> deleteCustomExercise(String id);

  /// 提供当前用例所需的 savePreferences 能力，身份与事务由实现维护。
  Future<FitnessPreferences> savePreferences(FitnessPreferences preferences);
}
