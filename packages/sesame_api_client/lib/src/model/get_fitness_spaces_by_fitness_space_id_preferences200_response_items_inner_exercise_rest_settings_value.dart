//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_preferences200_response_items_inner_exercise_rest_settings_value.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue
///
/// Properties:
/// * [restSeconds]
/// * [warmupRestSeconds]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue,
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueBuilder> {
  @BuiltValueField(wireName: r'rest_seconds')
  int get restSeconds;

  @BuiltValueField(wireName: r'warmup_rest_seconds')
  int get warmupRestSeconds;

  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue._();

  factory GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue,
    _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'rest_seconds';
    yield serializers.serialize(
      object.restSeconds,
      specifiedType: const FullType(int),
    );
    yield r'warmup_rest_seconds';
    yield serializers.serialize(
      object.warmupRestSeconds,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue
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
    required GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
            specifiedType: const FullType(int),
          ) as int;
          result.warmupRestSeconds = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValue
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerExerciseRestSettingsValueBuilder();
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
