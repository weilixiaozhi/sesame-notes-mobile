//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_templates200_response_items_inner_exercises_inner_sets_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner
///
/// Properties:
/// * [id]
/// * [kind]
/// * [weight]
/// * [weightLeft]
/// * [weightRight]
/// * [reps]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner,
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'kind')
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
      get kind;
  // enum kindEnum {  warmup,  working,  };

  @BuiltValueField(wireName: r'weight')
  String? get weight;

  @BuiltValueField(wireName: r'weight_left')
  String? get weightLeft;

  @BuiltValueField(wireName: r'weight_right')
  String? get weightRight;

  @BuiltValueField(wireName: r'reps')
  int? get reps;

  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner._();

  factory GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner,
    _$GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType: const FullType(
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum),
    );
    yield r'weight';
    yield object.weight == null
        ? null
        : serializers.serialize(
            object.weight,
            specifiedType: const FullType.nullable(String),
          );
    yield r'weight_left';
    yield object.weightLeft == null
        ? null
        : serializers.serialize(
            object.weightLeft,
            specifiedType: const FullType.nullable(String),
          );
    yield r'weight_right';
    yield object.weightRight == null
        ? null
        : serializers.serialize(
            object.weightRight,
            specifiedType: const FullType.nullable(String),
          );
    yield r'reps';
    yield object.reps == null
        ? null
        : serializers.serialize(
            object.reps,
            specifiedType: const FullType.nullable(int),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner
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
    required GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerBuilder
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
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum),
          ) as GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum;
          result.kind = valueDes;
          break;
        case r'weight':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.weight = valueDes;
          break;
        case r'weight_left':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.weightLeft = valueDes;
          break;
        case r'weight_right':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.weightRight = valueDes;
          break;
        case r'reps':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.reps = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerBuilder();
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

class GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'warmup')
  static const GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
      warmup =
      _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum_warmup;
  @BuiltValueEnumConst(wireName: r'working')
  static const GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
      working =
      _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum_working;

  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum>
      get serializer =>
          _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnumSerializer;

  const GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum>
      get values =>
          _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnumValues;
  static GetFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnum
      valueOf(String name) =>
          _$getFitnessSpacesByFitnessSpaceIdTemplates200ResponseItemsInnerExercisesInnerSetsInnerKindEnumValueOf(
              name);
}
