//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_transactions_request_splits_inner.g.dart';

/// PostLedgersByLedgerIdTransactionsRequestSplitsInner
///
/// Properties:
/// * [memberId]
/// * [amount]
@BuiltValue()
abstract class PostLedgersByLedgerIdTransactionsRequestSplitsInner
    implements
        Built<PostLedgersByLedgerIdTransactionsRequestSplitsInner,
            PostLedgersByLedgerIdTransactionsRequestSplitsInnerBuilder> {
  @BuiltValueField(wireName: r'member_id')
  String? get memberId;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  PostLedgersByLedgerIdTransactionsRequestSplitsInner._();

  factory PostLedgersByLedgerIdTransactionsRequestSplitsInner(
          [void updates(
              PostLedgersByLedgerIdTransactionsRequestSplitsInnerBuilder b)]) =
      _$PostLedgersByLedgerIdTransactionsRequestSplitsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostLedgersByLedgerIdTransactionsRequestSplitsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdTransactionsRequestSplitsInner>
      get serializer =>
          _$PostLedgersByLedgerIdTransactionsRequestSplitsInnerSerializer();
}

class _$PostLedgersByLedgerIdTransactionsRequestSplitsInnerSerializer
    implements
        PrimitiveSerializer<
            PostLedgersByLedgerIdTransactionsRequestSplitsInner> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdTransactionsRequestSplitsInner,
    _$PostLedgersByLedgerIdTransactionsRequestSplitsInner
  ];

  @override
  final String wireName =
      r'PostLedgersByLedgerIdTransactionsRequestSplitsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdTransactionsRequestSplitsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.memberId != null) {
      yield r'member_id';
      yield serializers.serialize(
        object.memberId,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdTransactionsRequestSplitsInner object, {
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
    required PostLedgersByLedgerIdTransactionsRequestSplitsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'member_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.memberId = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdTransactionsRequestSplitsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdTransactionsRequestSplitsInnerBuilder();
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
