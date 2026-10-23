//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_admin_fitness_templates_request_content.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_admin_fitness_templates_request.g.dart';

/// PostAdminFitnessTemplatesRequest
///
/// Properties:
/// * [content]
/// * [isEnabled]
@BuiltValue()
abstract class PostAdminFitnessTemplatesRequest
    implements
        Built<PostAdminFitnessTemplatesRequest,
            PostAdminFitnessTemplatesRequestBuilder> {
  @BuiltValueField(wireName: r'content')
  PostAdminFitnessTemplatesRequestContent get content;

  @BuiltValueField(wireName: r'is_enabled')
  bool? get isEnabled;

  PostAdminFitnessTemplatesRequest._();

  factory PostAdminFitnessTemplatesRequest(
          [void updates(PostAdminFitnessTemplatesRequestBuilder b)]) =
      _$PostAdminFitnessTemplatesRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAdminFitnessTemplatesRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAdminFitnessTemplatesRequest> get serializer =>
      _$PostAdminFitnessTemplatesRequestSerializer();
}

class _$PostAdminFitnessTemplatesRequestSerializer
    implements PrimitiveSerializer<PostAdminFitnessTemplatesRequest> {
  @override
  final Iterable<Type> types = const [
    PostAdminFitnessTemplatesRequest,
    _$PostAdminFitnessTemplatesRequest
  ];

  @override
  final String wireName = r'PostAdminFitnessTemplatesRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAdminFitnessTemplatesRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(PostAdminFitnessTemplatesRequestContent),
    );
    if (object.isEnabled != null) {
      yield r'is_enabled';
      yield serializers.serialize(
        object.isEnabled,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAdminFitnessTemplatesRequest object, {
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
    required PostAdminFitnessTemplatesRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(PostAdminFitnessTemplatesRequestContent),
          ) as PostAdminFitnessTemplatesRequestContent;
          result.content.replace(valueDes);
          break;
        case r'is_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
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
  PostAdminFitnessTemplatesRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAdminFitnessTemplatesRequestBuilder();
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
