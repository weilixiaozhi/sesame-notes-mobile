//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_official_fitness_references200_response_exercises_inner.g.dart';

/// ListOfficialFitnessReferences200ResponseExercisesInner
///
/// Properties:
/// * [id]
/// * [name]
/// * [isEnabled]
@BuiltValue()
abstract class ListOfficialFitnessReferences200ResponseExercisesInner
    implements
        Built<ListOfficialFitnessReferences200ResponseExercisesInner,
            ListOfficialFitnessReferences200ResponseExercisesInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'is_enabled')
  bool get isEnabled;

  ListOfficialFitnessReferences200ResponseExercisesInner._();

  factory ListOfficialFitnessReferences200ResponseExercisesInner(
      [void updates(
          ListOfficialFitnessReferences200ResponseExercisesInnerBuilder
              b)]) = _$ListOfficialFitnessReferences200ResponseExercisesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          ListOfficialFitnessReferences200ResponseExercisesInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListOfficialFitnessReferences200ResponseExercisesInner>
      get serializer =>
          _$ListOfficialFitnessReferences200ResponseExercisesInnerSerializer();
}

class _$ListOfficialFitnessReferences200ResponseExercisesInnerSerializer
    implements
        PrimitiveSerializer<
            ListOfficialFitnessReferences200ResponseExercisesInner> {
  @override
  final Iterable<Type> types = const [
    ListOfficialFitnessReferences200ResponseExercisesInner,
    _$ListOfficialFitnessReferences200ResponseExercisesInner
  ];

  @override
  final String wireName =
      r'ListOfficialFitnessReferences200ResponseExercisesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListOfficialFitnessReferences200ResponseExercisesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'is_enabled';
    yield serializers.serialize(
      object.isEnabled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListOfficialFitnessReferences200ResponseExercisesInner object, {
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
    required ListOfficialFitnessReferences200ResponseExercisesInnerBuilder
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'is_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isEnabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListOfficialFitnessReferences200ResponseExercisesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        ListOfficialFitnessReferences200ResponseExercisesInnerBuilder();
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
