//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'exchange_rate_override.g.dart';

/// ExchangeRateOverride
///
/// Properties:
/// * [id]
/// * [baseCurrency]
/// * [quoteCurrency]
/// * [rate]
/// * [updatedAt]
@BuiltValue()
abstract class ExchangeRateOverride
    implements Built<ExchangeRateOverride, ExchangeRateOverrideBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'base_currency')
  String get baseCurrency;

  @BuiltValueField(wireName: r'quote_currency')
  String get quoteCurrency;

  @BuiltValueField(wireName: r'rate')
  String get rate;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  ExchangeRateOverride._();

  factory ExchangeRateOverride([void updates(ExchangeRateOverrideBuilder b)]) =
      _$ExchangeRateOverride;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ExchangeRateOverrideBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ExchangeRateOverride> get serializer =>
      _$ExchangeRateOverrideSerializer();
}

class _$ExchangeRateOverrideSerializer
    implements PrimitiveSerializer<ExchangeRateOverride> {
  @override
  final Iterable<Type> types = const [
    ExchangeRateOverride,
    _$ExchangeRateOverride
  ];

  @override
  final String wireName = r'ExchangeRateOverride';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ExchangeRateOverride object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'base_currency';
    yield serializers.serialize(
      object.baseCurrency,
      specifiedType: const FullType(String),
    );
    yield r'quote_currency';
    yield serializers.serialize(
      object.quoteCurrency,
      specifiedType: const FullType(String),
    );
    yield r'rate';
    yield serializers.serialize(
      object.rate,
      specifiedType: const FullType(String),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ExchangeRateOverride object, {
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
    required ExchangeRateOverrideBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'base_currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.baseCurrency = valueDes;
          break;
        case r'quote_currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.quoteCurrency = valueDes;
          break;
        case r'rate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.rate = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ExchangeRateOverride deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ExchangeRateOverrideBuilder();
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
