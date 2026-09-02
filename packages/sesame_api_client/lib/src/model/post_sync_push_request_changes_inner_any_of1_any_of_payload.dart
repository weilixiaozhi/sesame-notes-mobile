//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_transactions_request_splits_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of1_any_of_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload
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
/// * [version]
/// * [lastEditedAt]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadBuilder> {
  @BuiltValueField(wireName: r'tx_type')
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum get txType;
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
  bool get excludeFromStats;

  @BuiltValueField(wireName: r'currency_code')
  String get currencyCode;

  @BuiltValueField(wireName: r'native_amount')
  String get nativeAmount;

  @BuiltValueField(wireName: r'recurring_id')
  String? get recurringId;

  @BuiltValueField(wireName: r'payer_member_id')
  String? get payerMemberId;

  @BuiltValueField(wireName: r'aa_mode')
  PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum? get aaMode;
  // enum aaModeEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'splits')
  BuiltList<PostLedgersByLedgerIdTransactionsRequestSplitsInner>? get splits;

  @BuiltValueField(wireName: r'version')
  int? get version;

  @BuiltValueField(wireName: r'last_edited_at')
  DateTime? get lastEditedAt;

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
    yield r'tx_type';
    yield serializers.serialize(
      object.txType,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum),
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
    if (object.payerMemberId != null) {
      yield r'payer_member_id';
      yield serializers.serialize(
        object.payerMemberId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'aa_mode';
    yield object.aaMode == null
        ? null
        : serializers.serialize(
            object.aaMode,
            specifiedType: const FullType.nullable(
                PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum),
          );
    yield r'splits';
    yield object.splits == null
        ? null
        : serializers.serialize(
            object.splits,
            specifiedType: const FullType.nullable(BuiltList, [
              FullType(PostLedgersByLedgerIdTransactionsRequestSplitsInner)
            ]),
          );
    if (object.version != null) {
      yield r'version';
      yield serializers.serialize(
        object.version,
        specifiedType: const FullType(int),
      );
    }
    yield r'last_edited_at';
    yield object.lastEditedAt == null
        ? null
        : serializers.serialize(
            object.lastEditedAt,
            specifiedType: const FullType.nullable(DateTime),
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
        case r'tx_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum;
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
                PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum?;
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
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.version = valueDes;
          break;
        case r'last_edited_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastEditedAt = valueDes;
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

class PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum
      expense =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum_expense;
  @BuiltValueEnumConst(wireName: r'income')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum
      income =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum_income;
  @BuiltValueEnumConst(wireName: r'transfer')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum
      transfer =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum_transfer;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum._(
      String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadTxTypeEnumValueOf(
          name);
}

class PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'0')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum n0 =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum_n0;
  @BuiltValueEnumConst(wireName: r'1')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum n1 =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum_n1;
  @BuiltValueEnumConst(wireName: r'2')
  static const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum n2 =
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum_n2;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum._(
      String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf1AnyOfPayloadAaModeEnumValueOf(
          name);
}
