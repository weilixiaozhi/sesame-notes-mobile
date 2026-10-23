//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_ledgers_by_ledger_id_aa_stats200_response_transfers_inner.g.dart';

/// GetLedgersByLedgerIdAaStats200ResponseTransfersInner
///
/// Properties:
/// * [fromMemberId]
/// * [toMemberId]
/// * [amount]
/// * [exactAmount]
@BuiltValue()
abstract class GetLedgersByLedgerIdAaStats200ResponseTransfersInner
    implements
        Built<GetLedgersByLedgerIdAaStats200ResponseTransfersInner,
            GetLedgersByLedgerIdAaStats200ResponseTransfersInnerBuilder> {
  @BuiltValueField(wireName: r'from_member_id')
  String get fromMemberId;

  @BuiltValueField(wireName: r'to_member_id')
  String get toMemberId;

  @BuiltValueField(wireName: r'amount')
  String get amount;

  @BuiltValueField(wireName: r'exact_amount')
  String get exactAmount;

  GetLedgersByLedgerIdAaStats200ResponseTransfersInner._();

  factory GetLedgersByLedgerIdAaStats200ResponseTransfersInner(
          [void updates(
              GetLedgersByLedgerIdAaStats200ResponseTransfersInnerBuilder b)]) =
      _$GetLedgersByLedgerIdAaStats200ResponseTransfersInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetLedgersByLedgerIdAaStats200ResponseTransfersInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetLedgersByLedgerIdAaStats200ResponseTransfersInner>
      get serializer =>
          _$GetLedgersByLedgerIdAaStats200ResponseTransfersInnerSerializer();
}

class _$GetLedgersByLedgerIdAaStats200ResponseTransfersInnerSerializer
    implements
        PrimitiveSerializer<
            GetLedgersByLedgerIdAaStats200ResponseTransfersInner> {
  @override
  final Iterable<Type> types = const [
    GetLedgersByLedgerIdAaStats200ResponseTransfersInner,
    _$GetLedgersByLedgerIdAaStats200ResponseTransfersInner
  ];

  @override
  final String wireName =
      r'GetLedgersByLedgerIdAaStats200ResponseTransfersInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetLedgersByLedgerIdAaStats200ResponseTransfersInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'from_member_id';
    yield serializers.serialize(
      object.fromMemberId,
      specifiedType: const FullType(String),
    );
    yield r'to_member_id';
    yield serializers.serialize(
      object.toMemberId,
      specifiedType: const FullType(String),
    );
    yield r'amount';
    yield serializers.serialize(
      object.amount,
      specifiedType: const FullType(String),
    );
    yield r'exact_amount';
    yield serializers.serialize(
      object.exactAmount,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetLedgersByLedgerIdAaStats200ResponseTransfersInner object, {
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
    required GetLedgersByLedgerIdAaStats200ResponseTransfersInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'from_member_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fromMemberId = valueDes;
          break;
        case r'to_member_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.toMemberId = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amount = valueDes;
          break;
        case r'exact_amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.exactAmount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetLedgersByLedgerIdAaStats200ResponseTransfersInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetLedgersByLedgerIdAaStats200ResponseTransfersInnerBuilder();
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
