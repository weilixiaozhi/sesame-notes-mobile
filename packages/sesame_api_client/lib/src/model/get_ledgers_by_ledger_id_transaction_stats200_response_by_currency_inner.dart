//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_ledgers_by_ledger_id_transaction_stats200_response_by_currency_inner.g.dart';

/// GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner
///
/// Properties:
/// * [currencyCode]
/// * [amountTotal]
/// * [nativeTotal]
/// * [transactionCount]
@BuiltValue()
abstract class GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner
    implements
        Built<GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner,
            GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerBuilder> {
  @BuiltValueField(wireName: r'currency_code')
  String get currencyCode;

  @BuiltValueField(wireName: r'amount_total')
  String get amountTotal;

  @BuiltValueField(wireName: r'native_total')
  String get nativeTotal;

  @BuiltValueField(wireName: r'transaction_count')
  int get transactionCount;

  GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner._();

  factory GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner(
          [void updates(
              GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerBuilder
                  b)]) =
      _$GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner>
      get serializer =>
          _$GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerSerializer();
}

class _$GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerSerializer
    implements
        PrimitiveSerializer<
            GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner> {
  @override
  final Iterable<Type> types = const [
    GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner,
    _$GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner
  ];

  @override
  final String wireName =
      r'GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'currency_code';
    yield serializers.serialize(
      object.currencyCode,
      specifiedType: const FullType(String),
    );
    yield r'amount_total';
    yield serializers.serialize(
      object.amountTotal,
      specifiedType: const FullType(String),
    );
    yield r'native_total';
    yield serializers.serialize(
      object.nativeTotal,
      specifiedType: const FullType(String),
    );
    yield r'transaction_count';
    yield serializers.serialize(
      object.transactionCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner object, {
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
    required GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'currency_code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currencyCode = valueDes;
          break;
        case r'amount_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.amountTotal = valueDes;
          break;
        case r'native_total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nativeTotal = valueDes;
          break;
        case r'transaction_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.transactionCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetLedgersByLedgerIdTransactionStats200ResponseByCurrencyInnerBuilder();
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
