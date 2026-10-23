//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/transaction_split.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_full200_response_recurring_state_occurrences_inner.g.dart';

/// GetSyncFull200ResponseRecurringStateOccurrencesInner
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
/// * [currencyCode]
/// * [nativeAmount]
/// * [recurringId]
/// * [occurrenceDate]
/// * [createdByMemberId]
/// * [lastEditedByMemberId]
/// * [payerMemberId]
/// * [aaMode]
/// * [splits]
/// * [revision]
/// * [lastEditedAt]
/// * [updatedAt]
/// * [createdAt]
/// * [deletedAt]
@BuiltValue()
abstract class GetSyncFull200ResponseRecurringStateOccurrencesInner
    implements
        Built<GetSyncFull200ResponseRecurringStateOccurrencesInner,
            GetSyncFull200ResponseRecurringStateOccurrencesInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'ledger_id')
  String get ledgerId;

  @BuiltValueField(wireName: r'tx_type')
  GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum get txType;
  // enum txTypeEnum {  expense,  };

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
  GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum?
      get categoryKind;
  // enum categoryKindEnum {  expense,  };

  @BuiltValueField(wireName: r'currency_code')
  String get currencyCode;

  @BuiltValueField(wireName: r'native_amount')
  String get nativeAmount;

  @BuiltValueField(wireName: r'recurring_id')
  String? get recurringId;

  @BuiltValueField(wireName: r'occurrence_date')
  Date? get occurrenceDate;

  @BuiltValueField(wireName: r'created_by_member_id')
  String? get createdByMemberId;

  @BuiltValueField(wireName: r'last_edited_by_member_id')
  String? get lastEditedByMemberId;

  @BuiltValueField(wireName: r'payer_member_id')
  String? get payerMemberId;

  @BuiltValueField(wireName: r'aa_mode')
  GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum? get aaMode;
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

  @BuiltValueField(wireName: r'deleted_at')
  DateTime? get deletedAt;

  GetSyncFull200ResponseRecurringStateOccurrencesInner._();

  factory GetSyncFull200ResponseRecurringStateOccurrencesInner(
          [void updates(
              GetSyncFull200ResponseRecurringStateOccurrencesInnerBuilder b)]) =
      _$GetSyncFull200ResponseRecurringStateOccurrencesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetSyncFull200ResponseRecurringStateOccurrencesInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncFull200ResponseRecurringStateOccurrencesInner>
      get serializer =>
          _$GetSyncFull200ResponseRecurringStateOccurrencesInnerSerializer();
}

class _$GetSyncFull200ResponseRecurringStateOccurrencesInnerSerializer
    implements
        PrimitiveSerializer<
            GetSyncFull200ResponseRecurringStateOccurrencesInner> {
  @override
  final Iterable<Type> types = const [
    GetSyncFull200ResponseRecurringStateOccurrencesInner,
    _$GetSyncFull200ResponseRecurringStateOccurrencesInner
  ];

  @override
  final String wireName =
      r'GetSyncFull200ResponseRecurringStateOccurrencesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncFull200ResponseRecurringStateOccurrencesInner object, {
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
          GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum),
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
            specifiedType: const FullType.nullable(
                GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum),
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
    yield r'occurrence_date';
    yield object.occurrenceDate == null
        ? null
        : serializers.serialize(
            object.occurrenceDate,
            specifiedType: const FullType.nullable(Date),
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
            specifiedType: const FullType.nullable(
                GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum),
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
    GetSyncFull200ResponseRecurringStateOccurrencesInner object, {
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
    required GetSyncFull200ResponseRecurringStateOccurrencesInnerBuilder result,
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
                GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum),
          ) as GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum;
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
            specifiedType: const FullType.nullable(
                GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum),
          ) as GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum?;
          if (valueDes == null) continue;
          result.categoryKind = valueDes;
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
        case r'occurrence_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.occurrenceDate = valueDes;
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
            specifiedType: const FullType.nullable(
                GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum),
          ) as GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum?;
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
  GetSyncFull200ResponseRecurringStateOccurrencesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetSyncFull200ResponseRecurringStateOccurrencesInnerBuilder();
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

class GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum
      expense =
      _$getSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum_expense;

  static Serializer<
          GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum>
      get serializer =>
          _$getSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnumSerializer;

  const GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum>
      get values =>
          _$getSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnumValues;
  static GetSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnum valueOf(
          String name) =>
      _$getSyncFull200ResponseRecurringStateOccurrencesInnerTxTypeEnumValueOf(
          name);
}

class GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum
      expense =
      _$getSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum_expense;

  static Serializer<
          GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum>
      get serializer =>
          _$getSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnumSerializer;

  const GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum>
      get values =>
          _$getSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnumValues;
  static GetSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnum
      valueOf(String name) =>
          _$getSyncFull200ResponseRecurringStateOccurrencesInnerCategoryKindEnumValueOf(
              name);
}

class GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'0')
  static const GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum
      n0 = _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum_n0;
  @BuiltValueEnumConst(wireName: r'1')
  static const GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum
      n1 = _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum_n1;
  @BuiltValueEnumConst(wireName: r'2')
  static const GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum
      n2 = _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum_n2;

  static Serializer<
          GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum>
      get serializer =>
          _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnumSerializer;

  const GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum>
      get values =>
          _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnumValues;
  static GetSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnum valueOf(
          String name) =>
      _$getSyncFull200ResponseRecurringStateOccurrencesInnerAaModeEnumValueOf(
          name);
}
