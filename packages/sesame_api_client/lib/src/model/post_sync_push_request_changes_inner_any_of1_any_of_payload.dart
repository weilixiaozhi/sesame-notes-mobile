//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of1_any_of_payload_event.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of1_any_of_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload
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
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'category')
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum get category;
  // enum categoryEnum {  birthday,  anniversary,  countdown,  stage,  };

  @BuiltValueField(wireName: r'countdown_mode')
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnum?
      get countdownMode;
  // enum countdownModeEnum {  fixed_date,  interval_days,  };

  @BuiltValueField(wireName: r'interval_days')
  int? get intervalDays;

  @BuiltValueField(wireName: r'repeat_type')
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnum
      get repeatType;
  // enum repeatTypeEnum {  none,  yearly,  };

  @BuiltValueField(wireName: r'statistic_type')
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnum
      get statisticType;
  // enum statisticTypeEnum {  year,  day,  };

  @BuiltValueField(wireName: r'event')
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent? get event;

  @BuiltValueField(wireName: r'start')
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent? get start;

  @BuiltValueField(wireName: r'end')
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadEvent? get end;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload._();

  factory PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload,
    _$PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload object, {
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
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum),
    );
    yield r'countdown_mode';
    yield object.countdownMode == null
        ? null
        : serializers.serialize(
            object.countdownMode,
            specifiedType: const FullType.nullable(
                PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnum),
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
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnum),
    );
    yield r'statistic_type';
    yield serializers.serialize(
      object.statisticType,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder result,
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
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum;
          result.category = valueDes;
          break;
        case r'countdown_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnum?;
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
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnum;
          result.repeatType = valueDes;
          break;
        case r'statistic_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'birthday')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum
      birthday =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum_birthday;
  @BuiltValueEnumConst(wireName: r'anniversary')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum
      anniversary =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum_anniversary;
  @BuiltValueEnumConst(wireName: r'countdown')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum
      countdown =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum_countdown;
  @BuiltValueEnumConst(wireName: r'stage')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum
      stage =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum_stage;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum._(
      String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCategoryEnumValueOf(
          name);
}

class PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fixed_date')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnum
      fixedDate =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnum_fixedDate;
  @BuiltValueEnumConst(wireName: r'interval_days')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnum
      intervalDays =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnum_intervalDays;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadCountdownModeEnumValueOf(
          name);
}

class PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'none')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnum
      none =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnum_none;
  @BuiltValueEnumConst(wireName: r'yearly')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnum
      yearly =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnum_yearly;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadRepeatTypeEnumValueOf(
          name);
}

class PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'year')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnum
      year =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnum_year;
  @BuiltValueEnumConst(wireName: r'day')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnum
      day =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnum_day;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadStatisticTypeEnumValueOf(
          name);
}
