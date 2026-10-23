//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/recurring_transaction.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_ledgers_by_ledger_id_recurring_transactions200_response.g.dart';

/// GetLedgersByLedgerIdRecurringTransactions200Response
///
/// Properties:
/// * [items]
/// * [nextCursor]
@BuiltValue()
abstract class GetLedgersByLedgerIdRecurringTransactions200Response
    implements
        Built<GetLedgersByLedgerIdRecurringTransactions200Response,
            GetLedgersByLedgerIdRecurringTransactions200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<RecurringTransaction> get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  GetLedgersByLedgerIdRecurringTransactions200Response._();

  factory GetLedgersByLedgerIdRecurringTransactions200Response(
          [void updates(
              GetLedgersByLedgerIdRecurringTransactions200ResponseBuilder b)]) =
      _$GetLedgersByLedgerIdRecurringTransactions200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetLedgersByLedgerIdRecurringTransactions200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetLedgersByLedgerIdRecurringTransactions200Response>
      get serializer =>
          _$GetLedgersByLedgerIdRecurringTransactions200ResponseSerializer();
}

class _$GetLedgersByLedgerIdRecurringTransactions200ResponseSerializer
    implements
        PrimitiveSerializer<
            GetLedgersByLedgerIdRecurringTransactions200Response> {
  @override
  final Iterable<Type> types = const [
    GetLedgersByLedgerIdRecurringTransactions200Response,
    _$GetLedgersByLedgerIdRecurringTransactions200Response
  ];

  @override
  final String wireName =
      r'GetLedgersByLedgerIdRecurringTransactions200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetLedgersByLedgerIdRecurringTransactions200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType:
          const FullType(BuiltList, [FullType(RecurringTransaction)]),
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
    GetLedgersByLedgerIdRecurringTransactions200Response object, {
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
    required GetLedgersByLedgerIdRecurringTransactions200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(RecurringTransaction)]),
          ) as BuiltList<RecurringTransaction>;
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
  GetLedgersByLedgerIdRecurringTransactions200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetLedgersByLedgerIdRecurringTransactions200ResponseBuilder();
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
