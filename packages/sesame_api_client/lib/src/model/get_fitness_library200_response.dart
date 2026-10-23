//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_library200_response_plans_inner.dart';
import 'package:sesame_api_client/src/model/get_fitness_library200_response_templates_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_library200_response.g.dart';

/// GetFitnessLibrary200Response
///
/// Properties:
/// * [schemaVersion]
/// * [contentVersion]
/// * [templates]
/// * [plans]
@BuiltValue()
abstract class GetFitnessLibrary200Response
    implements
        Built<GetFitnessLibrary200Response,
            GetFitnessLibrary200ResponseBuilder> {
  @BuiltValueField(wireName: r'schema_version')
  int get schemaVersion;

  @BuiltValueField(wireName: r'content_version')
  int get contentVersion;

  @BuiltValueField(wireName: r'templates')
  BuiltList<GetFitnessLibrary200ResponseTemplatesInner> get templates;

  @BuiltValueField(wireName: r'plans')
  BuiltList<GetFitnessLibrary200ResponsePlansInner> get plans;

  GetFitnessLibrary200Response._();

  factory GetFitnessLibrary200Response(
          [void updates(GetFitnessLibrary200ResponseBuilder b)]) =
      _$GetFitnessLibrary200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetFitnessLibrary200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetFitnessLibrary200Response> get serializer =>
      _$GetFitnessLibrary200ResponseSerializer();
}

class _$GetFitnessLibrary200ResponseSerializer
    implements PrimitiveSerializer<GetFitnessLibrary200Response> {
  @override
  final Iterable<Type> types = const [
    GetFitnessLibrary200Response,
    _$GetFitnessLibrary200Response
  ];

  @override
  final String wireName = r'GetFitnessLibrary200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessLibrary200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'schema_version';
    yield serializers.serialize(
      object.schemaVersion,
      specifiedType: const FullType(int),
    );
    yield r'content_version';
    yield serializers.serialize(
      object.contentVersion,
      specifiedType: const FullType(int),
    );
    yield r'templates';
    yield serializers.serialize(
      object.templates,
      specifiedType: const FullType(
          BuiltList, [FullType(GetFitnessLibrary200ResponseTemplatesInner)]),
    );
    yield r'plans';
    yield serializers.serialize(
      object.plans,
      specifiedType: const FullType(
          BuiltList, [FullType(GetFitnessLibrary200ResponsePlansInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessLibrary200Response object, {
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
    required GetFitnessLibrary200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'schema_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.schemaVersion = valueDes;
          break;
        case r'content_version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.contentVersion = valueDes;
          break;
        case r'templates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(GetFitnessLibrary200ResponseTemplatesInner)]),
          ) as BuiltList<GetFitnessLibrary200ResponseTemplatesInner>;
          result.templates.replace(valueDes);
          break;
        case r'plans':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(GetFitnessLibrary200ResponsePlansInner)]),
          ) as BuiltList<GetFitnessLibrary200ResponsePlansInner>;
          result.plans.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessLibrary200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetFitnessLibrary200ResponseBuilder();
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
