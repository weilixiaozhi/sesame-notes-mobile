//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/date.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_exchange_rates200_response.g.dart';

/// GetExchangeRates200Response
///
/// Properties:
/// * [baseCurrency]
/// * [rateDate]
/// * [source_]
/// * [fetchedAt]
/// * [rates]
@BuiltValue()
abstract class GetExchangeRates200Response
    implements
        Built<GetExchangeRates200Response, GetExchangeRates200ResponseBuilder> {
  @BuiltValueField(wireName: r'base_currency')
  String get baseCurrency;

  @BuiltValueField(wireName: r'rate_date')
  Date? get rateDate;

  @BuiltValueField(wireName: r'source')
  String get source_;

  @BuiltValueField(wireName: r'fetched_at')
  DateTime get fetchedAt;

  @BuiltValueField(wireName: r'rates')
  BuiltMap<String, String> get rates;

  GetExchangeRates200Response._();

  factory GetExchangeRates200Response(
          [void updates(GetExchangeRates200ResponseBuilder b)]) =
      _$GetExchangeRates200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetExchangeRates200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetExchangeRates200Response> get serializer =>
      _$GetExchangeRates200ResponseSerializer();
}

class _$GetExchangeRates200ResponseSerializer
    implements PrimitiveSerializer<GetExchangeRates200Response> {
  @override
  final Iterable<Type> types = const [
    GetExchangeRates200Response,
    _$GetExchangeRates200Response
  ];

  @override
  final String wireName = r'GetExchangeRates200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetExchangeRates200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'base_currency';
    yield serializers.serialize(
      object.baseCurrency,
      specifiedType: const FullType(String),
    );
    yield r'rate_date';
    yield object.rateDate == null
        ? null
        : serializers.serialize(
            object.rateDate,
            specifiedType: const FullType.nullable(Date),
          );
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(String),
    );
    yield r'fetched_at';
    yield serializers.serialize(
      object.fetchedAt,
      specifiedType: const FullType(DateTime),
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
    GetExchangeRates200Response object, {
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
    required GetExchangeRates200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'base_currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.baseCurrency = valueDes;
          break;
        case r'rate_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(Date),
          ) as Date?;
          if (valueDes == null) continue;
          result.rateDate = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.source_ = valueDes;
          break;
        case r'fetched_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.fetchedAt = valueDes;
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
  GetExchangeRates200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetExchangeRates200ResponseBuilder();
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
