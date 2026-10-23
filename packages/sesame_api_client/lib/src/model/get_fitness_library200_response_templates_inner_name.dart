//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_library200_response_templates_inner_name.g.dart';

/// GetFitnessLibrary200ResponseTemplatesInnerName
///
/// Properties:
/// * [zh]
/// * [zhHant]
/// * [en]
@BuiltValue()
abstract class GetFitnessLibrary200ResponseTemplatesInnerName
    implements
        Built<GetFitnessLibrary200ResponseTemplatesInnerName,
            GetFitnessLibrary200ResponseTemplatesInnerNameBuilder> {
  @BuiltValueField(wireName: r'zh')
  String get zh;

  @BuiltValueField(wireName: r'zh_hant')
  String get zhHant;

  @BuiltValueField(wireName: r'en')
  String get en;

  GetFitnessLibrary200ResponseTemplatesInnerName._();

  factory GetFitnessLibrary200ResponseTemplatesInnerName(
          [void updates(
              GetFitnessLibrary200ResponseTemplatesInnerNameBuilder b)]) =
      _$GetFitnessLibrary200ResponseTemplatesInnerName;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessLibrary200ResponseTemplatesInnerNameBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetFitnessLibrary200ResponseTemplatesInnerName>
      get serializer =>
          _$GetFitnessLibrary200ResponseTemplatesInnerNameSerializer();
}

class _$GetFitnessLibrary200ResponseTemplatesInnerNameSerializer
    implements
        PrimitiveSerializer<GetFitnessLibrary200ResponseTemplatesInnerName> {
  @override
  final Iterable<Type> types = const [
    GetFitnessLibrary200ResponseTemplatesInnerName,
    _$GetFitnessLibrary200ResponseTemplatesInnerName
  ];

  @override
  final String wireName = r'GetFitnessLibrary200ResponseTemplatesInnerName';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessLibrary200ResponseTemplatesInnerName object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'zh';
    yield serializers.serialize(
      object.zh,
      specifiedType: const FullType(String),
    );
    yield r'zh_hant';
    yield serializers.serialize(
      object.zhHant,
      specifiedType: const FullType(String),
    );
    yield r'en';
    yield serializers.serialize(
      object.en,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessLibrary200ResponseTemplatesInnerName object, {
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
    required GetFitnessLibrary200ResponseTemplatesInnerNameBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'zh':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.zh = valueDes;
          break;
        case r'zh_hant':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.zhHant = valueDes;
          break;
        case r'en':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.en = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessLibrary200ResponseTemplatesInnerName deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetFitnessLibrary200ResponseTemplatesInnerNameBuilder();
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
