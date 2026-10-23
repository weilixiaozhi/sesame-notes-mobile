//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/list_official_fitness_taxonomies200_response_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_official_fitness_taxonomies200_response.g.dart';

/// ListOfficialFitnessTaxonomies200Response
///
/// Properties:
/// * [items]
@BuiltValue()
abstract class ListOfficialFitnessTaxonomies200Response
    implements
        Built<ListOfficialFitnessTaxonomies200Response,
            ListOfficialFitnessTaxonomies200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ListOfficialFitnessTaxonomies200ResponseItemsInner> get items;

  ListOfficialFitnessTaxonomies200Response._();

  factory ListOfficialFitnessTaxonomies200Response(
          [void updates(ListOfficialFitnessTaxonomies200ResponseBuilder b)]) =
      _$ListOfficialFitnessTaxonomies200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListOfficialFitnessTaxonomies200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListOfficialFitnessTaxonomies200Response> get serializer =>
      _$ListOfficialFitnessTaxonomies200ResponseSerializer();
}

class _$ListOfficialFitnessTaxonomies200ResponseSerializer
    implements PrimitiveSerializer<ListOfficialFitnessTaxonomies200Response> {
  @override
  final Iterable<Type> types = const [
    ListOfficialFitnessTaxonomies200Response,
    _$ListOfficialFitnessTaxonomies200Response
  ];

  @override
  final String wireName = r'ListOfficialFitnessTaxonomies200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListOfficialFitnessTaxonomies200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList,
          [FullType(ListOfficialFitnessTaxonomies200ResponseItemsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListOfficialFitnessTaxonomies200Response object, {
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
    required ListOfficialFitnessTaxonomies200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(ListOfficialFitnessTaxonomies200ResponseItemsInner)]),
          ) as BuiltList<ListOfficialFitnessTaxonomies200ResponseItemsInner>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListOfficialFitnessTaxonomies200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListOfficialFitnessTaxonomies200ResponseBuilder();
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
