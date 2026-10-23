//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of12_any_of_payload.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_fitness_spaces_by_fitness_space_id_export200_response_records_inner_any_of1.g.dart';

/// GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1
///
/// Properties:
/// * [id]
/// * [entityType]
/// * [payload]
@BuiltValue()
abstract class GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1
    implements
        Built<
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1,
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Builder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'entity_type')
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum
      get entityType;
  // enum entityTypeEnum {  fitness_plan,  };

  @BuiltValueField(wireName: r'payload')
  PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload get payload;

  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1._();

  factory GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1(
          [void updates(
              GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Builder
                  b)]) =
      _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Builder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1>
      get serializer =>
          _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Serializer();
}

class _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Serializer
    implements
        PrimitiveSerializer<
            GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1> {
  @override
  final Iterable<Type> types = const [
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1,
    _$GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1
  ];

  @override
  final String wireName =
      r'GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1
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
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum),
    );
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType:
          const FullType(PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1
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
    required GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Builder
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
                GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum),
          ) as GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum;
          result.entityType = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload),
          ) as PostSyncPushRequestChangesInnerAnyOf12AnyOfPayload;
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
  GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1Builder();
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

class GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness_plan')
  static const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum
      fitnessPlan =
      _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum_fitnessPlan;

  static Serializer<
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum>
      get serializer =>
          _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnumSerializer;

  const GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum._(
      String name)
      : super(name);

  static BuiltSet<
          GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum>
      get values =>
          _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnumValues;
  static GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnum
      valueOf(String name) =>
          _$getFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInnerAnyOf1EntityTypeEnumValueOf(
              name);
}
