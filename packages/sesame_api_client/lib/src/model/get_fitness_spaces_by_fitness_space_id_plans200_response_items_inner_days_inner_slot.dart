//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_days_inner_slot_exercises_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_plans200_response_items_inner_days_inner_slot.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot
///
/// Properties:
/// * [id]
/// * [sourceTemplateId]
/// * [name]
/// * [exercises]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot,
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'source_template_id')
  String? get sourceTemplateId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'exercises')
  BuiltList<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner>
      get exercises;

  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot._();

  factory GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot,
    _$GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'source_template_id';
    yield object.sourceTemplateId == null
        ? null
        : serializers.serialize(
            object.sourceTemplateId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'exercises';
    yield serializers.serialize(
      object.exercises,
      specifiedType: const FullType(BuiltList, [
        FullType(
            GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner)
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot
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
    required GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotBuilder
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
        case r'source_template_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sourceTemplateId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'exercises':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotExercisesInner>;
          result.exercises.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlot
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdPlans200ResponseItemsInnerDaysInnerSlotBuilder();
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
