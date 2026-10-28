/// Android 独立验收包使用的合成数据；仅操作调用方提供的隔离数据库。
library;

import 'dart:convert';

import 'package:drift/drift.dart' as d;
import 'package:sesame_notes/core/logging/logger_service.dart';
import 'package:sesame_notes/data/db.dart';
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/fitness_custom_exercise.dart';
import 'package:sesame_notes/data/models/memo.dart';
import 'package:sesame_notes/data/models/memo_fields.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/utils/member_id.dart';

const androidProbeLedgerId = 'a1000000-0000-4000-8000-000000000001';
const androidProbeMemoBookId = 'a1000000-0000-4000-8000-000000000002';
const androidProbeCredentialBookId = 'a1000000-0000-4000-8000-000000000003';
const androidProbeFitnessSpaceId = 'a1000000-0000-4000-8000-000000000004';
const androidProbeTemplateId = 'a1000000-0000-4000-8000-000000000005';
const androidProbePlanId = 'a1000000-0000-4000-8000-000000000006';
const androidProbeCustomExerciseId =
    'custom:a1000000-0000-4000-8000-000000000007';
const androidProbeTodayWorkoutId = 'a1000000-0000-4000-8000-000000000008';

/// 一像素 PNG 的各块校验值及压缩载荷已验证，图片只用于附件内容与解码边界。
const androidProbePng =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+ip1sAAAAASUVORK5CYII=';

/// 固定编号生成合法身份，使扩容只追加更早的记录。
String _id(int number) =>
    'a1000000-0000-4000-8000-${number.toString().padLeft(12, '0')}';

/// 普通笔记编号零对应锚点当天，供真实首页确认首条数据已经显示。
String androidProbeMemoId(int index) => _id(200000 + index);

/// 构造四个动作，每个动作包含热身与正式组；完成历史保留正式组休息记录。
List<FitnessExercise> _exercises(int seed, {required bool completed}) => [
  for (var index = 0; index < 4; index++)
    FitnessExercise(
      id: _id(seed + index * 10),
      exerciseId: index == 3 ? androidProbeCustomExerciseId : '0025',
      restSeconds: 90,
      warmupRestSeconds: 0,
      sets: [
        FitnessSet(id: _id(seed + index * 10 + 1), kind: 'warmup'),
        FitnessSet(
          id: _id(seed + index * 10 + 2),
          weight: '20.1250000001',
          reps: 8,
          completed: completed,
          restDurationsSeconds: completed ? const [17, 42] : const [],
        ),
      ],
    ),
];

/// 通过领域校验后构造持久化行，拒绝不符合产品协议的测试样本。
FitnessEntitiesCompanion _fitnessRow(
  String id,
  String type,
  Map<String, dynamic> payload,
  DateTime at,
) {
  validateFitnessPayload(type, payload);
  return FitnessEntitiesCompanion.insert(
    id: id,
    fitnessSpaceId: androidProbeFitnessSpaceId,
    entityType: type,
    payload: jsonEncode(payload),
    createdAt: at,
    updatedAt: at,
  );
}

/// 将固定 1、5、10 年档追加进同一隔离库；现存行和人工编辑始终保持原值。
///
/// 锚点由入口固定并持久化；日期倒推让每档都有当月账单和当天待开始训练。
/// 每年四笔日账、一篇日记、二十四张卡片、每周三次已完成训练，另有一个当天训练。
Future<void> seedAndroidProbeData(
  SesameDatabase db,
  int years, {
  required DateTime anchor,
  required String localSelfId,
}) async {
  try {
    if (![1, 5, 10].contains(years) || localSelfId.trim().isEmpty) {
      throw ArgumentError('验收数据需要 1、5、10 年档和有效本机身份');
    }
    final fixed = anchor.toUtc();
    final first = fixed.subtract(const Duration(days: 3650));
    final localAnchor = anchor.toLocal();
    final today = DateTime(localAnchor.year, localAnchor.month, localAnchor.day);
    final self = localSelfMemberId(androidProbeLedgerId, localSelfId);
    final template = FitnessTemplate(
      id: androidProbeTemplateId,
      name: '验收固定模板',
      exercises: _exercises(50000, completed: false),
      createdAt: first,
      updatedAt: first,
    );
    final plan = FitnessPlan(
      id: androidProbePlanId,
      name: '验收两日计划',
      status: 'closed',
      cycleDays: 2,
      days: [
        FitnessPlanDay(
          dayIndex: 0,
          slot: FitnessPlanSlot(
            id: _id(9),
            name: template.name,
            sourceTemplateId: template.id,
            exercises: _exercises(51000, completed: false),
          ),
        ),
        const FitnessPlanDay(dayIndex: 1),
      ],
      createdAt: first,
      updatedAt: first,
    );
    final preferences = FitnessPreferences(
      id: androidProbeFitnessSpaceId,
      soundEnabled: false,
      vibrationEnabled: false,
      customExercises: const [
        FitnessCustomExercise(
          id: androidProbeCustomExerciseId,
          name: '验收内嵌图动作',
          bodyPart: 'chest',
          equipment: 'body weight',
          icon: 'activity',
          image: androidProbePng,
        ),
      ],
      createdAt: first,
      updatedAt: first,
    );
    final scheduled = FitnessWorkout(
      id: androidProbeTodayWorkoutId,
      name: '验收今天训练',
      scheduledDate: fitnessDate(today),
      sourceKind: 'template',
      sourceTemplateId: template.id,
      exercises: _exercises(60000, completed: false),
      createdAt: fixed,
      updatedAt: fixed,
    );
    await db.transaction(() async {
      // 父本全为本机归属，不注册云账号、同步身份或待上传意图。
      await db.batch((batch) {
        batch.insert(
          db.ledgers,
          LedgersCompanion.insert(
            id: androidProbeLedgerId,
            name: '长期验收账本',
            selfMemberId: d.Value(self),
            updatedAt: first,
          ),
          mode: d.InsertMode.insertOrIgnore,
        );
        batch.insert(
          db.ledgerMembers,
          LedgerMembersCompanion.insert(
            id: self,
            ledgerId: androidProbeLedgerId,
            displayName: '',
            memberType: 'LOCAL',
            role: const d.Value('owner'),
            updatedAt: first,
          ),
          mode: d.InsertMode.insertOrIgnore,
        );
        for (final (id, name, type) in [
          (androidProbeMemoBookId, '长期验收备忘', 'normal'),
          (androidProbeCredentialBookId, '长期验收账号', 'credentials'),
        ]) {
          batch.insert(
            db.memoBooks,
            MemoBooksCompanion.insert(
              id: id,
              name: name,
              type: type,
              createdAt: first,
              updatedAt: fixed,
            ),
            mode: d.InsertMode.insertOrIgnore,
          );
        }
        batch.insert(
          db.fitnessSpaces,
          FitnessSpacesCompanion.insert(
            id: androidProbeFitnessSpaceId,
            name: '长期验收健身',
            createdAt: first,
            updatedAt: fixed,
          ),
          mode: d.InsertMode.insertOrIgnore,
        );
      });
      await db.batch((batch) {
        for (var index = 0; index < years * 1460; index++) {
          final at = fixed.subtract(Duration(hours: index * 6));
          batch.insert(
            db.transactions,
            TransactionsCompanion.insert(
              id: _id(100000 + index),
              ledgerId: androidProbeLedgerId,
              txType: 'expense',
              amount: '12.34',
              nativeAmount: '12.34',
              currencyCode: 'CNY',
              happenedAt: at,
              createdAt: at,
              updatedAt: at,
              payerMemberId: d.Value(self),
              note: d.Value('合成账单 $index'),
            ),
            mode: d.InsertMode.insertOrIgnore,
          );
        }
        for (var index = 0; index < years * 365; index++) {
          final at = fixed.subtract(Duration(days: index));
          final content = index % 10 == 0
              ? List.filled(400, '多年记录长文🙂与换行。\n').join()
              : '短记 $index\n';
          final entry = MemoEntry(
            id: androidProbeMemoId(index),
            memoBookId: androidProbeMemoBookId,
            bookType: 'normal',
            title: '合成备忘 $index',
            bodyJson: jsonEncode({
              'ops': [
                {
                  'insert': '合成备忘 $index',
                  'attributes': {'bold': true},
                },
                {
                  'insert': '\n',
                  'attributes': {'header': 2},
                },
                {'insert': content},
                {'insert': 'https://example.com\n'},
              ],
            }),
            createdAt: at,
            updatedAt: at,
          );
          entry.validate();
          batch.insert(
            db.memoEntries,
            MemoEntriesCompanion.insert(
              id: entry.id,
              memoBookId: entry.memoBookId,
              bookType: entry.bookType,
              title: entry.title,
              bodyFormat: const d.Value('delta_v1'),
              body: d.Value(entry.bodyJson),
              createdAt: at,
              updatedAt: at,
            ),
            mode: d.InsertMode.insertOrIgnore,
          );
        }
        for (var index = 0; index < years * 24; index++) {
          final at = fixed.subtract(Duration(days: index * 15));
          batch.insert(
            db.memoEntries,
            MemoEntriesCompanion.insert(
              id: _id(300000 + index),
              memoBookId: androidProbeCredentialBookId,
              bookType: 'credentials',
              title: '虚构站点 $index',
              bodyFormat: const d.Value('fields_v1'),
              body: d.Value(
                encodeMemoFields([
                  MemoField(label: '账号', value: 'synthetic_$index@example.com'),
                  MemoField(label: '密码', value: 'FAKE_$index'),
                ]),
              ),
              orderKey: d.Value(index),
              createdAt: at,
              updatedAt: at,
            ),
            mode: d.InsertMode.insertOrIgnore,
          );
        }
        for (final (id, type, payload, at) in [
          (template.id, 'fitness_template', template.toJson(), first),
          (plan.id, 'fitness_plan', plan.toJson(), first),
          (preferences.id, 'fitness_preferences', preferences.toJson(), first),
          (scheduled.id, 'fitness_workout', scheduled.toJson(), fixed),
        ]) {
          batch.insert(
            db.fitnessEntities,
            _fitnessRow(id, type, payload, at),
            mode: d.InsertMode.insertOrIgnore,
          );
        }
        for (var index = 0; index < years * 156; index++) {
          final date = DateTime(
            today.year,
            today.month,
            today.day - (index * 7 ~/ 3) - 1,
            10,
          );
          final at = date.toUtc();
          final workout = FitnessWorkout(
            id: _id(400000 + index),
            name: '合成训练 $index',
            scheduledDate: fitnessDate(date),
            sourceKind: 'template',
            sourceTemplateId: template.id,
            status: 'completed',
            exercises: _exercises(500000 + index * 100, completed: true),
            runSegments: [
              FitnessRunSegment(
                startedAt: at,
                endedAt: at.add(const Duration(minutes: 45)),
              ),
            ],
            createdAt: at,
            updatedAt: at,
          );
          batch.insert(
            db.fitnessEntities,
            _fitnessRow(workout.id, 'fitness_workout', workout.toJson(), at),
            mode: d.InsertMode.insertOrIgnore,
          );
        }
      });
    });
  } catch (error, stack) {
    logger.error(
      'AndroidAcceptance',
      '合成验收数据准备失败，请保留日志后重试',
      safeErrorSummary(error),
      stack,
    );
    rethrow;
  }
}
