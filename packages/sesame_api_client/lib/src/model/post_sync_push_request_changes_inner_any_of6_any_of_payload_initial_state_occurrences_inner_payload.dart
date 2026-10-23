//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/date.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_transactions_request_splits_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of6_any_of_payload_initial_state_occurrences_inner_payload.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload
///
/// Properties:
/// * [txType]
/// * [amount]
/// * [happenedAt]
/// * [note]
/// * [categoryId]
/// * [currencyCode]
/// * [nativeAmount]
/// * [recurringId]
/// * [occurrenceDate]
/// * [payerMemberId]
/// * [aaMode]
/// * [splits]
/// * [lastEditedAt]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload
    implements
        Built<
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload,
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadBuilder> {
  @BuiltValueField(wireName: r'tx_type')
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadTxTypeEnum
      get txType;
  // enum txTypeEnum {  expense,  };

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'happened_at')
  DateTime get happenedAt;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'category_id')
  String? get categoryId;

  @BuiltValueField(wireName: r'currency_code')
  String get currencyCode;

  @BuiltValueField(wireName: r'native_amount')
  String get nativeAmount;

  @BuiltValueField(wireName: r'recurring_id')
  String? get recurringId;

  @BuiltValueField(wireName: r'occurrence_date')
  Date? get occurrenceDate;

  @BuiltValueField(wireName: r'payer_member_id')
  String? get payerMemberId;

  @BuiltValueField(wireName: r'aa_mode')
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnum?
      get aaMode;
  // enum aaModeEnum {  0,  1,  2,  };

  @BuiltValueField(wireName: r'splits')
  BuiltList<PostLedgersByLedgerIdTransactionsRequestSplitsInner>? get splits;

  @BuiltValueField(wireName: r'last_edited_at')
  DateTime? get lastEditedAt;

  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload._();

  factory PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadBuilder
                  b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload,
    _$PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload
  ];

  @override
  final String wireName =
      r'PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'tx_type';
    yield serializers.serialize(
      object.txType,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadTxTypeEnum),
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
    if (object.occurrenceDate != null) {
      yield r'occurrence_date';
      yield serializers.serialize(
        object.occurrenceDate,
        specifiedType: const FullType.nullable(Date),
      );
    }
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
                PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnum),
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
    PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload
        object, {
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
    required PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadBuilder
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
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadTxTypeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadTxTypeEnum;
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
                PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnum),
          ) as PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnum?;
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
  PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayload
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadTxTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'expense')
  static const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadTxTypeEnum
      expense =
      _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadTxTypeEnum_expense;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadTxTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadTxTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadTxTypeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadTxTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadTxTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadTxTypeEnum
      valueOf(String name) =>
          _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadTxTypeEnumValueOf(
              name);
}

class PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'0')
  static const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnum
      n0 =
      _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnum_n0;
  @BuiltValueEnumConst(wireName: r'1')
  static const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnum
      n1 =
      _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnum_n1;
  @BuiltValueEnumConst(wireName: r'2')
  static const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnum
      n2 =
      _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnum_n2;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnum
      valueOf(String name) =>
          _$postSyncPushRequestChangesInnerAnyOf6AnyOfPayloadInitialStateOccurrencesInnerPayloadAaModeEnumValueOf(
              name);
}
