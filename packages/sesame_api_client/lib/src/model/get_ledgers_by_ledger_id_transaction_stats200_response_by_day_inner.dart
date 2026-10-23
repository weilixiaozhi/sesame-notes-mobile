//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_ledgers_by_ledger_id_transaction_stats200_response_by_day_inner.g.dart';

/// GetLedgersByLedgerIdTransactionStats200ResponseByDayInner
///
/// Properties:
/// * [date]
/// * [nativeTotal]
/// * [transactionCount]
@BuiltValue()
abstract class GetLedgersByLedgerIdTransactionStats200ResponseByDayInner
    implements
        Built<GetLedgersByLedgerIdTransactionStats200ResponseByDayInner,
            GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerBuilder> {
  @BuiltValueField(wireName: r'date')
  String get date;

  @BuiltValueField(wireName: r'native_total')
  String get nativeTotal;

  @BuiltValueField(wireName: r'transaction_count')
  int get transactionCount;

  GetLedgersByLedgerIdTransactionStats200ResponseByDayInner._();

  factory GetLedgersByLedgerIdTransactionStats200ResponseByDayInner(
          [void updates(
              GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerBuilder
                  b)]) =
      _$GetLedgersByLedgerIdTransactionStats200ResponseByDayInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetLedgersByLedgerIdTransactionStats200ResponseByDayInner>
      get serializer =>
          _$GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerSerializer();
}

class _$GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerSerializer
    implements
        PrimitiveSerializer<
            GetLedgersByLedgerIdTransactionStats200ResponseByDayInner> {
  @override
  final Iterable<Type> types = const [
    GetLedgersByLedgerIdTransactionStats200ResponseByDayInner,
    _$GetLedgersByLedgerIdTransactionStats200ResponseByDayInner
  ];

  @override
  final String wireName =
      r'GetLedgersByLedgerIdTransactionStats200ResponseByDayInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetLedgersByLedgerIdTransactionStats200ResponseByDayInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'date';
    yield serializers.serialize(
      object.date,
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
    GetLedgersByLedgerIdTransactionStats200ResponseByDayInner object, {
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
    required GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.date = valueDes;
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
  GetLedgersByLedgerIdTransactionStats200ResponseByDayInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetLedgersByLedgerIdTransactionStats200ResponseByDayInnerBuilder();
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
