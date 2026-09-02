//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/transaction_split.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'transaction.g.dart';

/// Transaction
///
/// Properties:
/// * [id]
/// * [ledgerId]
/// * [txType]
/// * [amount]
/// * [happenedAt]
/// * [note]
/// * [categoryId]
/// * [categoryName]
/// * [categoryKind]
/// * [excludeFromStats]
/// * [currencyCode]
/// * [nativeAmount]
/// * [recurringId]
/// * [createdByMemberId]
/// * [lastEditedByMemberId]
/// * [payerMemberId]
/// * [aaMode]
/// * [splits]
/// * [revision]
/// * [lastEditedAt]
/// * [updatedAt]
/// * [createdAt]
@BuiltValue()
abstract class Transaction implements Built<Transaction, TransactionBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'ledger_id')
  String get ledgerId;

  @BuiltValueField(wireName: r'tx_type')
  TransactionTxTypeEnum get txType;
  // enum txTypeEnum {  expense,  income,  transfer,  };

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'happened_at')
  DateTime get happenedAt;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'category_id')
  String? get categoryId;

  @BuiltValueField(wireName: r'category_name')
  String? get categoryName;

  @BuiltValueField(wireName: r'category_kind')
  TransactionCategoryKindEnum? get categoryKind;
  // enum categoryKindEnum {  expense,  income,  transfer,  };

  @BuiltValueField(wireName: r'exclude_from_stats')
  bool get excludeFromStats;

  @BuiltValueField(wireName: r'currency_code')
  String get currencyCode;

  @BuiltValueField(wireName: r'native_amount')
  String get nativeAmount;

  @BuiltValueField(wireName: r'recurring_id')
  String? get recurringId;

  @BuiltValueField(wireName: r'created_by_member_id')
  String? get createdByMemberId;

  @BuiltValueField(wireName: r'last_edited_by_member_id')
  String? get lastEditedByMemberId;

  @BuiltValueField(wireName: r'payer_member_id')
  String? get payerMemberId;

  @BuiltValueField(wireName: r'aa_mode')
  TransactionAaModeEnum? get aaMode;
  // enum aaModeEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'splits')
  BuiltList<TransactionSplit> get splits;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  @BuiltValueField(wireName: r'last_edited_at')
  DateTime? get lastEditedAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  Transaction._();

  factory Transaction([void updates(TransactionBuilder b)]) = _$Transaction;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TransactionBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<Transaction> get serializer => _$TransactionSerializer();
}

class _$TransactionSerializer implements PrimitiveSerializer<Transaction> {
  @override
  final Iterable<Type> types = const [Transaction, _$Transaction];

  @override
  final String wireName = r'Transaction';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    Transaction object, {
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
      specifiedType: const FullType(TransactionTxTypeEnum),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'happened_at';
    yield serializers.serialize(
      object.happenedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'note';
    yield object.note == null
        ? null
        : serializers.serialize(
            object.note,
            specifiedType: const FullType.nullable(String),
          );
    yield r'category_id';
    yield object.categoryId == null
        ? null
        : serializers.serialize(
            object.categoryId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'category_name';
    yield object.categoryName == null
        ? null
        : serializers.serialize(
            object.categoryName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'category_kind';
    yield object.categoryKind == null
        ? null
        : serializers.serialize(
            object.categoryKind,
            specifiedType: const FullType.nullable(TransactionCategoryKindEnum),
          );
    yield r'exclude_from_stats';
    yield serializers.serialize(
      object.excludeFromStats,
      specifiedType: const FullType(bool),
    );
    yield r'currency_code';
    yield serializers.serialize(
      object.currencyCode,
      specifiedType: const FullType(String),
    );
    yield r'native_amount';
    yield serializers.serialize(
      object.nativeAmount,
      specifiedType: const FullType(String),
    );
    yield r'recurring_id';
    yield object.recurringId == null
        ? null
        : serializers.serialize(
            object.recurringId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'created_by_member_id';
    yield object.createdByMemberId == null
        ? null
        : serializers.serialize(
            object.createdByMemberId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'last_edited_by_member_id';
    yield object.lastEditedByMemberId == null
        ? null
        : serializers.serialize(
            object.lastEditedByMemberId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'payer_member_id';
    yield object.payerMemberId == null
        ? null
        : serializers.serialize(
            object.payerMemberId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'aa_mode';
    yield object.aaMode == null
        ? null
        : serializers.serialize(
            object.aaMode,
            specifiedType: const FullType.nullable(TransactionAaModeEnum),
          );
    yield r'splits';
    yield serializers.serialize(
      object.splits,
      specifiedType: const FullType(BuiltList, [FullType(TransactionSplit)]),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
    yield r'last_edited_at';
    yield object.lastEditedAt == null
        ? null
        : serializers.serialize(
            object.lastEditedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
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
    Transaction object, {
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
    required TransactionBuilder result,
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
            specifiedType: const FullType(TransactionTxTypeEnum),
          ) as TransactionTxTypeEnum;
          result.txType = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'happened_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.happenedAt = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'category_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.categoryId = valueDes;
          break;
        case r'category_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.categoryName = valueDes;
          break;
        case r'category_kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(TransactionCategoryKindEnum),
          ) as TransactionCategoryKindEnum?;
          if (valueDes == null) continue;
          result.categoryKind = valueDes;
          break;
        case r'exclude_from_stats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.excludeFromStats = valueDes;
          break;
        case r'currency_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currencyCode = valueDes;
          break;
        case r'native_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nativeAmount = valueDes;
          break;
        case r'recurring_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.recurringId = valueDes;
          break;
        case r'created_by_member_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.createdByMemberId = valueDes;
          break;
        case r'last_edited_by_member_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.lastEditedByMemberId = valueDes;
          break;
        case r'payer_member_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.payerMemberId = valueDes;
          break;
        case r'aa_mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(TransactionAaModeEnum),
          ) as TransactionAaModeEnum?;
          if (valueDes == null) continue;
          result.aaMode = valueDes;
          break;
        case r'splits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(TransactionSplit)]),
          ) as BuiltList<TransactionSplit>;
          result.splits.replace(valueDes);
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        case r'last_edited_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastEditedAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
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
  Transaction deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TransactionBuilder();
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

class TransactionTxTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const TransactionTxTypeEnum expense = _$transactionTxTypeEnum_expense;
  @BuiltValueEnumConst(wireName: r'income')
  static const TransactionTxTypeEnum income = _$transactionTxTypeEnum_income;
  @BuiltValueEnumConst(wireName: r'transfer')
  static const TransactionTxTypeEnum transfer =
      _$transactionTxTypeEnum_transfer;

  static Serializer<TransactionTxTypeEnum> get serializer =>
      _$transactionTxTypeEnumSerializer;

  const TransactionTxTypeEnum._(String name) : super(name);

  static BuiltSet<TransactionTxTypeEnum> get values =>
      _$transactionTxTypeEnumValues;
  static TransactionTxTypeEnum valueOf(String name) =>
      _$transactionTxTypeEnumValueOf(name);
}

class TransactionCategoryKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const TransactionCategoryKindEnum expense =
      _$transactionCategoryKindEnum_expense;
  @BuiltValueEnumConst(wireName: r'income')
  static const TransactionCategoryKindEnum income =
      _$transactionCategoryKindEnum_income;
  @BuiltValueEnumConst(wireName: r'transfer')
  static const TransactionCategoryKindEnum transfer =
      _$transactionCategoryKindEnum_transfer;

  static Serializer<TransactionCategoryKindEnum> get serializer =>
      _$transactionCategoryKindEnumSerializer;

  const TransactionCategoryKindEnum._(String name) : super(name);

  static BuiltSet<TransactionCategoryKindEnum> get values =>
      _$transactionCategoryKindEnumValues;
  static TransactionCategoryKindEnum valueOf(String name) =>
      _$transactionCategoryKindEnumValueOf(name);
}

class TransactionAaModeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'0')
  static const TransactionAaModeEnum n0 = _$transactionAaModeEnum_n0;
  @BuiltValueEnumConst(wireName: r'1')
  static const TransactionAaModeEnum n1 = _$transactionAaModeEnum_n1;
  @BuiltValueEnumConst(wireName: r'2')
  static const TransactionAaModeEnum n2 = _$transactionAaModeEnum_n2;

  static Serializer<TransactionAaModeEnum> get serializer =>
      _$transactionAaModeEnumSerializer;

  const TransactionAaModeEnum._(String name) : super(name);

  static BuiltSet<TransactionAaModeEnum> get values =>
      _$transactionAaModeEnumValues;
  static TransactionAaModeEnum valueOf(String name) =>
      _$transactionAaModeEnumValueOf(name);
}
