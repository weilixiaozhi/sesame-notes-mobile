//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delete_official_fitness_taxonomy_request.g.dart';

/// DeleteOfficialFitnessTaxonomyRequest
///
/// Properties:
/// * [version]
/// * [replacementId]
/// * [reason]
@BuiltValue()
abstract class DeleteOfficialFitnessTaxonomyRequest
    implements
        Built<DeleteOfficialFitnessTaxonomyRequest,
            DeleteOfficialFitnessTaxonomyRequestBuilder> {
  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'replacement_id')
  String? get replacementId;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  DeleteOfficialFitnessTaxonomyRequest._();

  factory DeleteOfficialFitnessTaxonomyRequest(
          [void updates(DeleteOfficialFitnessTaxonomyRequestBuilder b)]) =
      _$DeleteOfficialFitnessTaxonomyRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeleteOfficialFitnessTaxonomyRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeleteOfficialFitnessTaxonomyRequest> get serializer =>
      _$DeleteOfficialFitnessTaxonomyRequestSerializer();
}

class _$DeleteOfficialFitnessTaxonomyRequestSerializer
    implements PrimitiveSerializer<DeleteOfficialFitnessTaxonomyRequest> {
  @override
  final Iterable<Type> types = const [
    DeleteOfficialFitnessTaxonomyRequest,
    _$DeleteOfficialFitnessTaxonomyRequest
  ];

  @override
  final String wireName = r'DeleteOfficialFitnessTaxonomyRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeleteOfficialFitnessTaxonomyRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    if (object.replacementId != null) {
      yield r'replacement_id';
      yield serializers.serialize(
        object.replacementId,
        specifiedType: const FullType(String),
      );
    }
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    DeleteOfficialFitnessTaxonomyRequest object, {
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
    required DeleteOfficialFitnessTaxonomyRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'replacement_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.replacementId = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeleteOfficialFitnessTaxonomyRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeleteOfficialFitnessTaxonomyRequestBuilder();
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
