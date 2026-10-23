//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_preferences200_response_items_inner_exercise_rest_settings_value.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_preferences200_response_items_inner_custom_exercises_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_preferences200_response_items_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner
///
/// Properties:
/// * [customExercises]
/// * [defaultRestSeconds]
/// * [defaultWarmupRestSeconds]
/// * [exerciseRestSettings]
/// * [soundEnabled]
/// * [vibrationEnabled]
/// * [pinnedExerciseIds]
/// * [exerciseWeightModes]
/// * [createdAt]
/// * [updatedAt]
/// * [id]
/// * [fitnessSpaceId]
/// * [syncId]
/// * [revision]
/// * [deletedAt]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner
    implements
        Built<GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner,
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'custom_exercises')
  BuiltList<
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner>
      get customExercises;

  @BuiltValueField(wireName: r'default_rest_seconds')
  int get defaultRestSeconds;

  @BuiltValueField(wireName: r'default_warmup_rest_seconds')
  int? get defaultWarmupRestSeconds;

  @BuiltValueField(wireName: r'exercise_rest_settings')
  BuiltMap<String,
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue>?
      get exerciseRestSettings;

  @BuiltValueField(wireName: r'sound_enabled')
  bool get soundEnabled;

  @BuiltValueField(wireName: r'vibration_enabled')
  bool get vibrationEnabled;

  @BuiltValueField(wireName: r'pinned_exercise_ids')
  BuiltSet<String> get pinnedExerciseIds;

  @BuiltValueField(wireName: r'exercise_weight_modes')
  BuiltMap<String, bool> get exerciseWeightModes;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'fitness_space_id')
  String get fitnessSpaceId;

  @BuiltValueField(wireName: r'sync_id')
  String get syncId;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'deleted_at')
  String? get deletedAt;

  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner._();

  factory GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner,
    _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'custom_exercises';
    yield serializers.serialize(
      object.customExercises,
      specifiedType: const FullType(BuiltList, [
        FullType(
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner)
      ]),
    );
    yield r'default_rest_seconds';
    yield serializers.serialize(
      object.defaultRestSeconds,
      specifiedType: const FullType(int),
    );
    if (object.defaultWarmupRestSeconds != null) {
      yield r'default_warmup_rest_seconds';
      yield serializers.serialize(
        object.defaultWarmupRestSeconds,
        specifiedType: const FullType(int),
      );
    }
    if (object.exerciseRestSettings != null) {
      yield r'exercise_rest_settings';
      yield serializers.serialize(
        object.exerciseRestSettings,
        specifiedType: const FullType(BuiltMap, [
          FullType(String),
          FullType(
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue)
        ]),
      );
    }
    yield r'sound_enabled';
    yield serializers.serialize(
      object.soundEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'vibration_enabled';
    yield serializers.serialize(
      object.vibrationEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'pinned_exercise_ids';
    yield serializers.serialize(
      object.pinnedExerciseIds,
      specifiedType: const FullType(BuiltSet, [FullType(String)]),
    );
    yield r'exercise_weight_modes';
    yield serializers.serialize(
      object.exerciseWeightModes,
      specifiedType:
          const FullType(BuiltMap, [FullType(String), FullType(bool)]),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'fitness_space_id';
    yield serializers.serialize(
      object.fitnessSpaceId,
      specifiedType: const FullType(String),
    );
    yield r'sync_id';
    yield serializers.serialize(
      object.syncId,
      specifiedType: const FullType(String),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'deleted_at';
    yield object.deletedAt == null
        ? null
        : serializers.serialize(
            object.deletedAt,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'custom_exercises':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner>;
          result.customExercises.replace(valueDes);
          break;
        case r'default_rest_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.defaultRestSeconds = valueDes;
          break;
        case r'default_warmup_rest_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.defaultWarmupRestSeconds = valueDes;
          break;
        case r'exercise_rest_settings':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltMap, [
              FullType(String),
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue)
            ]),
          ) as BuiltMap<String,
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue>?;
          if (valueDes == null) continue;
          result.exerciseRestSettings.replace(valueDes);
          break;
        case r'sound_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.soundEnabled = valueDes;
          break;
        case r'vibration_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.vibrationEnabled = valueDes;
          break;
        case r'pinned_exercise_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet, [FullType(String)]),
          ) as BuiltSet<String>;
          result.pinnedExerciseIds.replace(valueDes);
          break;
        case r'exercise_weight_modes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltMap, [FullType(String), FullType(bool)]),
          ) as BuiltMap<String, bool>;
          result.exerciseWeightModes.replace(valueDes);
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'fitness_space_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fitnessSpaceId = valueDes;
          break;
        case r'sync_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.syncId = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'deleted_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.deletedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
