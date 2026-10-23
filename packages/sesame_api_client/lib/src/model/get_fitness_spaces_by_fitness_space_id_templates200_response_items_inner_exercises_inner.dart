//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_templates200_response_items_inner_exercises_inner_sets_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_templates200_response_items_inner_exercises_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner
///
/// Properties:
/// * [id]
/// * [exerciseId]
/// * [restSeconds]
/// * [warmupRestSeconds]
/// * [sets]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner,
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'exercise_id')
  String get exerciseId;

  @BuiltValueField(wireName: r'rest_seconds')
  int get restSeconds;

  @BuiltValueField(wireName: r'warmup_rest_seconds')
  int? get warmupRestSeconds;

  @BuiltValueField(wireName: r'sets')
  BuiltList<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner>
      get sets;

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner._();

  factory GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner,
    _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'exercise_id';
    yield serializers.serialize(
      object.exerciseId,
      specifiedType: const FullType(String),
    );
    yield r'rest_seconds';
    yield serializers.serialize(
      object.restSeconds,
      specifiedType: const FullType(int),
    );
    yield r'warmup_rest_seconds';
    yield object.warmupRestSeconds == null
        ? null
        : serializers.serialize(
            object.warmupRestSeconds,
            specifiedType: const FullType.nullable(int),
          );
    yield r'sets';
    yield serializers.serialize(
      object.sets,
      specifiedType: const FullType(BuiltList, [
        FullType(
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner)
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner
        object, {
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
    required GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'exercise_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.exerciseId = valueDes;
          break;
        case r'rest_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.restSeconds = valueDes;
          break;
        case r'warmup_rest_seconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.warmupRestSeconds = valueDes;
          break;
        case r'sets':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner>;
          result.sets.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerBuilder();
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
