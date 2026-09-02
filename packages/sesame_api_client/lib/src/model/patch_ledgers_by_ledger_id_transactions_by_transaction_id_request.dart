//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_transactions_request_splits_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'patch_ledgers_by_ledger_id_transactions_by_transaction_id_request.g.dart';

/// PatchLedgersByLedgerIdTransactionsByTransactionIdRequest
///
/// Properties:
/// * [txType]
/// * [amount]
/// * [happenedAt]
/// * [note]
/// * [categoryId]
/// * [excludeFromStats]
/// * [currencyCode]
/// * [nativeAmount]
/// * [recurringId]
/// * [payerMemberId]
/// * [aaMode]
/// * [splits]
/// * [baseRevision]
@BuiltValue()
abstract class PatchLedgersByLedgerIdTransactionsByTransactionIdRequest
    implements
        Built<PatchLedgersByLedgerIdTransactionsByTransactionIdRequest,
            PatchLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder> {
  @BuiltValueField(wireName: r'tx_type')
  PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum?
      get txType;
  // enum txTypeEnum {  expense,  income,  transfer,  };

  @BuiltValueField(wireName: r'amount')
  String? get amount;

  @BuiltValueField(wireName: r'happened_at')
  DateTime? get happenedAt;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'category_id')
  String? get categoryId;

  @BuiltValueField(wireName: r'exclude_from_stats')
  bool? get excludeFromStats;

  @BuiltValueField(wireName: r'currency_code')
  String? get currencyCode;

  @BuiltValueField(wireName: r'native_amount')
  String? get nativeAmount;

  @BuiltValueField(wireName: r'recurring_id')
  String? get recurringId;

  @BuiltValueField(wireName: r'payer_member_id')
  String? get payerMemberId;

  @BuiltValueField(wireName: r'aa_mode')
  PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum?
      get aaMode;
  // enum aaModeEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'splits')
  BuiltList<PostLedgersByLedgerIdTransactionsRequestSplitsInner>? get splits;

  @BuiltValueField(wireName: r'base_revision')
  int get baseRevision;

  PatchLedgersByLedgerIdTransactionsByTransactionIdRequest._();

  factory PatchLedgersByLedgerIdTransactionsByTransactionIdRequest(
      [void updates(
          PatchLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder
              b)]) = _$PatchLedgersByLedgerIdTransactionsByTransactionIdRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PatchLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PatchLedgersByLedgerIdTransactionsByTransactionIdRequest>
      get serializer =>
          _$PatchLedgersByLedgerIdTransactionsByTransactionIdRequestSerializer();
}

class _$PatchLedgersByLedgerIdTransactionsByTransactionIdRequestSerializer
    implements
        PrimitiveSerializer<
            PatchLedgersByLedgerIdTransactionsByTransactionIdRequest> {
  @override
  final Iterable<Type> types = const [
    PatchLedgersByLedgerIdTransactionsByTransactionIdRequest,
    _$PatchLedgersByLedgerIdTransactionsByTransactionIdRequest
  ];

  @override
  final String wireName =
      r'PatchLedgersByLedgerIdTransactionsByTransactionIdRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PatchLedgersByLedgerIdTransactionsByTransactionIdRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.txType != null) {
      yield r'tx_type';
      yield serializers.serialize(
        object.txType,
        specifiedType: const FullType(
            PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum),
      );
    }
    if (object.amount != null) {
      yield r'amount';
      yield serializers.serialize(
        object.amount,
        specifiedType: const FullType(String),
      );
    }
    if (object.happenedAt != null) {
      yield r'happened_at';
      yield serializers.serialize(
        object.happenedAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.categoryId != null) {
      yield r'category_id';
      yield serializers.serialize(
        object.categoryId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.excludeFromStats != null) {
      yield r'exclude_from_stats';
      yield serializers.serialize(
        object.excludeFromStats,
        specifiedType: const FullType(bool),
      );
    }
    if (object.currencyCode != null) {
      yield r'currency_code';
      yield serializers.serialize(
        object.currencyCode,
        specifiedType: const FullType(String),
      );
    }
    if (object.nativeAmount != null) {
      yield r'native_amount';
      yield serializers.serialize(
        object.nativeAmount,
        specifiedType: const FullType(String),
      );
    }
    if (object.recurringId != null) {
      yield r'recurring_id';
      yield serializers.serialize(
        object.recurringId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.payerMemberId != null) {
      yield r'payer_member_id';
      yield serializers.serialize(
        object.payerMemberId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.aaMode != null) {
      yield r'aa_mode';
      yield serializers.serialize(
        object.aaMode,
        specifiedType: const FullType.nullable(
            PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum),
      );
    }
    if (object.splits != null) {
      yield r'splits';
      yield serializers.serialize(
        object.splits,
        specifiedType: const FullType.nullable(BuiltList,
            [FullType(PostLedgersByLedgerIdTransactionsRequestSplitsInner)]),
      );
    }
    yield r'base_revision';
    yield serializers.serialize(
      object.baseRevision,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PatchLedgersByLedgerIdTransactionsByTransactionIdRequest object, {
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
    required PatchLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'tx_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum),
          ) as PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum?;
          if (valueDes == null) continue;
          result.txType = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.amount = valueDes;
          break;
        case r'happened_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
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
        case r'exclude_from_stats':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.excludeFromStats = valueDes;
          break;
        case r'currency_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.currencyCode = valueDes;
          break;
        case r'native_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
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
                PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum),
          ) as PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum?;
          if (valueDes == null) continue;
          result.aaMode = valueDes;
          break;
        case r'splits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList, [
              FullType(PostLedgersByLedgerIdTransactionsRequestSplitsInner)
            ]),
          ) as BuiltList<PostLedgersByLedgerIdTransactionsRequestSplitsInner>?;
          if (valueDes == null) continue;
          result.splits.replace(valueDes);
          break;
        case r'base_revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.baseRevision = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PatchLedgersByLedgerIdTransactionsByTransactionIdRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PatchLedgersByLedgerIdTransactionsByTransactionIdRequestBuilder();
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

class PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum
      expense =
      _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum_expense;
  @BuiltValueEnumConst(wireName: r'income')
  static const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum
      income =
      _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum_income;
  @BuiltValueEnumConst(wireName: r'transfer')
  static const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum
      transfer =
      _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum_transfer;

  static Serializer<
          PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum>
      get serializer =>
          _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnumSerializer;

  const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum>
      get values =>
          _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnumValues;
  static PatchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnum valueOf(
          String name) =>
      _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestTxTypeEnumValueOf(
          name);
}

class PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'0')
  static const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum
      n0 =
      _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum_n0;
  @BuiltValueEnumConst(wireName: r'1')
  static const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum
      n1 =
      _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum_n1;
  @BuiltValueEnumConst(wireName: r'2')
  static const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum
      n2 =
      _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum_n2;

  static Serializer<
          PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum>
      get serializer =>
          _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnumSerializer;

  const PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum>
      get values =>
          _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnumValues;
  static PatchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnum valueOf(
          String name) =>
      _$patchLedgersByLedgerIdTransactionsByTransactionIdRequestAaModeEnumValueOf(
          name);
}
