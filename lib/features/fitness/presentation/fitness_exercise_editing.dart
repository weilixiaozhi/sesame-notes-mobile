import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/private_book.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/features/fitness/application/fitness_actions.dart';
import 'package:sesame_notes/features/fitness/application/fitness_catalog_provider.dart';
import 'package:sesame_notes/features/fitness/application/fitness_providers.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';
import 'package:sesame_notes/navigation/route_consts.dart';
import 'package:sesame_notes/shared/widgets/app_dialog.dart';
import 'package:sesame_notes/shared/widgets/toast.dart';
import 'package:uuid/uuid.dart';

/// 动作编辑只传递稳定身份，父页面负责异步流程和最新草稿。
sealed class FitnessExerciseEditIntent {
  /// 每次操作固定自己的意图，等待期间不复用旧列表下标。
  const FitnessExerciseEditIntent();
}

/// 在当前列表末尾添加选中的动作。
final class AddFitnessExercises extends FitnessExerciseEditIntent {
  /// 添加操作不绑定已有动作实例。
  const AddFitnessExercises();
}

/// 替换指定实例的目录动作，保留实例和组的身份。
final class ReplaceFitnessExercise extends FitnessExerciseEditIntent {
  /// 记录实例身份，列表重排不会改变替换目标。
  const ReplaceFitnessExercise(this.instanceId);
  final String instanceId;
}

/// 删除指定实例，其它动作的当前位置不影响删除目标。
final class DeleteFitnessExercise extends FitnessExerciseEditIntent {
  /// 删除仅携带稳定实例身份，不复用菜单打开时的列表下标。
  const DeleteFitnessExercise(this.instanceId);
  final String instanceId;
}

/// 由指定实例确定目录动作，切换当前草稿内该动作的重量口径。
final class SetFitnessExerciseWeightMode extends FitnessExerciseEditIntent {
  /// 模式变更在偏好保存成功后应用到当前列表。
  const SetFitnessExerciseWeightMode(this.instanceId, this.enabled);
  final String instanceId;
  final bool enabled;
}

/// 一次成功编辑同时发布动作列表和已经持久化的偏好回执。
class FitnessExerciseEditResult {
  /// 普通动作编辑只改变列表，重量口径同时携带成功的偏好快照。
  const FitnessExerciseEditResult({
    required this.exercises,
    this.confirmedPreferences,
  });
  final List<FitnessExercise> exercises;
  final FitnessPreferences? confirmedPreferences;
}

/// 保留已提交成功但订阅尚未追平的偏好，避免界面口径与迁移后的组数据错位。
class FitnessEditingPreferences {
  FitnessPreferences? _confirmed;
  PrivateBookTarget? _target;

  /// 只接收原编辑目标的成功回执，请求提交前不覆盖显示状态。
  void accept(PrivateBookTarget target, FitnessPreferences? preferences) {
    if (preferences == null) return;
    if (preferences.id != target.bookId || preferences.updatedAt == null) {
      throw StateError('FITNESS_PREFERENCES_RECEIPT_INVALID');
    }
    _target = target;
    _confirmed = preferences;
  }

  /// 编辑目标失效时丢弃回执，切回旧空间也不会重新启用旧的显示覆盖。
  void clear() {
    _target = null;
    _confirmed = null;
  }

  /// 同目标订阅追平或超过回执版本后接管，未带版本的初始流不能覆盖已确认写入。
  FitnessPreferences resolve(
    PrivateBookTarget target,
    FitnessPreferences streamed,
  ) {
    final confirmed = _confirmed;
    if (confirmed == null) return streamed;
    if (_target == null || !matchesPrivateBookTarget(_target!, target)) {
      clear();
      return streamed;
    }
    // 首次云绑定允许从 null 建立身份，建立后便不能再沿用到其他同步时间线。
    _target = target;
    final confirmedAt = confirmed.updatedAt!;
    final streamedAt = streamed.updatedAt;
    if (identical(streamed, confirmed) ||
        streamedAt != null && !streamedAt.isBefore(confirmedAt)) {
      clear();
      return streamed;
    }
    return confirmed;
  }
}

/// 在父编辑页的会话内执行动作变更，目录刷新和子编辑器重建不改变写入目标。
///
/// [readCurrentExercises] 在草稿身份变化或记录失效时返回 null；合法会话返回
/// 当前列表，保证选择页打开期间的编辑或同步结果不会被旧列表覆盖。
Future<void> editFitnessExercises(
  BuildContext context,
  WidgetRef ref, {
  required PrivateBookTarget target,
  required FitnessExerciseEditIntent intent,
  required List<FitnessExercise>? Function() readCurrentExercises,
  required ValueChanged<FitnessExerciseEditResult> onChanged,
}) async {
  ProviderSubscription<Object?>? catalogSubscription;
  ProviderSubscription<Object?>? preferencesSubscription;

  /// 挂载状态先于 Ref 读取判断，离开的页面不会再访问已销毁的依赖。
  bool isCurrent() =>
      context.mounted &&
      matchesPrivateBookTarget(
        target,
        ref.read(fitnessActionsProvider).target,
      ) &&
      readCurrentExercises() != null;

  /// 替换和删除共用最新完成组确认；确认期间身份失效或实例消失时放弃操作。
  Future<bool> confirmCompletedSets(String instanceId) async {
    if (!context.mounted || !isCurrent()) return false;
    final source = readCurrentExercises()
        ?.where((item) => item.id == instanceId)
        .firstOrNull;
    if (source == null) return false;
    if (!source.sets.any((set) => set.completed)) return true;
    final l10n = AppLocalizations.of(context);
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.commonConfirm,
      message: l10n.fitnessCompletedChange,
    );
    return confirmed == true && isCurrent();
  }

  try {
    if (!isCurrent()) return;
    // 选择路由会暂停父页面的 watch；操作期间保持数据订阅，目录和偏好仍接收更新。
    catalogSubscription = ref.listenManual(fitnessCatalogProvider, (_, _) {});
    preferencesSubscription = ref.listenManual(
      fitnessPreferencesProvider,
      (_, _) {},
    );

    if (intent case DeleteFitnessExercise(:final instanceId)) {
      if (!await confirmCompletedSets(instanceId) || !isCurrent()) return;
      final current = readCurrentExercises();
      if (current == null || !current.any((item) => item.id == instanceId)) {
        return;
      }
      onChanged(
        FitnessExerciseEditResult(
          exercises: [
            for (final item in current)
              if (item.id != instanceId) item,
          ],
        ),
      );
      return;
    }

    if (intent case SetFitnessExerciseWeightMode(
      :final instanceId,
      :final enabled,
    )) {
      final source = readCurrentExercises()
          ?.where((item) => item.id == instanceId)
          .firstOrNull;
      if (source == null) return;
      final exerciseId = source.exerciseId;
      // 操作对象固定原空间；父页面在等待期间关闭键盘并禁止继续编辑。
      final confirmedPreferences = await ref
          .read(fitnessActionsProvider)
          .setExerciseSideWeight(exerciseId, enabled);
      if (!isCurrent()) return;
      final current = readCurrentExercises();
      if (current == null) return;
      onChanged(
        FitnessExerciseEditResult(
          exercises: fitnessSetExerciseWeightMode(
            current,
            exerciseId: exerciseId,
            sideWeight: enabled,
          ),
          confirmedPreferences: confirmedPreferences,
        ),
      );
      return;
    }

    final replacing = intent is ReplaceFitnessExercise
        ? intent.instanceId
        : null;
    if (replacing != null &&
        !readCurrentExercises()!.any((item) => item.id == replacing)) {
      return;
    }
    if (!context.mounted) return;
    final ids = await context.pushNamed<List<String>>(
      Routes.fitnessExercises,
      extra: replacing == null ? 'select' : 'replace',
    );
    if (ids == null || ids.isEmpty || !isCurrent()) return;

    // 动作库允许现场创建自定义动作，返回后等待最新目录，不能复用打开时的快照。
    final catalog = await ref.read(fitnessCatalogProvider.future);
    if (!isCurrent()) return;

    if (replacing != null) {
      if (ids.length != 1) {
        throw StateError('FITNESS_REPLACEMENT_REQUIRES_ONE_EXERCISE');
      }
      final definition = catalog
          .where((item) => item.id == ids.single)
          .firstOrNull;
      if (definition == null ||
          !definition.isEnabled ||
          definition.custom?.deleted == true) {
        throw StateError('FITNESS_SELECTED_EXERCISE_UNAVAILABLE');
      }
      if (!await confirmCompletedSets(replacing) || !isCurrent()) return;
      final current = readCurrentExercises();
      if (current == null || !current.any((item) => item.id == replacing)) {
        return;
      }
      onChanged(
        FitnessExerciseEditResult(
          exercises: [
            for (final item in current)
              item.id == replacing
                  ? fitnessReplaceExercise(item, exerciseId: definition.id)
                  : item,
          ],
        ),
      );
      return;
    }

    final preferences = await ref.read(fitnessPreferencesProvider.future);
    if (!isCurrent()) return;
    final added = <FitnessExercise>[];
    for (final id in ids) {
      final definition = catalog.where((item) => item.id == id).firstOrNull;
      // 目录项已被删除时整次选择保留原稿，避免只加入部分动作却没有反馈。
      if (definition == null ||
          !definition.isEnabled ||
          definition.custom?.deleted == true) {
        throw StateError('FITNESS_SELECTED_EXERCISE_UNAVAILABLE');
      }
      final rest = preferences.exerciseRestSettings[id];
      added.add(
        FitnessExercise(
          id: const Uuid().v4(),
          exerciseId: id,
          restSeconds: rest?.restSeconds ?? preferences.defaultRestSeconds,
          warmupRestSeconds:
              rest?.warmupRestSeconds ??
              preferences.defaultWarmupRestSeconds ??
              preferences.defaultRestSeconds,
          sets: [FitnessSet(id: const Uuid().v4())],
        ),
      );
    }
    // 所有异步读取结束后才取草稿，期间新增、删除或改组的数据都保留。
    final current = readCurrentExercises();
    if (current != null) {
      onChanged(FitnessExerciseEditResult(exercises: [...current, ...added]));
    }
  } catch (error, stackTrace) {
    logger.error(
      'FitnessExerciseEditing',
      '动作编辑失败，保留当前草稿',
      safeErrorSummary(error),
      stackTrace,
    );
    if (context.mounted) {
      final l10n = AppLocalizations.of(context);
      showToast(
        context,
        intent is SetFitnessExerciseWeightMode
            ? l10n.fitnessSaveFailed
            : l10n.fitnessLoadFailed,
      );
    }
  } finally {
    catalogSubscription?.close();
    preferencesSubscription?.close();
  }
}
