//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of1_any_of_payload_event.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'day_event.g.dart';

/// DayEvent
///
/// Properties:
/// * [name]
/// * [category]
/// * [countdownMode]
/// * [intervalDays]
/// * [repeatType]
/// * [statisticType]
/// * [event]
/// * [start]
/// * [end]
/// * [createdAt]
/// * [id]
/// * [syncId]
/// * [revision]
/// * [updatedAt]
/// * [deletedAt]
/// * [dayBookId]
@BuiltValue()
abstract class DayEvent implements Built<DayEvent, DayEventBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'category')
  DayEventCategoryEnum get category;
  // enum categoryEnum {  birthday,  anniversary,  countdown,  stage,  };

  @BuiltValueField(wireName: r'countdown_mode')
  DayEventCountdownModeEnum? get countdownMode;
  // enum countdownModeEnum {  fixed_date,  interval_days,  };

  @BuiltValueField(wireName: r'interval_days')
  int? get intervalDays;

  @BuiltValueField(wireName: r'repeat_type')
  DayEventRepeatTypeEnum get repeatType;
  // enum repeatTypeEnum {  none,  yearly,  };

  @BuiltValueField(wireName: r'statistic_type')
  DayEventStatisticTypeEnum get statisticType;
  // enum statisticTypeEnum {  year,  day,  };

  @BuiltValueField(wireName: r'event')
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent? get event;

  @BuiltValueField(wireName: r'start')
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent? get start;

  @BuiltValueField(wireName: r'end')
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent? get end;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'sync_id')
  String get syncId;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'deleted_at')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: r'day_book_id')
  String get dayBookId;

  DayEvent._();

  factory DayEvent([void updates(DayEventBuilder b)]) = _$DayEvent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DayEventBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DayEvent> get serializer => _$DayEventSerializer();
}

class _$DayEventSerializer implements PrimitiveSerializer<DayEvent> {
  @override
  final Iterable<Type> types = const [DayEvent, _$DayEvent];

  @override
  final String wireName = r'DayEvent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DayEvent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(DayEventCategoryEnum),
    );
    yield r'countdown_mode';
    yield object.countdownMode == null
        ? null
        : serializers.serialize(
            object.countdownMode,
            specifiedType: const FullType.nullable(DayEventCountdownModeEnum),
          );
    yield r'interval_days';
    yield object.intervalDays == null
        ? null
        : serializers.serialize(
            object.intervalDays,
            specifiedType: const FullType.nullable(int),
          );
    yield r'repeat_type';
    yield serializers.serialize(
      object.repeatType,
      specifiedType: const FullType(DayEventRepeatTypeEnum),
    );
    yield r'statistic_type';
    yield serializers.serialize(
      object.statisticType,
      specifiedType: const FullType(DayEventStatisticTypeEnum),
    );
    yield r'event';
    yield object.event == null
        ? null
        : serializers.serialize(
            object.event,
            specifiedType: const FullType.nullable(
                PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent),
          );
    yield r'start';
    yield object.start == null
        ? null
        : serializers.serialize(
            object.start,
            specifiedType: const FullType.nullable(
                PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent),
          );
    yield r'end';
    yield object.end == null
        ? null
        : serializers.serialize(
            object.end,
            specifiedType: const FullType.nullable(
                PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent),
          );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'sync_id';
    yield serializers.serialize(
      object.syncId,
      specifiedType: const FullType(String),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'deleted_at';
    yield object.deletedAt == null
        ? null
        : serializers.serialize(
            object.deletedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'day_book_id';
    yield serializers.serialize(
      object.dayBookId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DayEvent object, {
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
    required DayEventBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DayEventCategoryEnum),
          ) as DayEventCategoryEnum;
          result.category = valueDes;
          break;
        case r'countdown_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DayEventCountdownModeEnum),
          ) as DayEventCountdownModeEnum?;
          if (valueDes == null) continue;
          result.countdownMode = valueDes;
          break;
        case r'interval_days':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.intervalDays = valueDes;
          break;
        case r'repeat_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DayEventRepeatTypeEnum),
          ) as DayEventRepeatTypeEnum;
          result.repeatType = valueDes;
          break;
        case r'statistic_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DayEventStatisticTypeEnum),
          ) as DayEventStatisticTypeEnum;
          result.statisticType = valueDes;
          break;
        case r'event':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent),
          ) as PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent?;
          if (valueDes == null) continue;
          result.event.replace(valueDes);
          break;
        case r'start':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent),
          ) as PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent?;
          if (valueDes == null) continue;
          result.start.replace(valueDes);
          break;
        case r'end':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent),
          ) as PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent?;
          if (valueDes == null) continue;
          result.end.replace(valueDes);
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'sync_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.syncId = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'deleted_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deletedAt = valueDes;
          break;
        case r'day_book_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dayBookId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DayEvent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DayEventBuilder();
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

class DayEventCategoryEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'birthday')
  static const DayEventCategoryEnum birthday = _$dayEventCategoryEnum_birthday;
  @BuiltValueEnumConst(wireName: r'anniversary')
  static const DayEventCategoryEnum anniversary =
      _$dayEventCategoryEnum_anniversary;
  @BuiltValueEnumConst(wireName: r'countdown')
  static const DayEventCategoryEnum countdown =
      _$dayEventCategoryEnum_countdown;
  @BuiltValueEnumConst(wireName: r'stage')
  static const DayEventCategoryEnum stage = _$dayEventCategoryEnum_stage;

  static Serializer<DayEventCategoryEnum> get serializer =>
      _$dayEventCategoryEnumSerializer;

  const DayEventCategoryEnum._(String name) : super(name);

  static BuiltSet<DayEventCategoryEnum> get values =>
      _$dayEventCategoryEnumValues;
  static DayEventCategoryEnum valueOf(String name) =>
      _$dayEventCategoryEnumValueOf(name);
}

class DayEventCountdownModeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fixed_date')
  static const DayEventCountdownModeEnum fixedDate =
      _$dayEventCountdownModeEnum_fixedDate;
  @BuiltValueEnumConst(wireName: r'interval_days')
  static const DayEventCountdownModeEnum intervalDays =
      _$dayEventCountdownModeEnum_intervalDays;

  static Serializer<DayEventCountdownModeEnum> get serializer =>
      _$dayEventCountdownModeEnumSerializer;

  const DayEventCountdownModeEnum._(String name) : super(name);

  static BuiltSet<DayEventCountdownModeEnum> get values =>
      _$dayEventCountdownModeEnumValues;
  static DayEventCountdownModeEnum valueOf(String name) =>
      _$dayEventCountdownModeEnumValueOf(name);
}

class DayEventRepeatTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'none')
  static const DayEventRepeatTypeEnum none = _$dayEventRepeatTypeEnum_none;
  @BuiltValueEnumConst(wireName: r'yearly')
  static const DayEventRepeatTypeEnum yearly = _$dayEventRepeatTypeEnum_yearly;

  static Serializer<DayEventRepeatTypeEnum> get serializer =>
      _$dayEventRepeatTypeEnumSerializer;

  const DayEventRepeatTypeEnum._(String name) : super(name);

  static BuiltSet<DayEventRepeatTypeEnum> get values =>
      _$dayEventRepeatTypeEnumValues;
  static DayEventRepeatTypeEnum valueOf(String name) =>
      _$dayEventRepeatTypeEnumValueOf(name);
}

class DayEventStatisticTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'year')
  static const DayEventStatisticTypeEnum year =
      _$dayEventStatisticTypeEnum_year;
  @BuiltValueEnumConst(wireName: r'day')
  static const DayEventStatisticTypeEnum day = _$dayEventStatisticTypeEnum_day;

  static Serializer<DayEventStatisticTypeEnum> get serializer =>
      _$dayEventStatisticTypeEnumSerializer;

  const DayEventStatisticTypeEnum._(String name) : super(name);

  static BuiltSet<DayEventStatisticTypeEnum> get values =>
      _$dayEventStatisticTypeEnumValues;
  static DayEventStatisticTypeEnum valueOf(String name) =>
      _$dayEventStatisticTypeEnumValueOf(name);
}
