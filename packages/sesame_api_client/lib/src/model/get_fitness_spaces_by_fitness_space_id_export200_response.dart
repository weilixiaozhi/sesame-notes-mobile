//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_export200_response_records_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_export200_response.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdExport200Response
///
/// Properties:
/// * [records]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdExport200Response
    implements
        Built<GetFitnessSpacesByFitnessSpaceIdExport200Response,
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseBuilder> {
  @BuiltValueField(wireName: r'records')
  BuiltList<GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner>
      get records;

  GetFitnessSpacesByFitnessSpaceIdExport200Response._();

  factory GetFitnessSpacesByFitnessSpaceIdExport200Response(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdExport200ResponseBuilder b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdExport200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetFitnessSpacesByFitnessSpaceIdExport200Response>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseSerializer
    implements
        PrimitiveSerializer<GetFitnessSpacesByFitnessSpaceIdExport200Response> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdExport200Response,
    _$GetFitnessSpacesByFitnessSpaceIdExport200Response
  ];

  @override
  final String wireName = r'GetFitnessSpacesByFitnessSpaceIdExport200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdExport200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'records';
    yield serializers.serialize(
      object.records,
      specifiedType: const FullType(BuiltList, [
        FullType(GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner)
      ]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdExport200Response object, {
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
    required GetFitnessSpacesByFitnessSpaceIdExport200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'records':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner)
            ]),
          ) as BuiltList<
              GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner>;
          result.records.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetFitnessSpacesByFitnessSpaceIdExport200ResponseBuilder();
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
