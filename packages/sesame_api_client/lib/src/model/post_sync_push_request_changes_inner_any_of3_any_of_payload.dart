//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of3_any_of_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload
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
/// * [lastGeneratedDate]
/// * [enabled]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder> {
  @BuiltValueField(wireName: r'tx_type')
  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum get txType;
  // enum txTypeEnum {  expense,  income,  transfer,  };

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'currency_code')
  String get currencyCode;

  @BuiltValueField(wireName: r'category_id')
  String? get categoryId;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'frequency')
  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum get frequency;
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

  @BuiltValueField(wireName: r'last_generated_date')
  DateTime? get lastGeneratedDate;

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload._();

  factory PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadSerializer
    implements
        PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload,
    _$PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'tx_type';
    yield serializers.serialize(
      object.txType,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum),
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
          PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum),
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
    yield r'last_generated_date';
    yield object.lastGeneratedDate == null
        ? null
        : serializers.serialize(
            object.lastGeneratedDate,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload object, {
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
    required PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder result,
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
                PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum;
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
                PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum;
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
        case r'last_generated_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastGeneratedDate = valueDes;
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf3AnyOfPayload deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum
      expense =
      _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum_expense;
  @BuiltValueEnumConst(wireName: r'income')
  static const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum
      income =
      _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum_income;
  @BuiltValueEnumConst(wireName: r'transfer')
  static const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum
      transfer =
      _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum_transfer;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum._(
      String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadTxTypeEnumValueOf(
          name);
}

class PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'daily')
  static const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum
      daily =
      _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum_daily;
  @BuiltValueEnumConst(wireName: r'weekly')
  static const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum
      weekly =
      _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum_weekly;
  @BuiltValueEnumConst(wireName: r'monthly')
  static const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum
      monthly =
      _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum_monthly;
  @BuiltValueEnumConst(wireName: r'yearly')
  static const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum
      yearly =
      _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum_yearly;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf3AnyOfPayloadFrequencyEnumValueOf(
          name);
}
