//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_full200_response_recurring_state_rules_inner.g.dart';

/// GetSyncFull200ResponseRecurringStateRulesInner
///
/// Properties:
/// * [id]
/// * [ledgerId]
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
/// * [protocolVersion]
/// * [timeZone]
/// * [enabled]
/// * [updatedAt]
/// * [deletedAt]
@BuiltValue()
abstract class GetSyncFull200ResponseRecurringStateRulesInner
    implements
        Built<GetSyncFull200ResponseRecurringStateRulesInner,
            GetSyncFull200ResponseRecurringStateRulesInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'ledger_id')
  String get ledgerId;

  @BuiltValueField(wireName: r'tx_type')
  GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum get txType;
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
  GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum get frequency;
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

  @BuiltValueField(wireName: r'protocol_version')
  int get protocolVersion;

  @BuiltValueField(wireName: r'time_zone')
  String get timeZone;

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'deleted_at')
  DateTime? get deletedAt;

  GetSyncFull200ResponseRecurringStateRulesInner._();

  factory GetSyncFull200ResponseRecurringStateRulesInner(
          [void updates(
              GetSyncFull200ResponseRecurringStateRulesInnerBuilder b)]) =
      _$GetSyncFull200ResponseRecurringStateRulesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetSyncFull200ResponseRecurringStateRulesInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncFull200ResponseRecurringStateRulesInner>
      get serializer =>
          _$GetSyncFull200ResponseRecurringStateRulesInnerSerializer();
}

class _$GetSyncFull200ResponseRecurringStateRulesInnerSerializer
    implements
        PrimitiveSerializer<GetSyncFull200ResponseRecurringStateRulesInner> {
  @override
  final Iterable<Type> types = const [
    GetSyncFull200ResponseRecurringStateRulesInner,
    _$GetSyncFull200ResponseRecurringStateRulesInner
  ];

  @override
  final String wireName = r'GetSyncFull200ResponseRecurringStateRulesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncFull200ResponseRecurringStateRulesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'ledger_id';
    yield serializers.serialize(
      object.ledgerId,
      specifiedType: const FullType(String),
    );
    yield r'tx_type';
    yield serializers.serialize(
      object.txType,
      specifiedType: const FullType(
          GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum),
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
          GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    GetSyncFull200ResponseRecurringStateRulesInner object, {
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
    required GetSyncFull200ResponseRecurringStateRulesInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'ledger_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ledgerId = valueDes;
          break;
        case r'tx_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum),
          ) as GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum;
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
                GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum),
          ) as GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetSyncFull200ResponseRecurringStateRulesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetSyncFull200ResponseRecurringStateRulesInnerBuilder();
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

class GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum
      expense =
      _$getSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum_expense;

  static Serializer<GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum>
      get serializer =>
          _$getSyncFull200ResponseRecurringStateRulesInnerTxTypeEnumSerializer;

  const GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum._(String name)
      : super(name);

  static BuiltSet<GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum>
      get values =>
          _$getSyncFull200ResponseRecurringStateRulesInnerTxTypeEnumValues;
  static GetSyncFull200ResponseRecurringStateRulesInnerTxTypeEnum valueOf(
          String name) =>
      _$getSyncFull200ResponseRecurringStateRulesInnerTxTypeEnumValueOf(name);
}

class GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'daily')
  static const GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum
      daily =
      _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum_daily;
  @BuiltValueEnumConst(wireName: r'weekly')
  static const GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum
      weekly =
      _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum_weekly;
  @BuiltValueEnumConst(wireName: r'monthly')
  static const GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum
      monthly =
      _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum_monthly;
  @BuiltValueEnumConst(wireName: r'yearly')
  static const GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum
      yearly =
      _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum_yearly;

  static Serializer<GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum>
      get serializer =>
          _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnumSerializer;

  const GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum._(
      String name)
      : super(name);

  static BuiltSet<GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum>
      get values =>
          _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnumValues;
  static GetSyncFull200ResponseRecurringStateRulesInnerFrequencyEnum valueOf(
          String name) =>
      _$getSyncFull200ResponseRecurringStateRulesInnerFrequencyEnumValueOf(
          name);
}
