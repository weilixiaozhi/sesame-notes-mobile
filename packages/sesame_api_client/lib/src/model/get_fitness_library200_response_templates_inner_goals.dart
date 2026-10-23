//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_library200_response_templates_inner_goals.g.dart';

/// GetFitnessLibrary200ResponseTemplatesInnerGoals
///
/// Properties:
/// * [zh]
/// * [zhHant]
/// * [en]
@BuiltValue()
abstract class GetFitnessLibrary200ResponseTemplatesInnerGoals
    implements
        Built<GetFitnessLibrary200ResponseTemplatesInnerGoals,
            GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder> {
  @BuiltValueField(wireName: r'zh')
  BuiltList<String> get zh;

  @BuiltValueField(wireName: r'zh_hant')
  BuiltList<String> get zhHant;

  @BuiltValueField(wireName: r'en')
  BuiltList<String> get en;

  GetFitnessLibrary200ResponseTemplatesInnerGoals._();

  factory GetFitnessLibrary200ResponseTemplatesInnerGoals(
          [void updates(
              GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder b)]) =
      _$GetFitnessLibrary200ResponseTemplatesInnerGoals;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetFitnessLibrary200ResponseTemplatesInnerGoals>
      get serializer =>
          _$GetFitnessLibrary200ResponseTemplatesInnerGoalsSerializer();
}

class _$GetFitnessLibrary200ResponseTemplatesInnerGoalsSerializer
    implements
        PrimitiveSerializer<GetFitnessLibrary200ResponseTemplatesInnerGoals> {
  @override
  final Iterable<Type> types = const [
    GetFitnessLibrary200ResponseTemplatesInnerGoals,
    _$GetFitnessLibrary200ResponseTemplatesInnerGoals
  ];

  @override
  final String wireName = r'GetFitnessLibrary200ResponseTemplatesInnerGoals';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessLibrary200ResponseTemplatesInnerGoals object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'zh';
    yield serializers.serialize(
      object.zh,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'zh_hant';
    yield serializers.serialize(
      object.zhHant,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'en';
    yield serializers.serialize(
      object.en,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessLibrary200ResponseTemplatesInnerGoals object, {
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
    required GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'zh':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.zh.replace(valueDes);
          break;
        case r'zh_hant':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.zhHant.replace(valueDes);
          break;
        case r'en':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.en.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessLibrary200ResponseTemplatesInnerGoals deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetFitnessLibrary200ResponseTemplatesInnerGoalsBuilder();
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
