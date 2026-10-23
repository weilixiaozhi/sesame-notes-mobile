//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_preferences200_response_items_inner_custom_exercises_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner
///
/// Properties:
/// * [id]
/// * [name]
/// * [bodyPart]
/// * [equipment]
/// * [icon]
/// * [image]
/// * [deleted]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner,
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'body_part')
  String get bodyPart;

  @BuiltValueField(wireName: r'equipment')
  String get equipment;

  @BuiltValueField(wireName: r'icon')
  String get icon;

  @BuiltValueField(wireName: r'image')
  String? get image;

  @BuiltValueField(wireName: r'deleted')
  bool get deleted;

  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner._();

  factory GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner,
    _$GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner
        object, {
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
    yield r'body_part';
    yield serializers.serialize(
      object.bodyPart,
      specifiedType: const FullType(String),
    );
    yield r'equipment';
    yield serializers.serialize(
      object.equipment,
      specifiedType: const FullType(String),
    );
    yield r'icon';
    yield serializers.serialize(
      object.icon,
      specifiedType: const FullType(String),
    );
    yield r'image';
    yield object.image == null
        ? null
        : serializers.serialize(
            object.image,
            specifiedType: const FullType.nullable(String),
          );
    yield r'deleted';
    yield serializers.serialize(
      object.deleted,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner
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
    required GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInnerBuilder
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
        case r'body_part':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bodyPart = valueDes;
          break;
        case r'equipment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.equipment = valueDes;
          break;
        case r'icon':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.icon = valueDes;
          break;
        case r'image':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.image = valueDes;
          break;
        case r'deleted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.deleted = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdPreferences200ResponseItemsInnerCustomExercisesInnerBuilder();
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
