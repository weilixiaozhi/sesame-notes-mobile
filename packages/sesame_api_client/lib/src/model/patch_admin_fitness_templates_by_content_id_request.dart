//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_admin_fitness_templates_request_content.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'patch_admin_fitness_templates_by_content_id_request.g.dart';

/// PatchAdminFitnessTemplatesByContentIdRequest
///
/// Properties:
/// * [version]
/// * [content]
/// * [isEnabled]
@BuiltValue()
abstract class PatchAdminFitnessTemplatesByContentIdRequest
    implements
        Built<PatchAdminFitnessTemplatesByContentIdRequest,
            PatchAdminFitnessTemplatesByContentIdRequestBuilder> {
  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'content')
  PostAdminFitnessTemplatesRequestContent? get content;

  @BuiltValueField(wireName: r'is_enabled')
  bool? get isEnabled;

  PatchAdminFitnessTemplatesByContentIdRequest._();

  factory PatchAdminFitnessTemplatesByContentIdRequest(
          [void updates(
              PatchAdminFitnessTemplatesByContentIdRequestBuilder b)]) =
      _$PatchAdminFitnessTemplatesByContentIdRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PatchAdminFitnessTemplatesByContentIdRequestBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatchAdminFitnessTemplatesByContentIdRequest>
      get serializer =>
          _$PatchAdminFitnessTemplatesByContentIdRequestSerializer();
}

class _$PatchAdminFitnessTemplatesByContentIdRequestSerializer
    implements
        PrimitiveSerializer<PatchAdminFitnessTemplatesByContentIdRequest> {
  @override
  final Iterable<Type> types = const [
    PatchAdminFitnessTemplatesByContentIdRequest,
    _$PatchAdminFitnessTemplatesByContentIdRequest
  ];

  @override
  final String wireName = r'PatchAdminFitnessTemplatesByContentIdRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatchAdminFitnessTemplatesByContentIdRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(PostAdminFitnessTemplatesRequestContent),
      );
    }
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
    PatchAdminFitnessTemplatesByContentIdRequest object, {
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
    required PatchAdminFitnessTemplatesByContentIdRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PostAdminFitnessTemplatesRequestContent),
          ) as PostAdminFitnessTemplatesRequestContent?;
          if (valueDes == null) continue;
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
  PatchAdminFitnessTemplatesByContentIdRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PatchAdminFitnessTemplatesByContentIdRequestBuilder();
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
