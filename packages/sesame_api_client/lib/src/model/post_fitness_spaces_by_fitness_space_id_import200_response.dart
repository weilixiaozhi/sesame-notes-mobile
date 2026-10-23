//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_fitness_spaces_by_fitness_space_id_import200_response.g.dart';

/// PostFitnessSpacesByFitnessSpaceIdImport200Response
///
/// Properties:
/// * [imported]
/// * [skipped]
/// * [ids]
/// * [replayed]
@BuiltValue()
abstract class PostFitnessSpacesByFitnessSpaceIdImport200Response
    implements
        Built<PostFitnessSpacesByFitnessSpaceIdImport200Response,
            PostFitnessSpacesByFitnessSpaceIdImport200ResponseBuilder> {
  @BuiltValueField(wireName: r'imported')
  int get imported;

  @BuiltValueField(wireName: r'skipped')
  int get skipped;

  @BuiltValueField(wireName: r'ids')
  BuiltMap<String, String> get ids;

  @BuiltValueField(wireName: r'replayed')
  bool get replayed;

  PostFitnessSpacesByFitnessSpaceIdImport200Response._();

  factory PostFitnessSpacesByFitnessSpaceIdImport200Response(
          [void updates(
              PostFitnessSpacesByFitnessSpaceIdImport200ResponseBuilder b)]) =
      _$PostFitnessSpacesByFitnessSpaceIdImport200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostFitnessSpacesByFitnessSpaceIdImport200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostFitnessSpacesByFitnessSpaceIdImport200Response>
      get serializer =>
          _$PostFitnessSpacesByFitnessSpaceIdImport200ResponseSerializer();
}

class _$PostFitnessSpacesByFitnessSpaceIdImport200ResponseSerializer
    implements
        PrimitiveSerializer<
            PostFitnessSpacesByFitnessSpaceIdImport200Response> {
  @override
  final Iterable<Type> types = const [
    PostFitnessSpacesByFitnessSpaceIdImport200Response,
    _$PostFitnessSpacesByFitnessSpaceIdImport200Response
  ];

  @override
  final String wireName = r'PostFitnessSpacesByFitnessSpaceIdImport200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostFitnessSpacesByFitnessSpaceIdImport200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'imported';
    yield serializers.serialize(
      object.imported,
      specifiedType: const FullType(int),
    );
    yield r'skipped';
    yield serializers.serialize(
      object.skipped,
      specifiedType: const FullType(int),
    );
    yield r'ids';
    yield serializers.serialize(
      object.ids,
      specifiedType:
          const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
    yield r'replayed';
    yield serializers.serialize(
      object.replayed,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostFitnessSpacesByFitnessSpaceIdImport200Response object, {
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
    required PostFitnessSpacesByFitnessSpaceIdImport200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'imported':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.imported = valueDes;
          break;
        case r'skipped':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.skipped = valueDes;
          break;
        case r'ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.ids.replace(valueDes);
          break;
        case r'replayed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.replayed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostFitnessSpacesByFitnessSpaceIdImport200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostFitnessSpacesByFitnessSpaceIdImport200ResponseBuilder();
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
