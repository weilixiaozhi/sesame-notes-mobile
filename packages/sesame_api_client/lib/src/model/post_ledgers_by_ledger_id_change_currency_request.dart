//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_change_currency_request.g.dart';

/// PostLedgersByLedgerIdChangeCurrencyRequest
///
/// Properties:
/// * [currency]
/// * [expectedCurrency]
/// * [rates]
@BuiltValue()
abstract class PostLedgersByLedgerIdChangeCurrencyRequest
    implements
        Built<PostLedgersByLedgerIdChangeCurrencyRequest,
            PostLedgersByLedgerIdChangeCurrencyRequestBuilder> {
  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'expected_currency')
  String get expectedCurrency;

  @BuiltValueField(wireName: r'rates')
  BuiltMap<String, String> get rates;

  PostLedgersByLedgerIdChangeCurrencyRequest._();

  factory PostLedgersByLedgerIdChangeCurrencyRequest(
          [void updates(PostLedgersByLedgerIdChangeCurrencyRequestBuilder b)]) =
      _$PostLedgersByLedgerIdChangeCurrencyRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostLedgersByLedgerIdChangeCurrencyRequestBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdChangeCurrencyRequest>
      get serializer =>
          _$PostLedgersByLedgerIdChangeCurrencyRequestSerializer();
}

class _$PostLedgersByLedgerIdChangeCurrencyRequestSerializer
    implements PrimitiveSerializer<PostLedgersByLedgerIdChangeCurrencyRequest> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdChangeCurrencyRequest,
    _$PostLedgersByLedgerIdChangeCurrencyRequest
  ];

  @override
  final String wireName = r'PostLedgersByLedgerIdChangeCurrencyRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdChangeCurrencyRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'expected_currency';
    yield serializers.serialize(
      object.expectedCurrency,
      specifiedType: const FullType(String),
    );
    yield r'rates';
    yield serializers.serialize(
      object.rates,
      specifiedType:
          const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdChangeCurrencyRequest object, {
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
    required PostLedgersByLedgerIdChangeCurrencyRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'expected_currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.expectedCurrency = valueDes;
          break;
        case r'rates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.rates.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdChangeCurrencyRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdChangeCurrencyRequestBuilder();
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
