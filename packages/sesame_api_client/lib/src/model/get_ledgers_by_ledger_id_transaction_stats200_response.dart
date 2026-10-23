//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_ledgers_by_ledger_id_transaction_stats200_response_by_currency_inner.dart';
import 'package:sesame_api_client/src/model/get_ledgers_by_ledger_id_transaction_stats200_response_by_category_inner.dart';
import 'package:sesame_api_client/src/model/get_ledgers_by_ledger_id_transaction_stats200_response_by_day_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_ledgers_by_ledger_id_transaction_stats200_response.g.dart';

/// GetLedgersByLedgerIdTransactionStats200Response
///
/// Properties:
/// * [ledgerCurrency]
/// * [expenseTotal]
/// * [transactionCount]
/// * [byCurrency]
/// * [byDay]
/// * [byCategory]
@BuiltValue()
abstract class GetLedgersByLedgerIdTransactionStats200Response
    implements
        Built<GetLedgersByLedgerIdTransactionStats200Response,
            GetLedgersByLedgerIdTransactionStats200ResponseBuilder> {
  @BuiltValueField(wireName: r'ledger_currency')
  String get ledgerCurrency;

  @BuiltValueField(wireName: r'expense_total')
  String get expenseTotal;

  @BuiltValueField(wireName: r'transaction_count')
  int get transactionCount;

  @BuiltValueField(wireName: r'by_currency')
  BuiltList<GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner>
      get byCurrency;

  @BuiltValueField(wireName: r'by_day')
  BuiltList<GetLedgersByLedgerIdTransactionStats200ResponseByDayInner>
      get byDay;

  @BuiltValueField(wireName: r'by_category')
  BuiltList<GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner>
      get byCategory;

  GetLedgersByLedgerIdTransactionStats200Response._();

  factory GetLedgersByLedgerIdTransactionStats200Response(
          [void updates(
              GetLedgersByLedgerIdTransactionStats200ResponseBuilder b)]) =
      _$GetLedgersByLedgerIdTransactionStats200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetLedgersByLedgerIdTransactionStats200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetLedgersByLedgerIdTransactionStats200Response>
      get serializer =>
          _$GetLedgersByLedgerIdTransactionStats200ResponseSerializer();
}

class _$GetLedgersByLedgerIdTransactionStats200ResponseSerializer
    implements
        PrimitiveSerializer<GetLedgersByLedgerIdTransactionStats200Response> {
  @override
  final Iterable<Type> types = const [
    GetLedgersByLedgerIdTransactionStats200Response,
    _$GetLedgersByLedgerIdTransactionStats200Response
  ];

  @override
  final String wireName = r'GetLedgersByLedgerIdTransactionStats200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetLedgersByLedgerIdTransactionStats200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ledger_currency';
    yield serializers.serialize(
      object.ledgerCurrency,
      specifiedType: const FullType(String),
    );
    yield r'expense_total';
    yield serializers.serialize(
      object.expenseTotal,
      specifiedType: const FullType(String),
    );
    yield r'transaction_count';
    yield serializers.serialize(
      object.transactionCount,
      specifiedType: const FullType(int),
    );
    yield r'by_currency';
    yield serializers.serialize(
      object.byCurrency,
      specifiedType: const FullType(BuiltList, [
        FullType(GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner)
      ]),
    );
    yield r'by_day';
    yield serializers.serialize(
      object.byDay,
      specifiedType: const FullType(BuiltList, [
        FullType(GetLedgersByLedgerIdTransactionStats200ResponseByDayInner)
      ]),
    );
    yield r'by_category';
    yield serializers.serialize(
      object.byCategory,
      specifiedType: const FullType(BuiltList, [
        FullType(GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner)
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetLedgersByLedgerIdTransactionStats200Response object, {
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
    required GetLedgersByLedgerIdTransactionStats200ResponseBuilder result,
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
        case r'expense_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.expenseTotal = valueDes;
          break;
        case r'transaction_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.transactionCount = valueDes;
          break;
        case r'by_currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner)
            ]),
          ) as BuiltList<
              GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner>;
          result.byCurrency.replace(valueDes);
          break;
        case r'by_day':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetLedgersByLedgerIdTransactionStats200ResponseByDayInner)
            ]),
          ) as BuiltList<
              GetLedgersByLedgerIdTransactionStats200ResponseByDayInner>;
          result.byDay.replace(valueDes);
          break;
        case r'by_category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner)
            ]),
          ) as BuiltList<
              GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner>;
          result.byCategory.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetLedgersByLedgerIdTransactionStats200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetLedgersByLedgerIdTransactionStats200ResponseBuilder();
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
