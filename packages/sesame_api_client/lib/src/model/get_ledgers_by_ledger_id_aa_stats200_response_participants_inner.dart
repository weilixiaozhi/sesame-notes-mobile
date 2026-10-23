//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_ledgers_by_ledger_id_aa_stats200_response_participants_inner.g.dart';

/// GetLedgersByLedgerIdAaStats200ResponseParticipantsInner
///
/// Properties:
/// * [memberId]
/// * [displayName]
/// * [isSelf]
/// * [totalPaid]
/// * [totalShouldPay]
/// * [net]
/// * [nonSplitPaid]
@BuiltValue()
abstract class GetLedgersByLedgerIdAaStats200ResponseParticipantsInner
    implements
        Built<GetLedgersByLedgerIdAaStats200ResponseParticipantsInner,
            GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerBuilder> {
  @BuiltValueField(wireName: r'member_id')
  String get memberId;

  @BuiltValueField(wireName: r'display_name')
  String get displayName;

  @BuiltValueField(wireName: r'is_self')
  bool get isSelf;

  @BuiltValueField(wireName: r'total_paid')
  String get totalPaid;

  @BuiltValueField(wireName: r'total_should_pay')
  String get totalShouldPay;

  @BuiltValueField(wireName: r'net')
  String get net;

  @BuiltValueField(wireName: r'non_split_paid')
  String get nonSplitPaid;

  GetLedgersByLedgerIdAaStats200ResponseParticipantsInner._();

  factory GetLedgersByLedgerIdAaStats200ResponseParticipantsInner(
      [void updates(
          GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerBuilder
              b)]) = _$GetLedgersByLedgerIdAaStats200ResponseParticipantsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetLedgersByLedgerIdAaStats200ResponseParticipantsInner>
      get serializer =>
          _$GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerSerializer();
}

class _$GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerSerializer
    implements
        PrimitiveSerializer<
            GetLedgersByLedgerIdAaStats200ResponseParticipantsInner> {
  @override
  final Iterable<Type> types = const [
    GetLedgersByLedgerIdAaStats200ResponseParticipantsInner,
    _$GetLedgersByLedgerIdAaStats200ResponseParticipantsInner
  ];

  @override
  final String wireName =
      r'GetLedgersByLedgerIdAaStats200ResponseParticipantsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetLedgersByLedgerIdAaStats200ResponseParticipantsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'member_id';
    yield serializers.serialize(
      object.memberId,
      specifiedType: const FullType(String),
    );
    yield r'display_name';
    yield serializers.serialize(
      object.displayName,
      specifiedType: const FullType(String),
    );
    yield r'is_self';
    yield serializers.serialize(
      object.isSelf,
      specifiedType: const FullType(bool),
    );
    yield r'total_paid';
    yield serializers.serialize(
      object.totalPaid,
      specifiedType: const FullType(String),
    );
    yield r'total_should_pay';
    yield serializers.serialize(
      object.totalShouldPay,
      specifiedType: const FullType(String),
    );
    yield r'net';
    yield serializers.serialize(
      object.net,
      specifiedType: const FullType(String),
    );
    yield r'non_split_paid';
    yield serializers.serialize(
      object.nonSplitPaid,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetLedgersByLedgerIdAaStats200ResponseParticipantsInner object, {
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
    required GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'member_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.memberId = valueDes;
          break;
        case r'display_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'is_self':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isSelf = valueDes;
          break;
        case r'total_paid':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.totalPaid = valueDes;
          break;
        case r'total_should_pay':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.totalShouldPay = valueDes;
          break;
        case r'net':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.net = valueDes;
          break;
        case r'non_split_paid':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nonSplitPaid = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetLedgersByLedgerIdAaStats200ResponseParticipantsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetLedgersByLedgerIdAaStats200ResponseParticipantsInnerBuilder();
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
