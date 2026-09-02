//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recurring_transaction.g.dart';

/// RecurringTransaction
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
/// * [enabled]
/// * [updatedAt]
@BuiltValue()
abstract class RecurringTransaction
    implements Built<RecurringTransaction, RecurringTransactionBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'ledger_id')
  String get ledgerId;

  @BuiltValueField(wireName: r'tx_type')
  RecurringTransactionTxTypeEnum get txType;
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
  RecurringTransactionFrequencyEnum get frequency;
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

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  RecurringTransaction._();

  factory RecurringTransaction([void updates(RecurringTransactionBuilder b)]) =
      _$RecurringTransaction;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecurringTransactionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecurringTransaction> get serializer =>
      _$RecurringTransactionSerializer();
}

class _$RecurringTransactionSerializer
    implements PrimitiveSerializer<RecurringTransaction> {
  @override
  final Iterable<Type> types = const [
    RecurringTransaction,
    _$RecurringTransaction
  ];

  @override
  final String wireName = r'RecurringTransaction';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecurringTransaction object, {
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
      specifiedType: const FullType(RecurringTransactionTxTypeEnum),
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
      specifiedType: const FullType(RecurringTransactionFrequencyEnum),
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
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RecurringTransaction object, {
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
    required RecurringTransactionBuilder result,
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
            specifiedType: const FullType(RecurringTransactionTxTypeEnum),
          ) as RecurringTransactionTxTypeEnum;
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
            specifiedType: const FullType(RecurringTransactionFrequencyEnum),
          ) as RecurringTransactionFrequencyEnum;
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
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RecurringTransaction deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecurringTransactionBuilder();
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

class RecurringTransactionTxTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const RecurringTransactionTxTypeEnum expense =
      _$recurringTransactionTxTypeEnum_expense;
  @BuiltValueEnumConst(wireName: r'income')
  static const RecurringTransactionTxTypeEnum income =
      _$recurringTransactionTxTypeEnum_income;
  @BuiltValueEnumConst(wireName: r'transfer')
  static const RecurringTransactionTxTypeEnum transfer =
      _$recurringTransactionTxTypeEnum_transfer;

  static Serializer<RecurringTransactionTxTypeEnum> get serializer =>
      _$recurringTransactionTxTypeEnumSerializer;

  const RecurringTransactionTxTypeEnum._(String name) : super(name);

  static BuiltSet<RecurringTransactionTxTypeEnum> get values =>
      _$recurringTransactionTxTypeEnumValues;
  static RecurringTransactionTxTypeEnum valueOf(String name) =>
      _$recurringTransactionTxTypeEnumValueOf(name);
}

class RecurringTransactionFrequencyEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'daily')
  static const RecurringTransactionFrequencyEnum daily =
      _$recurringTransactionFrequencyEnum_daily;
  @BuiltValueEnumConst(wireName: r'weekly')
  static const RecurringTransactionFrequencyEnum weekly =
      _$recurringTransactionFrequencyEnum_weekly;
  @BuiltValueEnumConst(wireName: r'monthly')
  static const RecurringTransactionFrequencyEnum monthly =
      _$recurringTransactionFrequencyEnum_monthly;
  @BuiltValueEnumConst(wireName: r'yearly')
  static const RecurringTransactionFrequencyEnum yearly =
      _$recurringTransactionFrequencyEnum_yearly;

  static Serializer<RecurringTransactionFrequencyEnum> get serializer =>
      _$recurringTransactionFrequencyEnumSerializer;

  const RecurringTransactionFrequencyEnum._(String name) : super(name);

  static BuiltSet<RecurringTransactionFrequencyEnum> get values =>
      _$recurringTransactionFrequencyEnumValues;
  static RecurringTransactionFrequencyEnum valueOf(String name) =>
      _$recurringTransactionFrequencyEnumValueOf(name);
}
