//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_library200_response_plans_inner_days_inner.g.dart';

/// GetFitnessLibrary200ResponsePlansInnerDaysInner
///
/// Properties:
/// * [dayIndex]
/// * [templateId]
@BuiltValue()
abstract class GetFitnessLibrary200ResponsePlansInnerDaysInner
    implements
        Built<GetFitnessLibrary200ResponsePlansInnerDaysInner,
            GetFitnessLibrary200ResponsePlansInnerDaysInnerBuilder> {
  @BuiltValueField(wireName: r'day_index')
  int get dayIndex;

  @BuiltValueField(wireName: r'template_id')
  String? get templateId;

  GetFitnessLibrary200ResponsePlansInnerDaysInner._();

  factory GetFitnessLibrary200ResponsePlansInnerDaysInner(
          [void updates(
              GetFitnessLibrary200ResponsePlansInnerDaysInnerBuilder b)]) =
      _$GetFitnessLibrary200ResponsePlansInnerDaysInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessLibrary200ResponsePlansInnerDaysInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetFitnessLibrary200ResponsePlansInnerDaysInner>
      get serializer =>
          _$GetFitnessLibrary200ResponsePlansInnerDaysInnerSerializer();
}

class _$GetFitnessLibrary200ResponsePlansInnerDaysInnerSerializer
    implements
        PrimitiveSerializer<GetFitnessLibrary200ResponsePlansInnerDaysInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessLibrary200ResponsePlansInnerDaysInner,
    _$GetFitnessLibrary200ResponsePlansInnerDaysInner
  ];

  @override
  final String wireName = r'GetFitnessLibrary200ResponsePlansInnerDaysInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessLibrary200ResponsePlansInnerDaysInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'day_index';
    yield serializers.serialize(
      object.dayIndex,
      specifiedType: const FullType(int),
    );
    yield r'template_id';
    yield object.templateId == null
        ? null
        : serializers.serialize(
            object.templateId,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessLibrary200ResponsePlansInnerDaysInner object, {
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
    required GetFitnessLibrary200ResponsePlansInnerDaysInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'day_index':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.dayIndex = valueDes;
          break;
        case r'template_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.templateId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessLibrary200ResponsePlansInnerDaysInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetFitnessLibrary200ResponsePlansInnerDaysInnerBuilder();
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
