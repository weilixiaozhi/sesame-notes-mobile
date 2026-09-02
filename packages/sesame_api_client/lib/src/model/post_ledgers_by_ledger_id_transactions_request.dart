//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_transactions_request_splits_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_transactions_request.g.dart';

/// PostLedgersByLedgerIdTransactionsRequest
///
/// Properties:
/// * [id]
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
abstract class PostLedgersByLedgerIdTransactionsRequest
    implements
        Built<PostLedgersByLedgerIdTransactionsRequest,
            PostLedgersByLedgerIdTransactionsRequestBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'tx_type')
  PostLedgersByLedgerIdTransactionsRequestTxTypeEnum get txType;
  // enum txTypeEnum {  expense,  income,  transfer,  };

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'happened_at')
  DateTime get happenedAt;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'category_id')
  String? get categoryId;

  @BuiltValueField(wireName: r'exclude_from_stats')
  bool? get excludeFromStats;

  @BuiltValueField(wireName: r'currency_code')
  String get currencyCode;

  @BuiltValueField(wireName: r'native_amount')
  String get nativeAmount;

  @BuiltValueField(wireName: r'recurring_id')
  String? get recurringId;

  @BuiltValueField(wireName: r'payer_member_id')
  String? get payerMemberId;

  @BuiltValueField(wireName: r'aa_mode')
  PostLedgersByLedgerIdTransactionsRequestAaModeEnum? get aaMode;
  // enum aaModeEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'splits')
  BuiltList<PostLedgersByLedgerIdTransactionsRequestSplitsInner>? get splits;

  @BuiltValueField(wireName: r'base_revision')
  int? get baseRevision;

  PostLedgersByLedgerIdTransactionsRequest._();

  factory PostLedgersByLedgerIdTransactionsRequest(
          [void updates(PostLedgersByLedgerIdTransactionsRequestBuilder b)]) =
      _$PostLedgersByLedgerIdTransactionsRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostLedgersByLedgerIdTransactionsRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdTransactionsRequest> get serializer =>
      _$PostLedgersByLedgerIdTransactionsRequestSerializer();
}

class _$PostLedgersByLedgerIdTransactionsRequestSerializer
    implements PrimitiveSerializer<PostLedgersByLedgerIdTransactionsRequest> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdTransactionsRequest,
    _$PostLedgersByLedgerIdTransactionsRequest
  ];

  @override
  final String wireName = r'PostLedgersByLedgerIdTransactionsRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdTransactionsRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
    yield r'tx_type';
    yield serializers.serialize(
      object.txType,
      specifiedType:
          const FullType(PostLedgersByLedgerIdTransactionsRequestTxTypeEnum),
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
            PostLedgersByLedgerIdTransactionsRequestAaModeEnum),
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
    if (object.baseRevision != null) {
      yield r'base_revision';
      yield serializers.serialize(
        object.baseRevision,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdTransactionsRequest object, {
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
    required PostLedgersByLedgerIdTransactionsRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.id = valueDes;
          break;
        case r'tx_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostLedgersByLedgerIdTransactionsRequestTxTypeEnum),
          ) as PostLedgersByLedgerIdTransactionsRequestTxTypeEnum;
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
                PostLedgersByLedgerIdTransactionsRequestAaModeEnum),
          ) as PostLedgersByLedgerIdTransactionsRequestAaModeEnum?;
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
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
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
  PostLedgersByLedgerIdTransactionsRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdTransactionsRequestBuilder();
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

class PostLedgersByLedgerIdTransactionsRequestTxTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const PostLedgersByLedgerIdTransactionsRequestTxTypeEnum expense =
      _$postLedgersByLedgerIdTransactionsRequestTxTypeEnum_expense;
  @BuiltValueEnumConst(wireName: r'income')
  static const PostLedgersByLedgerIdTransactionsRequestTxTypeEnum income =
      _$postLedgersByLedgerIdTransactionsRequestTxTypeEnum_income;
  @BuiltValueEnumConst(wireName: r'transfer')
  static const PostLedgersByLedgerIdTransactionsRequestTxTypeEnum transfer =
      _$postLedgersByLedgerIdTransactionsRequestTxTypeEnum_transfer;

  static Serializer<PostLedgersByLedgerIdTransactionsRequestTxTypeEnum>
      get serializer =>
          _$postLedgersByLedgerIdTransactionsRequestTxTypeEnumSerializer;

  const PostLedgersByLedgerIdTransactionsRequestTxTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostLedgersByLedgerIdTransactionsRequestTxTypeEnum>
      get values => _$postLedgersByLedgerIdTransactionsRequestTxTypeEnumValues;
  static PostLedgersByLedgerIdTransactionsRequestTxTypeEnum valueOf(
          String name) =>
      _$postLedgersByLedgerIdTransactionsRequestTxTypeEnumValueOf(name);
}

class PostLedgersByLedgerIdTransactionsRequestAaModeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'0')
  static const PostLedgersByLedgerIdTransactionsRequestAaModeEnum n0 =
      _$postLedgersByLedgerIdTransactionsRequestAaModeEnum_n0;
  @BuiltValueEnumConst(wireName: r'1')
  static const PostLedgersByLedgerIdTransactionsRequestAaModeEnum n1 =
      _$postLedgersByLedgerIdTransactionsRequestAaModeEnum_n1;
  @BuiltValueEnumConst(wireName: r'2')
  static const PostLedgersByLedgerIdTransactionsRequestAaModeEnum n2 =
      _$postLedgersByLedgerIdTransactionsRequestAaModeEnum_n2;

  static Serializer<PostLedgersByLedgerIdTransactionsRequestAaModeEnum>
      get serializer =>
          _$postLedgersByLedgerIdTransactionsRequestAaModeEnumSerializer;

  const PostLedgersByLedgerIdTransactionsRequestAaModeEnum._(String name)
      : super(name);

  static BuiltSet<PostLedgersByLedgerIdTransactionsRequestAaModeEnum>
      get values => _$postLedgersByLedgerIdTransactionsRequestAaModeEnumValues;
  static PostLedgersByLedgerIdTransactionsRequestAaModeEnum valueOf(
          String name) =>
      _$postLedgersByLedgerIdTransactionsRequestAaModeEnumValueOf(name);
}
