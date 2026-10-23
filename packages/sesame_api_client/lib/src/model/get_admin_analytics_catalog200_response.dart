//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_admin_analytics_catalog200_response_events_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_analytics_catalog200_response.g.dart';

/// GetAdminAnalyticsCatalog200Response
///
/// Properties:
/// * [events]
@BuiltValue()
abstract class GetAdminAnalyticsCatalog200Response
    implements
        Built<GetAdminAnalyticsCatalog200Response,
            GetAdminAnalyticsCatalog200ResponseBuilder> {
  @BuiltValueField(wireName: r'events')
  BuiltList<GetAdminAnalyticsCatalog200ResponseEventsInner> get events;

  GetAdminAnalyticsCatalog200Response._();

  factory GetAdminAnalyticsCatalog200Response(
          [void updates(GetAdminAnalyticsCatalog200ResponseBuilder b)]) =
      _$GetAdminAnalyticsCatalog200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminAnalyticsCatalog200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminAnalyticsCatalog200Response> get serializer =>
      _$GetAdminAnalyticsCatalog200ResponseSerializer();
}

class _$GetAdminAnalyticsCatalog200ResponseSerializer
    implements PrimitiveSerializer<GetAdminAnalyticsCatalog200Response> {
  @override
  final Iterable<Type> types = const [
    GetAdminAnalyticsCatalog200Response,
    _$GetAdminAnalyticsCatalog200Response
  ];

  @override
  final String wireName = r'GetAdminAnalyticsCatalog200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminAnalyticsCatalog200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'events';
    yield serializers.serialize(
      object.events,
      specifiedType: const FullType(BuiltList,
          [FullType(GetAdminAnalyticsCatalog200ResponseEventsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminAnalyticsCatalog200Response object, {
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
    required GetAdminAnalyticsCatalog200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'events':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(GetAdminAnalyticsCatalog200ResponseEventsInner)]),
          ) as BuiltList<GetAdminAnalyticsCatalog200ResponseEventsInner>;
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
  GetAdminAnalyticsCatalog200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminAnalyticsCatalog200ResponseBuilder();
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
