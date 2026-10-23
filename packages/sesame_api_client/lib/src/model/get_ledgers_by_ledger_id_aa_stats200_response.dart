//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_ledgers_by_ledger_id_aa_stats200_response_transfers_inner.dart';
import 'package:sesame_api_client/src/model/get_ledgers_by_ledger_id_aa_stats200_response_participants_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_ledgers_by_ledger_id_aa_stats200_response.g.dart';

/// GetLedgersByLedgerIdAaStats200Response
///
/// Properties:
/// * [ledgerCurrency]
/// * [aaEnabled]
/// * [transactionCount]
/// * [excludedCount]
/// * [skippedCount]
/// * [participants]
/// * [transfers]
@BuiltValue()
abstract class GetLedgersByLedgerIdAaStats200Response
    implements
        Built<GetLedgersByLedgerIdAaStats200Response,
            GetLedgersByLedgerIdAaStats200ResponseBuilder> {
  @BuiltValueField(wireName: r'ledger_currency')
  String get ledgerCurrency;

  @BuiltValueField(wireName: r'aa_enabled')
  bool get aaEnabled;

  @BuiltValueField(wireName: r'transaction_count')
  int get transactionCount;

  @BuiltValueField(wireName: r'excluded_count')
  int get excludedCount;

  @BuiltValueField(wireName: r'skipped_count')
  int get skippedCount;

  @BuiltValueField(wireName: r'participants')
  BuiltList<GetLedgersByLedgerIdAaStats200ResponseParticipantsInner>
      get participants;

  @BuiltValueField(wireName: r'transfers')
  BuiltList<GetLedgersByLedgerIdAaStats200ResponseTransfersInner> get transfers;

  GetLedgersByLedgerIdAaStats200Response._();

  factory GetLedgersByLedgerIdAaStats200Response(
          [void updates(GetLedgersByLedgerIdAaStats200ResponseBuilder b)]) =
      _$GetLedgersByLedgerIdAaStats200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetLedgersByLedgerIdAaStats200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetLedgersByLedgerIdAaStats200Response> get serializer =>
      _$GetLedgersByLedgerIdAaStats200ResponseSerializer();
}

class _$GetLedgersByLedgerIdAaStats200ResponseSerializer
    implements PrimitiveSerializer<GetLedgersByLedgerIdAaStats200Response> {
  @override
  final Iterable<Type> types = const [
    GetLedgersByLedgerIdAaStats200Response,
    _$GetLedgersByLedgerIdAaStats200Response
  ];

  @override
  final String wireName = r'GetLedgersByLedgerIdAaStats200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetLedgersByLedgerIdAaStats200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ledger_currency';
    yield serializers.serialize(
      object.ledgerCurrency,
      specifiedType: const FullType(String),
    );
    yield r'aa_enabled';
    yield serializers.serialize(
      object.aaEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'transaction_count';
    yield serializers.serialize(
      object.transactionCount,
      specifiedType: const FullType(int),
    );
    yield r'excluded_count';
    yield serializers.serialize(
      object.excludedCount,
      specifiedType: const FullType(int),
    );
    yield r'skipped_count';
    yield serializers.serialize(
      object.skippedCount,
      specifiedType: const FullType(int),
    );
    yield r'participants';
    yield serializers.serialize(
      object.participants,
      specifiedType: const FullType(BuiltList,
          [FullType(GetLedgersByLedgerIdAaStats200ResponseParticipantsInner)]),
    );
    yield r'transfers';
    yield serializers.serialize(
      object.transfers,
      specifiedType: const FullType(BuiltList,
          [FullType(GetLedgersByLedgerIdAaStats200ResponseTransfersInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetLedgersByLedgerIdAaStats200Response object, {
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
    required GetLedgersByLedgerIdAaStats200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ledger_currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ledgerCurrency = valueDes;
          break;
        case r'aa_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.aaEnabled = valueDes;
          break;
        case r'transaction_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.transactionCount = valueDes;
          break;
        case r'excluded_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.excludedCount = valueDes;
          break;
        case r'skipped_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.skippedCount = valueDes;
          break;
        case r'participants':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(GetLedgersByLedgerIdAaStats200ResponseParticipantsInner)
            ]),
          ) as BuiltList<
              GetLedgersByLedgerIdAaStats200ResponseParticipantsInner>;
          result.participants.replace(valueDes);
          break;
        case r'transfers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(GetLedgersByLedgerIdAaStats200ResponseTransfersInner)
            ]),
          ) as BuiltList<GetLedgersByLedgerIdAaStats200ResponseTransfersInner>;
          result.transfers.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetLedgersByLedgerIdAaStats200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetLedgersByLedgerIdAaStats200ResponseBuilder();
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
