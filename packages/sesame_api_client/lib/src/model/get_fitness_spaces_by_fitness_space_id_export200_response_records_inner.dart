//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of14_any_of_payload.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_export200_response_records_inner_any_of3.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_export200_response_records_inner_any_of.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_export200_response_records_inner_any_of1.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_export200_response_records_inner_any_of2.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'get_fitness_spaces_by_fitness_space_id_export200_response_records_inner.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner
///
/// Properties:
/// * [id]
/// * [entityType]
/// * [payload]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner
    implements
        Built<GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner,
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerBuilder> {
  /// Any Of [GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf], [GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1], [GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2], [GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3]
  AnyOf get anyOf;

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner._();

  factory GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner,
    _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf),
      FullType(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1),
      FullType(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf2),
      FullType(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness_preferences')
  static const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum
      fitnessPreferences =
      _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum_fitnessPreferences;

  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum>
      get serializer =>
          _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnumSerializer;

  const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum>
      get values =>
          _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnumValues;
  static GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnum
      valueOf(String name) =>
          _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerEntityTypeEnumValueOf(
              name);
}
