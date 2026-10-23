//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_analytics_events_request_events_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_analytics_events_request.g.dart';

/// PostAnalyticsEventsRequest
///
/// Properties:
/// * [events]
@BuiltValue()
abstract class PostAnalyticsEventsRequest
    implements
        Built<PostAnalyticsEventsRequest, PostAnalyticsEventsRequestBuilder> {
  @BuiltValueField(wireName: r'events')
  BuiltList<PostAnalyticsEventsRequestEventsInner> get events;

  PostAnalyticsEventsRequest._();

  factory PostAnalyticsEventsRequest(
          [void updates(PostAnalyticsEventsRequestBuilder b)]) =
      _$PostAnalyticsEventsRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostAnalyticsEventsRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostAnalyticsEventsRequest> get serializer =>
      _$PostAnalyticsEventsRequestSerializer();
}

class _$PostAnalyticsEventsRequestSerializer
    implements PrimitiveSerializer<PostAnalyticsEventsRequest> {
  @override
  final Iterable<Type> types = const [
    PostAnalyticsEventsRequest,
    _$PostAnalyticsEventsRequest
  ];

  @override
  final String wireName = r'PostAnalyticsEventsRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostAnalyticsEventsRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'events';
    yield serializers.serialize(
      object.events,
      specifiedType: const FullType(
          BuiltList, [FullType(PostAnalyticsEventsRequestEventsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostAnalyticsEventsRequest object, {
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
    required PostAnalyticsEventsRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(PostAnalyticsEventsRequestEventsInner)]),
          ) as BuiltList<PostAnalyticsEventsRequestEventsInner>;
          result.events.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostAnalyticsEventsRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostAnalyticsEventsRequestBuilder();
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
