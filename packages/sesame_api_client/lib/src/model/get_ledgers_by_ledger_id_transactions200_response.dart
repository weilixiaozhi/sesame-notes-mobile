//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/transaction.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_ledgers_by_ledger_id_transactions200_response.g.dart';

/// GetLedgersByLedgerIdTransactions200Response
///
/// Properties:
/// * [items]
/// * [nextCursor]
@BuiltValue()
abstract class GetLedgersByLedgerIdTransactions200Response
    implements
        Built<GetLedgersByLedgerIdTransactions200Response,
            GetLedgersByLedgerIdTransactions200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<Transaction> get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  GetLedgersByLedgerIdTransactions200Response._();

  factory GetLedgersByLedgerIdTransactions200Response(
          [void updates(
              GetLedgersByLedgerIdTransactions200ResponseBuilder b)]) =
      _$GetLedgersByLedgerIdTransactions200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetLedgersByLedgerIdTransactions200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetLedgersByLedgerIdTransactions200Response>
      get serializer =>
          _$GetLedgersByLedgerIdTransactions200ResponseSerializer();
}

class _$GetLedgersByLedgerIdTransactions200ResponseSerializer
    implements
        PrimitiveSerializer<GetLedgersByLedgerIdTransactions200Response> {
  @override
  final Iterable<Type> types = const [
    GetLedgersByLedgerIdTransactions200Response,
    _$GetLedgersByLedgerIdTransactions200Response
  ];

  @override
  final String wireName = r'GetLedgersByLedgerIdTransactions200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetLedgersByLedgerIdTransactions200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(Transaction)]),
    );
    yield r'next_cursor';
    yield object.nextCursor == null
        ? null
        : serializers.serialize(
            object.nextCursor,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetLedgersByLedgerIdTransactions200Response object, {
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
    required GetLedgersByLedgerIdTransactions200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Transaction)]),
          ) as BuiltList<Transaction>;
          result.items.replace(valueDes);
          break;
        case r'next_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetLedgersByLedgerIdTransactions200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetLedgersByLedgerIdTransactions200ResponseBuilder();
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
