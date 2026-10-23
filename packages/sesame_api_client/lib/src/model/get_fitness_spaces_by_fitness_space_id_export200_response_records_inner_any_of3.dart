//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of14_any_of_payload.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_export200_response_records_inner_any_of3.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3
///
/// Properties:
/// * [id]
/// * [entityType]
/// * [payload]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3,
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Builder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'entity_type')
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum
      get entityType;
  // enum entityTypeEnum {  fitness_preferences,  };

  @BuiltValueField(wireName: r'payload')
  PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload get payload;

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3._();

  factory GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Builder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Builder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Serializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Serializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3,
    _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3
        object, {
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
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum),
    );
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType:
          const FullType(PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3
        object, {
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
    required GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Builder
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
                GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum),
          ) as GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum;
          result.entityType = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload),
          ) as PostSyncPushRequestChangesInnerAnyOf14AnyOfPayload;
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
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3Builder();
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

class GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness_preferences')
  static const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum
      fitnessPreferences =
      _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum_fitnessPreferences;

  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum>
      get serializer =>
          _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnumSerializer;

  const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum>
      get values =>
          _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnumValues;
  static GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnum
      valueOf(String name) =>
          _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf3EntityTypeEnumValueOf(
              name);
}
