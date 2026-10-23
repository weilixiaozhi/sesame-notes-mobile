//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_official_fitness_taxonomies200_response_items_inner_name.g.dart';

/// ListOfficialFitnessTaxonomies200ResponseItemsInnerName
///
/// Properties:
/// * [zh]
/// * [zhHant]
/// * [en]
@BuiltValue()
abstract class ListOfficialFitnessTaxonomies200ResponseItemsInnerName
    implements
        Built<ListOfficialFitnessTaxonomies200ResponseItemsInnerName,
            ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder> {
  @BuiltValueField(wireName: r'zh')
  String get zh;

  @BuiltValueField(wireName: r'zh_hant')
  String get zhHant;

  @BuiltValueField(wireName: r'en')
  String get en;

  ListOfficialFitnessTaxonomies200ResponseItemsInnerName._();

  factory ListOfficialFitnessTaxonomies200ResponseItemsInnerName(
      [void updates(
          ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder
              b)]) = _$ListOfficialFitnessTaxonomies200ResponseItemsInnerName;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListOfficialFitnessTaxonomies200ResponseItemsInnerName>
      get serializer =>
          _$ListOfficialFitnessTaxonomies200ResponseItemsInnerNameSerializer();
}

class _$ListOfficialFitnessTaxonomies200ResponseItemsInnerNameSerializer
    implements
        PrimitiveSerializer<
            ListOfficialFitnessTaxonomies200ResponseItemsInnerName> {
  @override
  final Iterable<Type> types = const [
    ListOfficialFitnessTaxonomies200ResponseItemsInnerName,
    _$ListOfficialFitnessTaxonomies200ResponseItemsInnerName
  ];

  @override
  final String wireName =
      r'ListOfficialFitnessTaxonomies200ResponseItemsInnerName';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListOfficialFitnessTaxonomies200ResponseItemsInnerName object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'zh';
    yield serializers.serialize(
      object.zh,
      specifiedType: const FullType(String),
    );
    yield r'zh_hant';
    yield serializers.serialize(
      object.zhHant,
      specifiedType: const FullType(String),
    );
    yield r'en';
    yield serializers.serialize(
      object.en,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListOfficialFitnessTaxonomies200ResponseItemsInnerName object, {
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
    required ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'zh':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.zh = valueDes;
          break;
        case r'zh_hant':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.zhHant = valueDes;
          break;
        case r'en':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.en = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListOfficialFitnessTaxonomies200ResponseItemsInnerName deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder();
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
