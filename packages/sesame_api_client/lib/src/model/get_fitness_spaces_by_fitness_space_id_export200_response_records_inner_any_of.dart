//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of11_any_of_payload.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_export200_response_records_inner_any_of.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf
///
/// Properties:
/// * [id]
/// * [entityType]
/// * [payload]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf,
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'entity_type')
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum
      get entityType;
  // enum entityTypeEnum {  fitness_template,  };

  @BuiltValueField(wireName: r'payload')
  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload get payload;

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf._();

  factory GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfBuilder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfSerializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfSerializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf,
    _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'entity_type';
    yield serializers.serialize(
      object.entityType,
      specifiedType: const FullType(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum),
    );
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType:
          const FullType(PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf object, {
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
    required GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfBuilder
        result,
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
        case r'entity_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum),
          ) as GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum;
          result.entityType = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload),
          ) as PostSyncPushRequestChangesInnerAnyOf11AnyOfPayload;
          result.payload.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfBuilder();
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

class GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness_template')
  static const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum
      fitnessTemplate =
      _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum_fitnessTemplate;

  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum>
      get serializer =>
          _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnumSerializer;

  const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum>
      get values =>
          _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnumValues;
  static GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnum
      valueOf(String name) =>
          _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOfEntityTypeEnumValueOf(
              name);
}
