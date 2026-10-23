import '../contracts/fitness_repositories.dart';
import 'package:sesame_notes/utils/wire_timestamp.dart';
import '../../models/fitness_custom_exercise.dart';
import 'fitness_space_repository.dart';
import '../../models/private_book.dart';
import 'dart:convert';
import 'package:drift/drift.dart' as d;
import 'package:uuid/uuid.dart';
import '../../db.dart';
import '../../models/fitness.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import '../support/change_recorder.dart';

/// 每个实例固定账号与会话代次；异步编辑不能在切号后落入另一账号。
class FitnessRepository
    implements
        FitnessQueryRepository,
        FitnessWorkoutRepository,
        FitnessLibraryWriteRepository,
        FitnessPreferencesRepository {
  final SesameDatabase db;
  final String spaceId;
  final String Function()? spaceIdGetter;
  final String? Function()? syncIdGetter;
  String? _boundSyncId;
  @override
  PrivateBookTarget get target => (
    bookId: spaceId,
    accountId: accountId,
    generation: generation,
    syncId: _boundSyncId,
  );
  final ChangeRecorder? changeRecorder;
  final String? Function() accountIdGetter;
  final int Function() generationGetter;
  final DateTime Function() clock;
  final String? accountId;
  final int generation;
  FitnessRepository(
    this.db, {
    this.changeRecorder,
    required this.spaceId,
    this.spaceIdGetter,
    this.syncIdGetter,
    String? syncId,
    String? Function()? accountIdGetter,
    int Function()? generationGetter,
    DateTime Function()? clock,
  }) : _boundSyncId = syncId,
       accountIdGetter = accountIdGetter ?? (() => null),
       generationGetter = generationGetter ?? (() => 0),
       clock = clock ?? DateTime.now,
       accountId = accountIdGetter?.call(),
       generation = generationGetter?.call() ?? 0;

  void _check() {
    if ((_boundSyncId != null &&
            syncIdGetter != null &&
            syncIdGetter!() != _boundSyncId) ||
        accountIdGetter() != accountId ||
        generationGetter() != generation ||
        (spaceIdGetter != null && spaceIdGetter!() != spaceId)) {
      throw const FitnessValidationException('FITNESS_SESSION_CHANGED');
    }
  }

  Future<FitnessSpace> _space() async {
    _check();
    final book = await FitnessSpaceRepository(
      db,
      accountIdGetter: accountIdGetter,
      generationGetter: generationGetter,
    ).getBook(spaceId, accountId: accountId);
    _check();
    if (book == null || book.isStale || !book.isComplete) {
      throw StateError('FITNESS_SPACE_UNAVAILABLE');
    }
    if (_boundSyncId != null && book.syncId != _boundSyncId) {
      throw StateError('FITNESS_TARGET_CHANGED');
    }
    _boundSyncId ??= book.syncId;
    return book;
  }

  d.Expression<bool> _scope(FitnessEntities e) =>
      e.fitnessSpaceId.equals(spaceId) &
      e.fitnessSpaceId.isInQuery(
        db.selectOnly(db.fitnessSpaces)
          ..addColumns([db.fitnessSpaces.id])
          ..where(
            db.fitnessSpaces.deletedAt.isNull() &
                db.fitnessSpaces.isHidden.equals(false) &
                db.fitnessSpaces.pendingLocalDelete.equals(false) &
                (db.fitnessSpaces.storageMode.equals('local') |
                    db.fitnessSpaces.scopeAccountId.equals(accountId ?? '')),
          ),
      );
  d.SimpleSelectStatement<FitnessEntities, FitnessEntityRow> _query(
    String type, {
    bool includeDeleted = false,
  }) => db.select(db.fitnessEntities)
    ..where(
      (e) =>
          _scope(e) &
          e.entityType.equals(type) &
          (includeDeleted ? const d.Constant(true) : e.deletedAt.isNull()),
    );
  Map<String, dynamic> _json(FitnessEntityRow row) => {
    ...jsonDecode(row.payload) as Map<String, dynamic>,
    'id': row.id,
  };
  Future<List<T>> _get<T>(
    String type,
    T Function(Map<String, dynamic>) parse, {
    bool includeDeleted = false,
  }) async {
    _check();
    final rows = await _query(type, includeDeleted: includeDeleted).get();
    _check();
    return rows.map((r) => parse(_json(r))).toList();
  }

  Stream<List<T>> _watch<T>(
    String type,
    T Function(Map<String, dynamic>) parse, {
    bool includeDeleted = false,
  }) => _query(type, includeDeleted: includeDeleted).watch().map((rows) {
    _check();
    return rows.map((r) => parse(_json(r))).toList();
  });
  @override
  Future<List<FitnessTemplate>> getTemplates() =>
      _get('fitness_template', FitnessTemplate.fromJson);
  @override
  Stream<List<FitnessTemplate>> watchTemplates() =>
      _watch('fitness_template', FitnessTemplate.fromJson);
  @override
  Future<List<FitnessPlan>> getPlans({bool includeDeleted = false}) => _get(
    'fitness_plan',
    FitnessPlan.fromJson,
    includeDeleted: includeDeleted,
  );
  @override
  Stream<List<FitnessPlan>> watchPlans({bool includeDeleted = false}) => _watch(
    'fitness_plan',
    FitnessPlan.fromJson,
    includeDeleted: includeDeleted,
  );
  @override
  Future<List<FitnessWorkout>> getWorkouts() =>
      _get('fitness_workout', FitnessWorkout.fromJson);

  /// 详情和提醒只读取目标训练，其他历史不进入 Dart 对象图。
  @override
  Stream<FitnessWorkout?> watchWorkout(String id) =>
      (_query(
        'fitness_workout',
      )..where((row) => row.id.equals(id))).watchSingleOrNull().map((row) {
        _check();
        return row == null ? null : FitnessWorkout.fromJson(_json(row));
      });

  d.SimpleSelectStatement<FitnessEntities, FitnessEntityRow> _runningQuery() =>
      _query('fitness_workout')
        ..where(
          (row) => const d.CustomExpression<bool>(
            "json_extract(payload,'\$.status')='in_progress'",
          ),
        )
        ..limit(1);
  @override
  Stream<FitnessWorkout?> watchRunningWorkout() =>
      _runningQuery().watchSingleOrNull().map((row) {
        _check();
        return row == null ? null : FitnessWorkout.fromJson(_json(row));
      });

  static const _visibleSpaceSql =
      "fitness_space_id IN (SELECT id FROM fitness_spaces WHERE deleted_at IS NULL AND is_hidden=0 AND pending_local_delete=0 AND (storage_mode='local' OR scope_account_id=?))";

  @override
  Stream<List<String>> watchRecentExerciseIds() => db
      .customSelect(
        "SELECT json_extract(e.value,'\$.exercise_id') AS exercise_id, max(json_extract(w.payload,'\$.run_segments[#-1].started_at')) AS last_used FROM fitness_entities w,json_each(w.payload,'\$.exercises') e WHERE w.fitness_space_id=? AND $_visibleSpaceSql AND w.entity_type='fitness_workout' AND w.deleted_at IS NULL AND json_array_length(w.payload,'\$.run_segments')>0 GROUP BY exercise_id ORDER BY last_used DESC,exercise_id",
        variables: [d.Variable(spaceId), d.Variable(accountId ?? '')],
        readsFrom: {db.fitnessEntities, db.fitnessSpaces},
      )
      .watch()
      .map((rows) {
        _check();
        return rows.map((r) => r.read<String>('exercise_id')).toList();
      });

  Stream<List<FitnessWorkout>> _watchWorkoutQuery(
    String predicate,
    List<d.Variable> parameters, {
    int? limit,
  }) => db
      .customSelect(
        "SELECT w.* FROM fitness_entities w WHERE w.fitness_space_id=? AND $_visibleSpaceSql AND w.entity_type='fitness_workout' AND w.deleted_at IS NULL AND ($predicate) ORDER BY json_extract(w.payload,'\$.run_segments[0].started_at') DESC,w.id ${limit == null ? '' : 'LIMIT ?'}",
        variables: [
          d.Variable(spaceId),
          d.Variable(accountId ?? ''),
          ...parameters,
          if (limit != null) d.Variable(limit),
        ],
        readsFrom: {db.fitnessEntities, db.fitnessSpaces},
      )
      .watch()
      .map((rows) {
        _check();
        return rows
            .map(
              (r) => FitnessWorkout.fromJson(
                _json(db.fitnessEntities.map(r.data)),
              ),
            )
            .toList();
      });

  /// 查询当前展示区间；跨午夜训练按时段重叠保留，日程日期与训练归档日期均参与。
  @override
  Stream<List<FitnessWorkout>> watchWorkoutsInRange(
    DateTime start,
    DateTime until, {
    bool calendar = false,
  }) {
    final utcStart = start.toUtc().toIso8601String(),
        utcEnd = until.toUtc().toIso8601String();
    const first = r"json_extract(w.payload,'$.run_segments[0].started_at')";
    const scheduled = r"json_extract(w.payload,'$.scheduled_date')";
    final predicate = calendar
        ? "$scheduled>=? AND $scheduled<? OR $first>=? AND $first<? OR EXISTS(SELECT 1 FROM json_each(w.payload,'\$.run_segments') s WHERE json_extract(s.value,'\$.started_at')<? AND (json_extract(s.value,'\$.ended_at') IS NULL OR json_extract(s.value,'\$.ended_at')>=?))"
        : "$first>=? AND $first<? OR $first IS NULL AND $scheduled>=? AND $scheduled<?";
    return _watchWorkoutQuery(
      predicate,
      calendar
          ? [
              d.Variable(fitnessDate(start)),
              d.Variable(fitnessDate(until)),
              d.Variable(utcStart),
              d.Variable(utcEnd),
              d.Variable(utcEnd),
              d.Variable(utcStart),
            ]
          : [
              d.Variable(utcStart),
              d.Variable(utcEnd),
              d.Variable(fitnessDate(start)),
              d.Variable(fitnessDate(until)),
            ],
    );
  }

  @override
  Stream<({DateTime? earliest, DateTime? latest})> watchWorkoutBounds() => db
      .customSelect(
        r"SELECT min(json_extract(payload,'$.run_segments[0].started_at')) AS earliest,max(json_extract(payload,'$.run_segments[0].started_at')) AS latest FROM fitness_entities WHERE fitness_space_id=? AND " +
            _visibleSpaceSql +
            r" AND entity_type='fitness_workout' AND deleted_at IS NULL AND json_extract(payload,'$.status')='completed'",
        variables: [d.Variable(spaceId), d.Variable(accountId ?? '')],
        readsFrom: {db.fitnessEntities, db.fitnessSpaces},
      )
      .watchSingle()
      .map((row) {
        _check();
        DateTime? date(String key) {
          final text = row.readNullable<String>(key);
          return text == null ? null : DateTime.parse(text).toLocal();
        }

        return (earliest: date('earliest'), latest: date('latest'));
      });

  @override
  Stream<List<FitnessWorkout>> watchExerciseHistory(
    String exerciseId, {
    int limit = 50,
  }) => _watchWorkoutQuery(
    r"EXISTS(SELECT 1 FROM json_each(w.payload,'$.exercises') e WHERE json_extract(e.value,'$.exercise_id')=? AND EXISTS(SELECT 1 FROM json_each(e.value,'$.sets') s WHERE json_extract(s.value,'$.completed')=1))",
    [d.Variable(exerciseId)],
    limit: limit,
  );

  @override
  Future<FitnessPreferences> getPreferences() async =>
      (await _get(
        'fitness_preferences',
        FitnessPreferences.fromJson,
      )).firstOrNull ??
      FitnessPreferences(id: spaceId);
  @override
  Stream<FitnessPreferences> watchPreferences() => _watch(
    'fitness_preferences',
    FitnessPreferences.fromJson,
  ).map((p) => p.firstOrNull ?? FitnessPreferences(id: spaceId));

  Future<FitnessEntityRow?> _row(
    String id,
    String type, {
    bool deleted = false,
  }) async {
    _check();
    final row = await (_query(
      type,
      includeDeleted: deleted,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    _check();
    return row;
  }

  Future<FitnessEntityRow> _require(String id, String type) async {
    final row = await _row(id, type);
    fitnessRequire(row != null && !row.isStale, 'FITNESS_ENTITY_UNAVAILABLE');
    return row!;
  }

  @override
  Future<FitnessWorkout?> getWorkout(String id) async {
    final row = await _row(id, 'fitness_workout');
    return row == null ? null : FitnessWorkout.fromJson(_json(row));
  }

  Future<T> _write<T>(Future<T> Function() work) => db.transaction(() async {
    _check();
    await _space();
    final result = await work();
    _check();
    return result;
  });

  Future<Map<String, dynamic>> _save(
    String type,
    String id,
    Map<String, dynamic> payload, {
    bool createOnly = false,
  }) async {
    _check();
    final space = await _space();
    validateFitnessId(id);
    final any = await (db.select(
      db.fitnessEntities,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    _check();
    fitnessRequire(
      any == null ||
          (any.fitnessSpaceId == spaceId &&
              any.entityType == type &&
              any.deletedAt == null &&
              !any.isStale),
      'FITNESS_ENTITY_UNAVAILABLE',
    );
    if (createOnly && any != null) return _json(any);
    final now = clock().toUtc();
    final latest = any?.updatedAt;
    final updated = latest != null && !now.isAfter(latest)
        ? latest.add(const Duration(milliseconds: 1))
        : now;
    final body = normalizeFitnessNames(
      {
        ...payload,
        'created_at': wireTimestamp(any?.createdAt ?? now),
        'updated_at': wireTimestamp(updated),
      }..remove('id'),
    );
    validateFitnessPayload(type, body);
    validateFitnessIdentity(type, id, body);
    // 已知来源只能属于当前空间；已删除或尚未下载的来源仍保留业务快照。
    final foreignSource = await db
        .customSelect(
          "SELECT 1 FROM json_tree(?) ref JOIN fitness_entities e ON e.id=ref.value WHERE ref.key IN ('source_plan_id','source_template_id') AND e.fitness_space_id!=? LIMIT 1",
          variables: [d.Variable(jsonEncode(body)), d.Variable(spaceId)],
        )
        .getSingleOrNull();
    fitnessRequire(foreignSource == null, 'FITNESS_SOURCE_SPACE');
    await db
        .into(db.fitnessEntities)
        .insertOnConflictUpdate(
          FitnessEntitiesCompanion(
            id: d.Value(id),
            entityType: d.Value(type),
            fitnessSpaceId: d.Value(spaceId),
            scopeAccountId: d.Value(space.scopeAccountId),
            storageMode: d.Value(space.storageMode),
            syncId: d.Value(space.syncId),
            serverRevision: d.Value(
              !space.isCloud ? null : any?.serverRevision ?? 0,
            ),
            payload: d.Value(jsonEncode(body)),
            createdAt: d.Value(any?.createdAt ?? now),
            updatedAt: d.Value(updated),
          ),
        );
    if (space.isCloud) {
      fitnessRequire(changeRecorder != null, 'FITNESS_SYNC_UNAVAILABLE');
      await changeRecorder!.recordFitnessChange(
        entityType: type,
        entityId: id,
        accountId: space.scopeAccountId!,
        fitnessSpaceId: spaceId,
        action: 'upsert',
        payload: jsonEncode(body),
        updatedAt: updated,
        baseRevision: any?.serverRevision ?? 0,
      );
    }
    _check();
    return {...body, 'id': id};
  }

  Future<void> _delete(String id, String type) => _write(() async {
    final space = await _space();
    final row = await _row(id, type, deleted: true);
    if (row == null || row.deletedAt != null) return;
    fitnessRequire(!row.isStale, 'FITNESS_ENTITY_UNAVAILABLE');
    final now = clock().toUtc();
    // 保留快照与 occurrence_key，计划删除也保留已经生成的休息标记。
    await (db.update(db.fitnessEntities)..where((e) => e.id.equals(id))).write(
      FitnessEntitiesCompanion(
        deletedAt: d.Value(now),
        updatedAt: d.Value(now),
      ),
    );
    if (space.isCloud) {
      fitnessRequire(changeRecorder != null, 'FITNESS_SYNC_UNAVAILABLE');
      await changeRecorder!.recordFitnessChange(
        entityType: type,
        entityId: id,
        accountId: space.scopeAccountId!,
        fitnessSpaceId: spaceId,
        action: 'delete',
        payload: '{}',
        updatedAt: now,
        baseRevision: row.serverRevision ?? 0,
      );
    }
  });

  @override
  Future<FitnessTemplate> saveTemplate(FitnessTemplate template) => _write(
    () async => FitnessTemplate.fromJson(
      await _save(
        'fitness_template',
        template.id.isEmpty ? const Uuid().v4() : template.id,
        template.toJson(),
      ),
    ),
  );
  Future<void> deleteTemplate(String id) => _delete(id, 'fitness_template');

  /// 导入官方模板；选择复用时再次核对同空间来源，原副本已删除则创建新副本。
  @override
  Future<FitnessTemplate> importCatalogTemplate(
    FitnessTemplate official, {
    String? reuseTemplateId,
  }) => _write(() async {
    final origin = official.catalogOrigin;
    fitnessRequire(
      official.id == origin?.itemId && origin?.source == 'official',
      'FITNESS_CATALOG_ORIGIN',
    );
    if (reuseTemplateId != null) {
      final reused = await _catalogTemplateCopy(
        reuseTemplateId,
        origin!.itemId,
      );
      if (reused != null) return reused;
    }
    return saveTemplate(
      official.copyWith(
        id: const Uuid().v4(),
        exercises: fitnessSnapshotExercises(official.exercises, newIds: true),
        createdAt: null,
        updatedAt: null,
      ),
    );
  });

  /// 在当前训练空间读取指定官方来源的有效模板副本。
  Future<FitnessTemplate?> _catalogTemplateCopy(
    String userTemplateId,
    String officialTemplateId,
  ) async {
    final row = await _row(userTemplateId, 'fitness_template');
    if (row == null || row.isStale) return null;
    final template = FitnessTemplate.fromJson(_json(row));
    fitnessRequire(
      template.catalogOrigin?.source == 'official' &&
          template.catalogOrigin?.itemId == officialTemplateId,
      'FITNESS_CATALOG_ORIGIN',
    );
    return template;
  }

  /// 在一次事务中复制计划实际使用的官方模板、重映射来源并保存用户计划。
  @override
  Future<FitnessPlan> importCatalogPlan(
    FitnessPlan draft,
    Map<String, FitnessTemplate> officialTemplates, {
    Map<String, String> reusableTemplateIds = const {},
  }) => _write(() async {
    final origin = draft.catalogOrigin;
    fitnessRequire(
      draft.id.isEmpty && origin?.source == 'official',
      'FITNESS_CATALOG_ORIGIN',
    );
    final referencedOfficialIds = {
      for (final day in draft.days)
        if (day.slot?.sourceTemplateId case final sourceId?)
          if (officialTemplates.containsKey(sourceId)) sourceId,
    };
    final mappedTemplates = <String, FitnessTemplate>{};
    for (final officialId in referencedOfficialIds) {
      final source = officialTemplates[officialId];
      fitnessRequire(
        source?.id == officialId &&
            source?.catalogOrigin?.itemId == officialId &&
            source?.catalogOrigin?.source == 'official',
        'FITNESS_CATALOG_ORIGIN',
      );
      final reusableId = reusableTemplateIds[officialId];
      final reused = reusableId == null
          ? null
          : await _catalogTemplateCopy(reusableId, officialId);
      // 选择的副本已被删除或失效时，用用户确认过的草稿内容建新副本，避免落库结果与预览不一致。
      final previewed = reused == null && reusableId != null
          ? _previewedSlot(draft, officialId)
          : null;
      final template =
          reused ??
          await saveTemplate(
            source!.copyWith(
              id: const Uuid().v4(),
              name: previewed?.name ?? source.name,
              exercises: fitnessSnapshotExercises(
                previewed?.exercises ?? source.exercises,
                newIds: true,
              ),
              createdAt: null,
              updatedAt: null,
            ),
          );
      mappedTemplates[officialId] = template;
    }
    // 每个安排节点、动作和组都重新生成身份，官方模板 ID 只保留在来源标记中。
    FitnessPlanDay mappedDay(FitnessPlanDay day) {
      final slot = day.slot;
      final template = mappedTemplates[slot?.sourceTemplateId];
      return FitnessPlanDay(
        dayIndex: day.dayIndex,
        slot: slot?.copyWith(
          id: const Uuid().v4(),
          sourceTemplateId: template?.id ?? slot.sourceTemplateId,
          name: template?.name ?? slot.name,
          exercises: fitnessSnapshotExercises(
            template?.exercises ?? slot.exercises,
            newIds: true,
          ),
        ),
      );
    }

    final mappedDays = [for (final day in draft.days) mappedDay(day)];
    return savePlan(
      draft.copyWith(
        id: '',
        days: mappedDays,
        generationState: const FitnessGenerationState(),
        pendingSchedule: null,
        createdAt: null,
        updatedAt: null,
      ),
    );
  });

  @override
  Future<FitnessTemplate> copyTemplate(String id, {String? name}) =>
      _write(() async {
        final old = FitnessTemplate.fromJson(
          _json(await _require(id, 'fitness_template')),
        );
        return saveTemplate(
          old.copyWith(
            id: const Uuid().v4(),
            name: name ?? old.name,
            exercises: fitnessSnapshotExercises(old.exercises, newIds: true),
          ),
        );
      });
  @override
  Future<FitnessPlan> savePlan(
    FitnessPlan plan, {
    String? restartDate,
  }) => _write(() async {
    final id = plan.id.isEmpty ? const Uuid().v4() : plan.id;
    final row = await _row(id, 'fitness_plan');
    final old = row == null ? null : FitnessPlan.fromJson(_json(row));
    final restarting =
        old != null &&
        old.status != 'in_progress' &&
        plan.status == 'in_progress';
    fitnessRequire(
      !restarting ||
          old.generationState.nextCycleStartDate == null ||
          restartDate != null,
      'FITNESS_START_DATE_REQUIRED',
    );
    fitnessRequire(restartDate == null || restarting, 'FITNESS_PLAN_STATUS');
    var next = plan.copyWith(
      id: id,
      generationState: old?.generationState ?? const FitnessGenerationState(),
      pendingSchedule: null,
    );
    if (restarting) {
      next = next.copyWith(startDate: restartDate ?? plan.startDate);
    }
    if (next.startDate != null) {
      fitnessParseDate(next.startDate!);
      fitnessRequire(
        !restarting && old != null && next.startDate == old.startDate ||
            next.startDate!.compareTo(fitnessDate(clock())) >= 0,
        'FITNESS_PAST_SCHEDULE',
      );
    }
    if (old != null &&
        old.generationState.nextCycleStartDate != null &&
        !restarting) {
      fitnessRequire(
        next.status == 'closed' || next.startDate == old.startDate,
        'FITNESS_START_DATE_IMMUTABLE',
      );
      final schedule = FitnessSchedule(
        cycleDays: next.cycleDays,
        days: next.days,
      );
      final changed =
          jsonEncode(schedule.toJson()) !=
          jsonEncode(
            FitnessSchedule(cycleDays: old.cycleDays, days: old.days).toJson(),
          );
      next = next.copyWith(
        cycleDays: old.cycleDays,
        days: old.days,
        pendingSchedule: changed ? schedule : null,
      );
    }
    validateFitnessSchedule(
      FitnessSchedule(cycleDays: plan.cycleDays, days: plan.days),
    );
    fitnessRequire(
      ['in_progress', 'closed'].contains(next.status),
      'FITNESS_PLAN_STATUS',
    );
    final result = await _generate(next, restart: restarting);
    if (restarting) {
      // 仅覆盖新周期日期内同一计划的旧训练；新周期编号不会复活旧发生身份。
      final end = result.plan.generationState.nextCycleStartDate!;
      final overwritten = await db
          .customSelect(
            r"SELECT id FROM fitness_entities WHERE fitness_space_id=? AND " +
                _visibleSpaceSql +
                r" AND entity_type='fitness_workout' AND deleted_at IS NULL AND json_extract(payload,'$.source_plan_id')=? AND json_extract(payload,'$.scheduled_date')>=? AND json_extract(payload,'$.scheduled_date')<?",
            variables: [
              d.Variable(spaceId),
              d.Variable(accountId ?? ''),
              d.Variable(id),
              d.Variable(next.startDate!),
              d.Variable(end),
            ],
          )
          .get();
      for (final workout in overwritten) {
        await _delete(workout.read<String>('id'), 'fitness_workout');
      }
    }
    await _saveGeneratedWorkouts(result.workouts);
    return FitnessPlan.fromJson(
      await _save('fitness_plan', id, result.plan.toJson()),
    );
  });

  Future<FitnessGenerationResult> _generate(
    FitnessPlan plan, {
    bool restart = false,
  }) async => fitnessGenerate(
    plan,
    fitnessDate(clock()),
    restart: restart,
    templates: {
      for (final template in await getTemplates()) template.id: template,
    },
    restSettings: (await getPreferences()).exerciseRestSettings,
  );

  Future<void> _saveGeneratedWorkouts(List<FitnessWorkout> workouts) async {
    for (final workout in workouts) {
      if (!await _occurrenceExists(workout)) {
        await _save(
          'fitness_workout',
          workout.id,
          workout.toJson(),
          createOnly: true,
        );
      }
    }
  }

  Future<void> deletePlan(String id) => _delete(id, 'fitness_plan');
  Future<bool> _occurrenceExists(FitnessWorkout workout) async {
    final rows = await db
        .customSelect(
          "SELECT id FROM fitness_entities WHERE entity_type='fitness_workout' AND fitness_space_id=? AND $_visibleSpaceSql AND (id=? OR json_extract(payload,'\$.occurrence_key')=?) LIMIT 1",
          variables: [
            d.Variable(spaceId),
            d.Variable(accountId ?? ''),
            d.Variable(workout.id),
            d.Variable(workout.occurrenceKey!),
          ],
          readsFrom: {db.fitnessEntities, db.fitnessSpaces},
        )
        .get();
    _check();
    return rows.isNotEmpty;
  }

  @override
  Future<void> refreshSchedule() => _write(() async {
    for (final plan in await getPlans()) {
      if (plan.status != 'in_progress') continue;
      final result = await _generate(plan);
      if (jsonEncode(result.plan.toJson()) == jsonEncode(plan.toJson())) {
        continue;
      }
      await _saveGeneratedWorkouts(result.workouts);
      await _save('fitness_plan', plan.id, result.plan.toJson());
    }
  });

  Future<void> _ensureNoRunning({String? except}) async {
    // 写事务直接读取，不订阅 UI 已缓存的流，避免等待本事务提交后才发出的快照。
    final row = await _runningQuery().getSingleOrNull();
    final running = row == null ? null : FitnessWorkout.fromJson(_json(row));
    _check();
    if (running != null && running.id != except) {
      throw FitnessRunningWorkoutException(running);
    }
  }

  /// 创建只保存未开始的训练，浏览和填写动作不累计用时。
  @override
  Future<FitnessWorkout> createBlankWorkout({
    String name = '训练',
    String? id,
    DateTime? scheduledDate,
  }) => _write(() async {
    final newId = id ?? const Uuid().v4();
    final old = await _row(newId, 'fitness_workout');
    if (old != null) {
      return FitnessWorkout.fromJson(
        _json(await _require(newId, 'fitness_workout')),
      );
    }
    return FitnessWorkout.fromJson(
      await _save(
        'fitness_workout',
        newId,
        FitnessWorkout(
          id: newId,
          name: name.trim().isEmpty ? '训练' : name,
          scheduledDate: fitnessDate(scheduledDate ?? clock()),
        ).toJson(),
      ),
    );
  });

  @override
  Future<FitnessWorkout> startFromTemplate(String templateId) =>
      _write(() async {
        await _ensureNoRunning();
        final template = FitnessTemplate.fromJson(
          _json(await _require(templateId, 'fitness_template')),
        );
        final workout = FitnessWorkout(
          id: const Uuid().v4(),
          name: template.name,
          scheduledDate: fitnessDate(clock()),
          sourceKind: 'template',
          sourceTemplateId: template.id,
          exercises: fitnessSnapshotExercises(template.exercises),
        );
        await _save(
          'fitness_workout',
          workout.id,
          workout.toJson(),
          createOnly: true,
        );
        return startWorkout(workout.id);
      });
  @override
  Future<FitnessWorkout> startWorkout(String id) => _write(() async {
    final w = FitnessWorkout.fromJson(
      _json(await _require(id, 'fitness_workout')),
    );
    if (w.status == 'in_progress' && w.runSegments.last.endedAt == null) {
      return w;
    }
    await _ensureNoRunning(except: id);
    var now = clock().toUtc();
    // 系统时钟回拨时不制造重叠运行段，也不扣除已经记录的时长。
    final end = w.runSegments.lastOrNull?.endedAt;
    if (end != null && now.isBefore(end)) now = end;
    return FitnessWorkout.fromJson(
      await _save(
        'fitness_workout',
        id,
        w
            .copyWith(
              status: 'in_progress',
              runSegments: [
                ...w.runSegments,
                FitnessRunSegment(startedAt: now),
              ],
              restTimer: w.status == 'in_progress' ? w.restTimer : null,
            )
            .toJson(),
      ),
    );
  });
  @override
  Future<FitnessWorkout> pauseWorkout(String id) => _write(() async {
    final w = FitnessWorkout.fromJson(
      _json(await _require(id, 'fitness_workout')),
    );
    fitnessRequire(w.status == 'in_progress', 'FITNESS_NOT_RUNNING');
    final last = w.runSegments.last;
    if (last.endedAt != null) return w;
    final now = clock().toUtc();
    return FitnessWorkout.fromJson(
      await _save(
        'fitness_workout',
        id,
        w
            .copyWith(
              runSegments: [
                ...w.runSegments.take(w.runSegments.length - 1),
                last.copyWith(
                  endedAt: now.isBefore(last.startedAt) ? last.startedAt : now,
                ),
              ],
            )
            .toJson(),
      ),
    );
  });

  @override
  Future<FitnessPreferences> setExerciseRestSettings(
    Iterable<String> exerciseIds,
    FitnessExerciseRest setting,
  ) => _write(() async {
    final prefs = await getPreferences();
    final ids = exerciseIds.toSet();
    return savePreferences(
      prefs.copyWith(
        exerciseRestSettings: {
          ...prefs.exerciseRestSettings,
          for (final id in ids) id: setting,
        },
      ),
    );
  });

  /// 写入动作的重量口径（true 记录左右重量）；显式值优先于器械推导的默认值。
  @override
  Future<FitnessPreferences> setExerciseSideWeight(
    String exerciseId,
    bool enabled,
  ) => _write(() async {
    final prefs = await getPreferences();
    return savePreferences(
      prefs.copyWith(
        exerciseWeightModes: {
          ...prefs.exerciseWeightModes,
          exerciseId: enabled,
        },
      ),
    );
  });

  @override
  Future<FitnessWorkout> finishWorkout(String id) => _write(() async {
    var w = FitnessWorkout.fromJson(
      _json(await _require(id, 'fitness_workout')),
    );
    if (w.status == 'completed') return w;
    fitnessRequire(w.status == 'in_progress', 'FITNESS_NOT_RUNNING');
    final segments = [...w.runSegments], last = w.runSegments.last;
    final now = clock().toUtc();
    w = fitnessSettleRest(w, now);
    if (last.endedAt == null) {
      segments[segments.length - 1] = last.copyWith(
        endedAt: now.isBefore(last.startedAt) ? last.startedAt : now,
      );
    }
    return FitnessWorkout.fromJson(
      await _save(
        'fitness_workout',
        id,
        w
            .copyWith(
              status: 'completed',
              runSegments: segments,
              restTimer: null,
            )
            .toJson(),
      ),
    );
  });

  /// 仅保存可编辑配置，沿用持久化计时状态并复核每组完成条件。
  @override
  Future<FitnessWorkout> saveWorkout(FitnessWorkout workout) =>
      _write(() async {
        final old = FitnessWorkout.fromJson(
          _json(await _require(workout.id, 'fitness_workout')),
        );
        fitnessRequire(
          workout.status == old.status &&
              jsonEncode(workout.runSegments.map((s) => s.toJson()).toList()) ==
                  jsonEncode(old.runSegments.map((s) => s.toJson()).toList()),
          'FITNESS_USE_RUN_ACTION',
        );
        fitnessRequire(
          workout.scheduledDate == old.scheduledDate,
          'FITNESS_SCHEDULE_IMMUTABLE',
        );
        final exercises = workout.exercises.map((e) {
          final before = old.exercises.where((v) => v.id == e.id).firstOrNull;
          if (before != null && before.exerciseId != e.exerciseId) {
            return fitnessReplaceExercise(e, exerciseId: e.exerciseId);
          }
          return e.copyWith(
            sets: e.sets
                .map(
                  // 编辑只改成绩，保留全局计时器刚结算的休息记录；取消完成仍清空记录。
                  (s) => s.copyWith(
                    completed: s.completed && fitnessSetIsValid(s),
                    restDurationsSeconds:
                        before?.sets
                            .where((saved) => saved.id == s.id)
                            .firstOrNull
                            ?.restDurationsSeconds ??
                        s.restDurationsSeconds,
                  ),
                )
                .toList(),
          );
        }).toList();
        var next = old.copyWith(name: workout.name, exercises: exercises);
        final timer = next.restTimer;
        if (timer?.exerciseId != null &&
            !exercises.any(
              (e) =>
                  e.id == timer!.exerciseId &&
                  e.sets.any((s) => s.id == timer.setId && s.completed),
            )) {
          next = next.copyWith(
            restTimer: timer!.copyWith(exerciseId: null, setId: null),
          );
        }
        return FitnessWorkout.fromJson(
          await _save('fitness_workout', next.id, next.toJson()),
        );
      });

  /// 只有用户明确确认时，才用已保存的训练配置更新来源模板。
  @override
  Future<FitnessTemplate> updateWorkoutTemplate(String workoutId) =>
      _write(() async {
        final workout = FitnessWorkout.fromJson(
          _json(await _require(workoutId, 'fitness_workout')),
        );
        fitnessRequire(
          workout.sourceTemplateId != null,
          'FITNESS_TEMPLATE_MISSING',
        );
        fitnessRequire(workout.exercises.isNotEmpty, 'FITNESS_EMPTY_TEMPLATE');
        final template = FitnessTemplate.fromJson(
          _json(await _require(workout.sourceTemplateId!, 'fitness_template')),
        );
        return saveTemplate(
          template.copyWith(
            exercises: fitnessSnapshotExercises(workout.exercises),
          ),
        );
      });
  Future<void> deleteWorkout(String id) => _delete(id, 'fitness_workout');
  @override
  Future<FitnessTemplate> saveWorkoutAsTemplate(
    String id, {
    required String name,
  }) => _write(() async {
    final w = FitnessWorkout.fromJson(
      _json(await _require(id, 'fitness_workout')),
    );
    return saveTemplate(
      FitnessTemplate(
        name: name,
        exercises: fitnessSnapshotExercises(w.exercises, newIds: true),
      ),
    );
  });

  /// 组完成状态与首次开始、休息结算及下一次休息调度原子提交。
  @override
  Future<FitnessWorkout> setGroupCompleted(
    String workoutId,
    String exerciseId,
    String setId,
    bool completed,
  ) => _write(() async {
    var w = FitnessWorkout.fromJson(
      _json(await _require(workoutId, 'fitness_workout')),
    );
    var e = w.exercises.where((e) => e.id == exerciseId).firstOrNull;
    fitnessRequire(e != null, 'FITNESS_EXERCISE_ID');
    final set = e!.sets.where((s) => s.id == setId).firstOrNull;
    fitnessRequire(set != null, 'FITNESS_SET_ID');
    if (set!.completed == completed) return w;
    fitnessRequire(
      !completed || fitnessSetIsValid(set),
      'FITNESS_SET_INCOMPLETE',
    );
    // 任意有效组的首次勾选与开始计时在同一事务内；取消勾选不改运行时段。
    if (completed && w.status == 'scheduled') w = await startWorkout(workoutId);
    if (completed) {
      w = fitnessSettleRest(w, clock());
      e = w.exercises.firstWhere((e) => e.id == exerciseId);
    } else if (w.restTimer?.exerciseId == exerciseId &&
        w.restTimer?.setId == setId) {
      w = w.copyWith(
        restTimer: w.restTimer!.copyWith(exerciseId: null, setId: null),
      );
    }
    w = w.copyWith(
      exercises: w.exercises
          .map(
            (v) => v.id != exerciseId
                ? v
                : v.copyWith(
                    sets: v.sets
                        .map(
                          (s) => s.id == setId
                              ? s.copyWith(completed: completed)
                              : s,
                        )
                        .toList(),
                  ),
          )
          .toList(),
    );
    // 最后一组同样启动休息，训练由用户明确结束，避免丢失最后一组休息记录。
    if (completed && w.status == 'in_progress') {
      final setting =
          (await getPreferences()).exerciseRestSettings[e.exerciseId];
      final seconds = set.kind == 'warmup'
          ? setting?.warmupRestSeconds ?? e.warmupRestSeconds ?? e.restSeconds
          : setting?.restSeconds ?? e.restSeconds;
      w = w.copyWith(
        restTimer: seconds == 0
            ? null
            : FitnessRestTimer(
                endsAt: clock().toUtc().add(Duration(seconds: seconds)),
                remainingSeconds: seconds,
                durationSeconds: seconds,
                exerciseId: exerciseId,
                setId: setId,
              ),
      );
    }
    return FitnessWorkout.fromJson(
      await _save('fitness_workout', w.id, w.toJson()),
    );
  });
  Future<FitnessWorkout> _rest(
    String id,
    FitnessRestTimer? Function(FitnessRestTimer?) update, {
    bool settle = false,
  }) => _write(() async {
    var w = FitnessWorkout.fromJson(
      _json(await _require(id, 'fitness_workout')),
    );
    fitnessRequire(w.status == 'in_progress', 'FITNESS_NOT_RUNNING');
    final timer = w.restTimer;
    if (settle) w = fitnessSettleRest(w, clock());
    return FitnessWorkout.fromJson(
      await _save(
        'fitness_workout',
        id,
        w.copyWith(restTimer: update(timer)).toJson(),
      ),
    );
  });
  @override
  Future<FitnessWorkout> startRest(String id, {required int seconds}) {
    fitnessRequire(
      seconds >= 0 && seconds <= FitnessDefaults.maxInteger,
      'FITNESS_REST_TIMER',
    );
    return _rest(
      id,
      (r) => seconds == 0
          ? null
          : FitnessRestTimer(
              endsAt: clock().toUtc().add(Duration(seconds: seconds)),
              remainingSeconds: seconds,
              durationSeconds: seconds,
              exerciseId: r?.exerciseId,
              setId: r?.setId,
            ),
      settle: true,
    );
  }

  @override
  Future<FitnessWorkout> pauseRest(String id) => _rest(
    id,
    (r) => r?.copyWith(
      status: 'paused',
      endsAt: null,
      remainingSeconds: fitnessRestRemaining(r, clock()),
      elapsedSeconds: fitnessRestElapsed(r, clock()),
    ),
  );
  @override
  Future<FitnessWorkout> resumeRest(String id) => _rest(
    id,
    (r) => r == null || r.status == 'running'
        ? r
        : r.copyWith(
            status: 'running',
            endsAt: clock().toUtc().add(Duration(seconds: r.remainingSeconds)),
          ),
  );
  @override
  Future<FitnessWorkout> skipRest(String id) =>
      _rest(id, (_) => null, settle: true);
  @override
  Future<FitnessWorkout> adjustRest(String id, int deltaSeconds) =>
      _rest(id, (r) {
        if (r == null) return null;
        final seconds = (fitnessRestRemaining(r, clock()) + deltaSeconds).clamp(
          0,
          FitnessDefaults.maxInteger,
        );
        return r.copyWith(
          elapsedSeconds: fitnessRestElapsed(r, clock()),
          remainingSeconds: seconds,
          endsAt: r.status == 'running'
              ? clock().toUtc().add(Duration(seconds: seconds))
              : null,
        );
      });
  @override
  Future<void> saveCustomExercise(FitnessCustomExercise exercise) =>
      _write(() async {
        final prefs = await getPreferences();
        final items = [...prefs.customExercises];
        final index = items.indexWhere((e) => e.id == exercise.id);
        if (index < 0) {
          items.add(exercise);
        } else {
          fitnessRequire(!items[index].deleted, 'FITNESS_ENTITY_UNAVAILABLE');
          items[index] = exercise;
        }
        await _save(
          'fitness_preferences',
          spaceId,
          prefs.copyWith(customExercises: items).toJson(),
        );
      });

  @override
  Future<void> deleteCustomExercise(String id) => _write(() async {
    final prefs = await getPreferences();
    final items = prefs.customExercises
        .map(
          (e) => e.id != id
              ? e
              : FitnessCustomExercise.fromJson({
                  ...e.toJson(),
                  'deleted': true,
                  'image': null,
                }),
        )
        .toList();
    await _save(
      'fitness_preferences',
      spaceId,
      prefs
          .copyWith(
            customExercises: items,
            pinnedExerciseIds: prefs.pinnedExerciseIds
                .where((e) => e != id)
                .toList(),
            exerciseRestSettings: {...prefs.exerciseRestSettings}..remove(id),
          )
          .toJson(),
    );
  });

  @override
  Future<FitnessPreferences> savePreferences(FitnessPreferences preferences) =>
      _write(
        () async => FitnessPreferences.fromJson(
          await _save(
            'fitness_preferences',
            spaceId,
            preferences
                .copyWith(
                  customExercises: (await getPreferences()).customExercises,
                )
                .toJson(),
          ),
        ),
      );
}

/// 草稿中该官方模板对应的预览安排；没有引用时返回 null。
FitnessPlanSlot? _previewedSlot(FitnessPlan draft, String officialId) {
  for (final day in draft.days) {
    final slot = day.slot;
    if (slot != null && slot.sourceTemplateId == officialId) return slot;
  }
  return null;
}
