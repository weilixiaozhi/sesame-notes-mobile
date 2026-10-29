//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_analytics_details200_response_exposures_inner.g.dart';

/// GetAdminAnalyticsDetails200ResponseExposuresInner
///
/// Properties:
/// * [eventName]
/// * [name]
/// * [total]
/// * [users]
@BuiltValue()
abstract class GetAdminAnalyticsDetails200ResponseExposuresInner
    implements
        Built<GetAdminAnalyticsDetails200ResponseExposuresInner,
            GetAdminAnalyticsDetails200ResponseExposuresInnerBuilder> {
  @BuiltValueField(wireName: r'event_name')
  String get eventName;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'users')
  int get users;

  GetAdminAnalyticsDetails200ResponseExposuresInner._();

  factory GetAdminAnalyticsDetails200ResponseExposuresInner(
          [void updates(
              GetAdminAnalyticsDetails200ResponseExposuresInnerBuilder b)]) =
      _$GetAdminAnalyticsDetails200ResponseExposuresInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetAdminAnalyticsDetails200ResponseExposuresInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminAnalyticsDetails200ResponseExposuresInner>
      get serializer =>
          _$GetAdminAnalyticsDetails200ResponseExposuresInnerSerializer();
}

class _$GetAdminAnalyticsDetails200ResponseExposuresInnerSerializer
    implements
        PrimitiveSerializer<GetAdminAnalyticsDetails200ResponseExposuresInner> {
  @override
  final Iterable<Type> types = const [
    GetAdminAnalyticsDetails200ResponseExposuresInner,
    _$GetAdminAnalyticsDetails200ResponseExposuresInner
  ];

  @override
  final String wireName = r'GetAdminAnalyticsDetails200ResponseExposuresInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminAnalyticsDetails200ResponseExposuresInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(int),
    );
    yield r'users';
    yield serializers.serialize(
      object.users,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminAnalyticsDetails200ResponseExposuresInner object, {
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
    required GetAdminAnalyticsDetails200ResponseExposuresInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.total = valueDes;
          break;
        case r'users':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.users = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminAnalyticsDetails200ResponseExposuresInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminAnalyticsDetails200ResponseExposuresInnerBuilder();
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
