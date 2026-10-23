//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_analytics_events200_response.g.dart';

/// PostAnalyticsEvents200Response
///
/// Properties:
/// * [accepted]
/// * [duplicates]
@BuiltValue()
abstract class PostAnalyticsEvents200Response
    implements
        Built<PostAnalyticsEvents200Response,
            PostAnalyticsEvents200ResponseBuilder> {
  @BuiltValueField(wireName: r'accepted')
  int get accepted;

  @BuiltValueField(wireName: r'duplicates')
  int get duplicates;

  PostAnalyticsEvents200Response._();

  factory PostAnalyticsEvents200Response(
          [void updates(PostAnalyticsEvents200ResponseBuilder b)]) =
      _$PostAnalyticsEvents200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAnalyticsEvents200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAnalyticsEvents200Response> get serializer =>
      _$PostAnalyticsEvents200ResponseSerializer();
}

class _$PostAnalyticsEvents200ResponseSerializer
    implements PrimitiveSerializer<PostAnalyticsEvents200Response> {
  @override
  final Iterable<Type> types = const [
    PostAnalyticsEvents200Response,
    _$PostAnalyticsEvents200Response
  ];

  @override
  final String wireName = r'PostAnalyticsEvents200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAnalyticsEvents200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'accepted';
    yield serializers.serialize(
      object.accepted,
      specifiedType: const FullType(int),
    );
    yield r'duplicates';
    yield serializers.serialize(
      object.duplicates,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAnalyticsEvents200Response object, {
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
    required PostAnalyticsEvents200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accepted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.accepted = valueDes;
          break;
        case r'duplicates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.duplicates = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAnalyticsEvents200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAnalyticsEvents200ResponseBuilder();
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
