//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of6_any_of_payload_initial_state.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of6_any_of_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload
///
/// Properties:
/// * [txType]
/// * [amount]
/// * [currencyCode]
/// * [categoryId]
/// * [note]
/// * [frequency]
/// * [interval]
/// * [dayOfMonth]
/// * [dayOfWeek]
/// * [monthOfYear]
/// * [startDate]
/// * [endDate]
/// * [protocolVersion]
/// * [timeZone]
/// * [enabled]
/// * [initialState]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder> {
  @BuiltValueField(wireName: r'tx_type')
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum get txType;
  // enum txTypeEnum {  expense,  };

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'currency_code')
  String get currencyCode;

  @BuiltValueField(wireName: r'category_id')
  String? get categoryId;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'frequency')
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum get frequency;
  // enum frequencyEnum {  daily,  weekly,  monthly,  yearly,  };

  @BuiltValueField(wireName: r'interval')
  int get interval;

  @BuiltValueField(wireName: r'day_of_month')
  int? get dayOfMonth;

  @BuiltValueField(wireName: r'day_of_week')
  int? get dayOfWeek;

  @BuiltValueField(wireName: r'month_of_year')
  int? get monthOfYear;

  @BuiltValueField(wireName: r'start_date')
  DateTime get startDate;

  @BuiltValueField(wireName: r'end_date')
  DateTime? get endDate;

  @BuiltValueField(wireName: r'protocol_version')
  int get protocolVersion;

  @BuiltValueField(wireName: r'time_zone')
  String get timeZone;

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'initial_state')
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState?
      get initialState;

  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload._();

  factory PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload,
    _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'tx_type';
    yield serializers.serialize(
      object.txType,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'currency_code';
    yield serializers.serialize(
      object.currencyCode,
      specifiedType: const FullType(String),
    );
    yield r'category_id';
    yield object.categoryId == null
        ? null
        : serializers.serialize(
            object.categoryId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'note';
    yield object.note == null
        ? null
        : serializers.serialize(
            object.note,
            specifiedType: const FullType.nullable(String),
          );
    yield r'frequency';
    yield serializers.serialize(
      object.frequency,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum),
    );
    yield r'interval';
    yield serializers.serialize(
      object.interval,
      specifiedType: const FullType(int),
    );
    yield r'day_of_month';
    yield object.dayOfMonth == null
        ? null
        : serializers.serialize(
            object.dayOfMonth,
            specifiedType: const FullType.nullable(int),
          );
    yield r'day_of_week';
    yield object.dayOfWeek == null
        ? null
        : serializers.serialize(
            object.dayOfWeek,
            specifiedType: const FullType.nullable(int),
          );
    yield r'month_of_year';
    yield object.monthOfYear == null
        ? null
        : serializers.serialize(
            object.monthOfYear,
            specifiedType: const FullType.nullable(int),
          );
    yield r'start_date';
    yield serializers.serialize(
      object.startDate,
      specifiedType: const FullType(DateTime),
    );
    yield r'end_date';
    yield object.endDate == null
        ? null
        : serializers.serialize(
            object.endDate,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'protocol_version';
    yield serializers.serialize(
      object.protocolVersion,
      specifiedType: const FullType(int),
    );
    yield r'time_zone';
    yield serializers.serialize(
      object.timeZone,
      specifiedType: const FullType(String),
    );
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
    if (object.initialState != null) {
      yield r'initial_state';
      yield serializers.serialize(
        object.initialState,
        specifiedType: const FullType(
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tx_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum;
          result.txType = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'currency_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currencyCode = valueDes;
          break;
        case r'category_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.categoryId = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'frequency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum;
          result.frequency = valueDes;
          break;
        case r'interval':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.interval = valueDes;
          break;
        case r'day_of_month':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.dayOfMonth = valueDes;
          break;
        case r'day_of_week':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.dayOfWeek = valueDes;
          break;
        case r'month_of_year':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.monthOfYear = valueDes;
          break;
        case r'start_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startDate = valueDes;
          break;
        case r'end_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endDate = valueDes;
          break;
        case r'protocol_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.protocolVersion = valueDes;
          break;
        case r'time_zone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.timeZone = valueDes;
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        case r'initial_state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState),
          ) as PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialState?;
          if (valueDes == null) continue;
          result.initialState.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum
      expense =
      _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum_expense;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum._(
      String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadTxTypeEnumValueOf(
          name);
}

class PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'daily')
  static const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum
      daily =
      _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum_daily;
  @BuiltValueEnumConst(wireName: r'weekly')
  static const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum
      weekly =
      _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum_weekly;
  @BuiltValueEnumConst(wireName: r'monthly')
  static const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum
      monthly =
      _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum_monthly;
  @BuiltValueEnumConst(wireName: r'yearly')
  static const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum
      yearly =
      _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum_yearly;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadFrequencyEnumValueOf(
          name);
}
