//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_analytics_details200_response_events_inner.g.dart';

/// GetAdminAnalyticsDetails200ResponseEventsInner
///
/// Properties:
/// * [eventName]
/// * [name]
/// * [behavior]
/// * [total]
/// * [users]
@BuiltValue()
abstract class GetAdminAnalyticsDetails200ResponseEventsInner
    implements
        Built<GetAdminAnalyticsDetails200ResponseEventsInner,
            GetAdminAnalyticsDetails200ResponseEventsInnerBuilder> {
  @BuiltValueField(wireName: r'event_name')
  String get eventName;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'behavior')
  GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum get behavior;
  // enum behaviorEnum {  click,  complete,  };

  @BuiltValueField(wireName: r'total')
  int get total;

  @BuiltValueField(wireName: r'users')
  int get users;

  GetAdminAnalyticsDetails200ResponseEventsInner._();

  factory GetAdminAnalyticsDetails200ResponseEventsInner(
          [void updates(
              GetAdminAnalyticsDetails200ResponseEventsInnerBuilder b)]) =
      _$GetAdminAnalyticsDetails200ResponseEventsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetAdminAnalyticsDetails200ResponseEventsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminAnalyticsDetails200ResponseEventsInner>
      get serializer =>
          _$GetAdminAnalyticsDetails200ResponseEventsInnerSerializer();
}

class _$GetAdminAnalyticsDetails200ResponseEventsInnerSerializer
    implements
        PrimitiveSerializer<GetAdminAnalyticsDetails200ResponseEventsInner> {
  @override
  final Iterable<Type> types = const [
    GetAdminAnalyticsDetails200ResponseEventsInner,
    _$GetAdminAnalyticsDetails200ResponseEventsInner
  ];

  @override
  final String wireName = r'GetAdminAnalyticsDetails200ResponseEventsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminAnalyticsDetails200ResponseEventsInner object, {
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
    yield r'behavior';
    yield serializers.serialize(
      object.behavior,
      specifiedType: const FullType(
          GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum),
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
    GetAdminAnalyticsDetails200ResponseEventsInner object, {
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
    required GetAdminAnalyticsDetails200ResponseEventsInnerBuilder result,
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
        case r'behavior':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum),
          ) as GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum;
          result.behavior = valueDes;
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
  GetAdminAnalyticsDetails200ResponseEventsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminAnalyticsDetails200ResponseEventsInnerBuilder();
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

class GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'click')
  static const GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum
      click =
      _$getAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum_click;
  @BuiltValueEnumConst(wireName: r'complete')
  static const GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum
      complete =
      _$getAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum_complete;

  static Serializer<GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum>
      get serializer =>
          _$getAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnumSerializer;

  const GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum._(
      String name)
      : super(name);

  static BuiltSet<GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum>
      get values =>
          _$getAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnumValues;
  static GetAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnum valueOf(
          String name) =>
      _$getAdminAnalyticsDetails200ResponseEventsInnerBehaviorEnumValueOf(name);
}
