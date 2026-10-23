//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of1_any_of_payload_event.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent
///
/// Properties:
/// * [calendarType]
/// * [originalYear]
/// * [originalMonth]
/// * [originalDay]
/// * [isLeapMonth]
/// * [solarDate]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent,
            PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder> {
  @BuiltValueField(wireName: r'calendar_type')
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum
      get calendarType;
  // enum calendarTypeEnum {  solar,  lunar,  };

  @BuiltValueField(wireName: r'original_year')
  int get originalYear;

  @BuiltValueField(wireName: r'original_month')
  int get originalMonth;

  @BuiltValueField(wireName: r'original_day')
  int get originalDay;

  @BuiltValueField(wireName: r'is_leap_month')
  bool get isLeapMonth;

  @BuiltValueField(wireName: r'solar_date')
  String get solarDate;

  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent._();

  factory PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent(
      [void updates(
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder
              b)]) = _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent,
    _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent
  ];

  @override
  final String wireName =
      r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'calendar_type';
    yield serializers.serialize(
      object.calendarType,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum),
    );
    yield r'original_year';
    yield serializers.serialize(
      object.originalYear,
      specifiedType: const FullType(int),
    );
    yield r'original_month';
    yield serializers.serialize(
      object.originalMonth,
      specifiedType: const FullType(int),
    );
    yield r'original_day';
    yield serializers.serialize(
      object.originalDay,
      specifiedType: const FullType(int),
    );
    yield r'is_leap_month';
    yield serializers.serialize(
      object.isLeapMonth,
      specifiedType: const FullType(bool),
    );
    yield r'solar_date';
    yield serializers.serialize(
      object.solarDate,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent object, {
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
    required PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'calendar_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum;
          result.calendarType = valueDes;
          break;
        case r'original_year':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.originalYear = valueDes;
          break;
        case r'original_month':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.originalMonth = valueDes;
          break;
        case r'original_day':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.originalDay = valueDes;
          break;
        case r'is_leap_month':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isLeapMonth = valueDes;
          break;
        case r'solar_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.solarDate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'solar')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum
      solar =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum_solar;
  @BuiltValueEnumConst(wireName: r'lunar')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum
      lunar =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum_lunar;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnum
      valueOf(String name) =>
          _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEventCalendarTypeEnumValueOf(
              name);
}
