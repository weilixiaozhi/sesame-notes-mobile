//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/list_official_fitness_taxonomies200_response_items_inner_name.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_official_fitness_taxonomy_request.g.dart';

/// UpdateOfficialFitnessTaxonomyRequest
///
/// Properties:
/// * [version]
/// * [name]
/// * [sortOrder]
/// * [reason]
@BuiltValue()
abstract class UpdateOfficialFitnessTaxonomyRequest
    implements
        Built<UpdateOfficialFitnessTaxonomyRequest,
            UpdateOfficialFitnessTaxonomyRequestBuilder> {
  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'name')
  ListOfficialFitnessTaxonomies200ResponseItemsInnerName? get name;

  @BuiltValueField(wireName: r'sort_order')
  int? get sortOrder;

  @BuiltValueField(wireName: r'reason')
  String get reason;

  UpdateOfficialFitnessTaxonomyRequest._();

  factory UpdateOfficialFitnessTaxonomyRequest(
          [void updates(UpdateOfficialFitnessTaxonomyRequestBuilder b)]) =
      _$UpdateOfficialFitnessTaxonomyRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateOfficialFitnessTaxonomyRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateOfficialFitnessTaxonomyRequest> get serializer =>
      _$UpdateOfficialFitnessTaxonomyRequestSerializer();
}

class _$UpdateOfficialFitnessTaxonomyRequestSerializer
    implements PrimitiveSerializer<UpdateOfficialFitnessTaxonomyRequest> {
  @override
  final Iterable<Type> types = const [
    UpdateOfficialFitnessTaxonomyRequest,
    _$UpdateOfficialFitnessTaxonomyRequest
  ];

  @override
  final String wireName = r'UpdateOfficialFitnessTaxonomyRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateOfficialFitnessTaxonomyRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(
            ListOfficialFitnessTaxonomies200ResponseItemsInnerName),
      );
    }
    if (object.sortOrder != null) {
      yield r'sort_order';
      yield serializers.serialize(
        object.sortOrder,
        specifiedType: const FullType(int),
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
    UpdateOfficialFitnessTaxonomyRequest object, {
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
    required UpdateOfficialFitnessTaxonomyRequestBuilder result,
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
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                ListOfficialFitnessTaxonomies200ResponseItemsInnerName),
          ) as ListOfficialFitnessTaxonomies200ResponseItemsInnerName?;
          if (valueDes == null) continue;
          result.name.replace(valueDes);
          break;
        case r'sort_order':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.sortOrder = valueDes;
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
  UpdateOfficialFitnessTaxonomyRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateOfficialFitnessTaxonomyRequestBuilder();
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
