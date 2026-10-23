//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_ledgers_by_ledger_id_transaction_stats200_response_by_category_inner.g.dart';

/// GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner
///
/// Properties:
/// * [categoryId]
/// * [categoryName]
/// * [nativeTotal]
/// * [transactionCount]
@BuiltValue()
abstract class GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner
    implements
        Built<GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner,
            GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerBuilder> {
  @BuiltValueField(wireName: r'category_id')
  String? get categoryId;

  @BuiltValueField(wireName: r'category_name')
  String? get categoryName;

  @BuiltValueField(wireName: r'native_total')
  String get nativeTotal;

  @BuiltValueField(wireName: r'transaction_count')
  int get transactionCount;

  GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner._();

  factory GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner(
          [void updates(
              GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerBuilder
                  b)]) =
      _$GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner>
      get serializer =>
          _$GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerSerializer();
}

class _$GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerSerializer
    implements
        PrimitiveSerializer<
            GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner> {
  @override
  final Iterable<Type> types = const [
    GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner,
    _$GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner
  ];

  @override
  final String wireName =
      r'GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'category_id';
    yield object.categoryId == null
        ? null
        : serializers.serialize(
            object.categoryId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'category_name';
    yield object.categoryName == null
        ? null
        : serializers.serialize(
            object.categoryName,
            specifiedType: const FullType.nullable(String),
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
    GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner object, {
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
    required GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'category_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.categoryId = valueDes;
          break;
        case r'category_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.categoryName = valueDes;
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
  GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetLedgersByLedgerIdTransactionStats200ResponseByCategoryInnerBuilder();
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
