import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sesame_api_client/sesame_api_client.dart' as api;
import 'package:sesame_notes/data/models/fitness.dart';
import 'package:sesame_notes/data/models/fitness_catalog.dart';
import 'package:sesame_notes/data/models/fitness_catalog_snapshot.dart';
import 'package:sesame_notes/data/models/fitness_custom_exercise.dart';
import 'package:sesame_notes/data/repositories/fitness_catalog_repository.dart';
import 'package:sesame_notes/domain/fitness/fitness_rules.dart';
import 'package:sesame_notes/features/fitness/presentation/widgets/fitness_widgets.dart';
import 'package:sesame_notes/features/fitness/domain/fitness_statistics.dart';
import 'package:sesame_notes/l10n/app_localizations.dart';

const _exercise = {
  'id': '0025',
  'name_zh': '卧推',
  'name_zh_hant': '臥推',
  'name_en': 'Bench press',
  'body_part': 'grip',
  'target': 'grip',
  'equipment': 'new-machine',
  'gif_asset': '',
  'secondary_muscles': <String>[],
  'instructions_zh': <String>[],
  'instructions_zh_hant': <String>[],
  'instructions_en': <String>[],
};

/// 构造公开目录契约，名称和删除状态可变化而标识保持稳定。
Map<String, Object> _entry(String id, String name, {bool deleted = false}) => {
  'id': id,
  'name': {'zh': name, 'zh_hant': '繁體$name', 'en': 'English $name'},
  'is_deleted': deleted,
};

/// 离线随包目录只包含动作，不依赖动态目录已同步。
class _Bundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(
    Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'exercises': [_exercise],
        }),
      ),
    ),
  );
}

/// 返回可控响应，使缓存验证包含真实 JSON 解析和持久化。
class _Adapter implements HttpClientAdapter {
  _Adapter(this.respond);
  final ResponseBody Function(RequestOptions) respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => respond(options);

  @override
  void close({bool force = false}) {}
}

/// 分类增删改必须贯穿缓存、语言回退与同步载荷，不能仅改变选择器文本。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('动态分类与解剖区域分别累计，同一分类的跨区域动作点击后只统计所选区域', () {
    try {
      final catalog = {
        '0025': FitnessExerciseDefinition.fromJson({
          ..._exercise,
          'body_part': 'new-category',
          'target': 'pectorals',
        }),
        '0047': FitnessExerciseDefinition.fromJson({
          ..._exercise,
          'id': '0047',
          'body_part': 'new-category',
          'target': 'quads',
        }),
      };
      final stats = fitnessStatistics(
        [
          FitnessWorkout(
            id: 'workout',
            name: '分类迁移统计',
            status: 'completed',
            scheduledDate: '2026-10-10',
            runSegments: [
              FitnessRunSegment(
                startedAt: DateTime.utc(2026, 10, 10, 10),
                endedAt: DateTime.utc(2026, 10, 10, 11),
              ),
            ],
            exercises: [
              const FitnessExercise(
                id: 'first',
                exerciseId: '0025',
                sets: [
                  FitnessSet(
                    id: 'set-first',
                    weight: '10',
                    reps: 2,
                    completed: true,
                  ),
                ],
              ),
              const FitnessExercise(
                id: 'second',
                exerciseId: '0047',
                sets: [
                  FitnessSet(
                    id: 'set-second',
                    weight: '20',
                    reps: 3,
                    completed: true,
                  ),
                ],
              ),
            ],
          ),
        ],
        startDate: '2026-10-10',
        endDate: '2026-10-10',
        catalog: catalog,
      );
      expect(stats.bodyPartVolumeKg, {'new-category': Decimal.fromInt(80)});
      expect(stats.anatomyVolumeKg, {
        'chest': Decimal.fromInt(20),
        'upper legs': Decimal.fromInt(60),
      });
      expect(stats.anatomyCategoryVolumeKg['chest'], {
        'new-category': Decimal.fromInt(20),
      });
      expect(stats.anatomyCategoryVolumeKg['upper legs'], {
        'new-category': Decimal.fromInt(60),
      });
      expect(stats.trainedMuscles, {'pectorals', 'quads'});
      expect(stats.volumeKg, Decimal.fromInt(80));
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        StateError('分类与解剖区域独立统计验收失败：$error'),
        stackTrace,
      );
    }
  });

  test('新分类可选择、删除分类保留三语标签，内置分类仅在缺少动态目录时回退', () async {
    try {
      final taxonomies = FitnessTaxonomies.fromJson({
        'body_parts': [
          _entry('grip', '握力'),
          _entry('chest', '旧胸部', deleted: true),
        ],
        'equipment': [_entry('new-machine', '新器械')],
      });
      expect(fitnessSelectableTaxonomyIds(taxonomies), ['grip']);
      expect(fitnessSelectableTaxonomyIds(taxonomies, isEquipment: true), [
        'new-machine',
      ]);
      expect(taxonomies.label('chest', 'zh'), '旧胸部');
      expect(taxonomies.label('grip', 'zh_TW'), '繁體握力');
      expect(taxonomies.label('grip', 'zh-Hant'), '繁體握力');
      expect(taxonomies.label('grip', 'en'), 'English 握力');
      final zh = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(fitnessCatalogLabel(zh, 'chest', taxonomies: taxonomies), '旧胸部');
      expect(
        fitnessCatalogLabel(
          zh,
          'new-machine',
          taxonomies: taxonomies,
          isEquipment: true,
        ),
        '新器械',
      );
      expect(
        fitnessCatalogLabel(zh, 'back', taxonomies: taxonomies),
        fitnessBodyPartLabel(zh, 'back'),
      );
      expect(fitnessSelectableTaxonomyIds(null), contains('chest'));
      expect(
        fitnessSelectableTaxonomyIds(
          FitnessTaxonomies(bodyParts: [], equipment: []),
        ),
        isEmpty,
      );
      expect(() => taxonomies.bodyParts.clear(), throwsUnsupportedError);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(StateError('分类选择与历史名称验收失败：$error'), stackTrace);
    }
  });

  test('目录重命名与删除缓存后离线仍可用，损坏响应不能覆盖快照', () async {
    try {
      final preferences = await SharedPreferences.getInstance();
      Object remote = {
        'exercises': [_exercise],
        'taxonomies': {
          'body_parts': [_entry('grip', '握力')],
          'equipment': [_entry('new-machine', '新器械')],
        },
      };
      final dio = Dio(BaseOptions(baseUrl: 'http://taxonomy.test'))
        ..httpClientAdapter = _Adapter(
          (_) => ResponseBody.fromString(
            jsonEncode(remote),
            200,
            headers: {
              Headers.contentTypeHeader: ['application/json'],
            },
          ),
        );
      final repository = FitnessCatalogRepository(
        dio: dio,
        preferences: preferences,
        bundle: _Bundle(),
      );
      expect((await repository.loadSnapshot()).taxonomies, isNull);
      expect(await repository.refresh(), isTrue);
      expect(
        (await repository.loadSnapshot()).taxonomies!.label('grip', 'zh'),
        '握力',
      );
      remote = {
        'exercises': [_exercise],
        'taxonomies': {
          'body_parts': [_entry('grip', '前臂握力', deleted: true)],
          'equipment': [_entry('new-machine', '器械更新名称')],
        },
      };
      expect(await repository.refresh(), isTrue);
      final cached = await repository.loadSnapshot();
      expect(cached.taxonomies!.label('grip', 'zh'), '前臂握力');
      expect(fitnessSelectableTaxonomyIds(cached.taxonomies), isEmpty);
      expect((await repository.loadLocal()).single.bodyPart, 'grip');
      remote = {
        'exercises': [_exercise],
        'taxonomies': {
          'body_parts': [_entry('duplicate', '重复'), _entry('duplicate', '重复2')],
          'equipment': [],
        },
      };
      expect(await repository.refresh(), isFalse);
      expect(
        (await repository.loadSnapshot()).taxonomies!.label('grip', 'zh'),
        '前臂握力',
      );
      dio.httpClientAdapter = _Adapter((_) => throw StateError('模拟离线'));
      expect(await repository.refresh(), isFalse);
      expect(
        (await repository.loadSnapshot()).taxonomies!.label(
          'new-machine',
          'zh',
          isEquipment: true,
        ),
        '器械更新名称',
      );
      final other = FitnessCatalogRepository(
        dio: Dio(BaseOptions(baseUrl: 'http://other.test')),
        preferences: preferences,
        bundle: _Bundle(),
      );
      expect((await other.loadSnapshot()).taxonomies, isNull);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(StateError('分类快照缓存验收失败：$error'), stackTrace);
    }
  });

  test('自定义动作允许后台新增的稳定分类标识，拒绝空值与超长标识', () {
    try {
      const custom = FitnessCustomExercise(
        id: 'custom:11111111-1111-4111-8111-111111111111',
        name: '新增分类动作',
        bodyPart: 'grip',
        equipment: 'new-machine',
        icon: 'dumbbell',
      );
      final payload = FitnessPreferences(
        customExercises: [custom],
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ).toJson();
      expect(
        () => validateFitnessPayload('fitness_preferences', payload),
        returnsNormally,
      );
      // 同步发送和接收均经过正式生成的序列化器，动态分类标识必须能无损往返。
      final serializer =
          api.PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload.serializer;
      final serialized = api.standardSerializers.deserializeWith(
        serializer,
        payload,
      );
      expect(
        api.standardSerializers.serializeWith(serializer, serialized),
        payload,
      );
      for (final invalid in ['', ' ', 'x' * 101]) {
        expect(
          () => validateFitnessPayload('fitness_preferences', {
            ...payload,
            'custom_exercises': [
              {...custom.toJson(), 'body_part': invalid},
            ],
          }),
          throwsA(isA<FitnessValidationException>()),
        );
      }
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(StateError('动态分类同步载荷验收失败：$error'), stackTrace);
    }
  });
}
