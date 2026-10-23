//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_analytics_details200_response_pages_inner.g.dart';

/// GetAdminAnalyticsDetails200ResponsePagesInner
///
/// Properties:
/// * [pageId]
/// * [eventName]
/// * [name]
/// * [pageViews]
/// * [visitors]
@BuiltValue()
abstract class GetAdminAnalyticsDetails200ResponsePagesInner
    implements
        Built<GetAdminAnalyticsDetails200ResponsePagesInner,
            GetAdminAnalyticsDetails200ResponsePagesInnerBuilder> {
  @BuiltValueField(wireName: r'page_id')
  String get pageId;

  @BuiltValueField(wireName: r'event_name')
  String get eventName;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'page_views')
  int get pageViews;

  @BuiltValueField(wireName: r'visitors')
  int get visitors;

  GetAdminAnalyticsDetails200ResponsePagesInner._();

  factory GetAdminAnalyticsDetails200ResponsePagesInner(
          [void updates(
              GetAdminAnalyticsDetails200ResponsePagesInnerBuilder b)]) =
      _$GetAdminAnalyticsDetails200ResponsePagesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetAdminAnalyticsDetails200ResponsePagesInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminAnalyticsDetails200ResponsePagesInner>
      get serializer =>
          _$GetAdminAnalyticsDetails200ResponsePagesInnerSerializer();
}

class _$GetAdminAnalyticsDetails200ResponsePagesInnerSerializer
    implements
        PrimitiveSerializer<GetAdminAnalyticsDetails200ResponsePagesInner> {
  @override
  final Iterable<Type> types = const [
    GetAdminAnalyticsDetails200ResponsePagesInner,
    _$GetAdminAnalyticsDetails200ResponsePagesInner
  ];

  @override
  final String wireName = r'GetAdminAnalyticsDetails200ResponsePagesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminAnalyticsDetails200ResponsePagesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'page_id';
    yield serializers.serialize(
      object.pageId,
      specifiedType: const FullType(String),
    );
    yield r'event_name';
    yield serializers.serialize(
      object.eventName,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'page_views';
    yield serializers.serialize(
      object.pageViews,
      specifiedType: const FullType(int),
    );
    yield r'visitors';
    yield serializers.serialize(
      object.visitors,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminAnalyticsDetails200ResponsePagesInner object, {
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
    required GetAdminAnalyticsDetails200ResponsePagesInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'page_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.pageId = valueDes;
          break;
        case r'event_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.eventName = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'page_views':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.pageViews = valueDes;
          break;
        case r'visitors':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.visitors = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminAnalyticsDetails200ResponsePagesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminAnalyticsDetails200ResponsePagesInnerBuilder();
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
