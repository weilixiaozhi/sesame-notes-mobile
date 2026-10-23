//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_fitness_spaces_by_fitness_space_id_export200_response_records_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_fitness_spaces_by_fitness_space_id_import_request.g.dart';

/// PostFitnessSpacesByFitnessSpaceIdImportRequest
///
/// Properties:
/// * [syncId]
/// * [exportId]
/// * [replacePreferences]
/// * [records]
@BuiltValue()
abstract class PostFitnessSpacesByFitnessSpaceIdImportRequest
    implements
        Built<PostFitnessSpacesByFitnessSpaceIdImportRequest,
            PostFitnessSpacesByFitnessSpaceIdImportRequestBuilder> {
  @BuiltValueField(wireName: r'sync_id')
  String get syncId;

  @BuiltValueField(wireName: r'export_id')
  String get exportId;

  @BuiltValueField(wireName: r'replace_preferences')
  bool? get replacePreferences;

  @BuiltValueField(wireName: r'records')
  BuiltList<GetFitnessSpacesByFitnessSpaceIdExport200ResponseRecordsInner>
      get records;

  PostFitnessSpacesByFitnessSpaceIdImportRequest._();

  factory PostFitnessSpacesByFitnessSpaceIdImportRequest(
          [void updates(
              PostFitnessSpacesByFitnessSpaceIdImportRequestBuilder b)]) =
      _$PostFitnessSpacesByFitnessSpaceIdImportRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostFitnessSpacesByFitnessSpaceIdImportRequestBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostFitnessSpacesByFitnessSpaceIdImportRequest>
      get serializer =>
          _$PostFitnessSpacesByFitnessSpaceIdImportRequestSerializer();
}

class _$PostFitnessSpacesByFitnessSpaceIdImportRequestSerializer
    implements
        PrimitiveSerializer<PostFitnessSpacesByFitnessSpaceIdImportRequest> {
  @override
  final Iterable<Type> types = const [
    PostFitnessSpacesByFitnessSpaceIdImportRequest,
    _$PostFitnessSpacesByFitnessSpaceIdImportRequest
  ];

  @override
  final String wireName = r'PostFitnessSpacesByFitnessSpaceIdImportRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostFitnessSpacesByFitnessSpaceIdImportRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'sync_id';
    yield serializers.serialize(
      object.syncId,
      specifiedType: const FullType(String),
    );
    yield r'export_id';
    yield serializers.serialize(
      object.exportId,
      specifiedType: const FullType(String),
    );
    if (object.replacePreferences != null) {
      yield r'replace_preferences';
      yield serializers.serialize(
        object.replacePreferences,
        specifiedType: const FullType(bool),
      );
    }
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
    PostFitnessSpacesByFitnessSpaceIdImportRequest object, {
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
    required PostFitnessSpacesByFitnessSpaceIdImportRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'sync_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.syncId = valueDes;
          break;
        case r'export_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.exportId = valueDes;
          break;
        case r'replace_preferences':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(bool),
          ) as bool?;
          if (valueDes == null) continue;
          result.replacePreferences = valueDes;
          break;
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
  PostFitnessSpacesByFitnessSpaceIdImportRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostFitnessSpacesByFitnessSpaceIdImportRequestBuilder();
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
