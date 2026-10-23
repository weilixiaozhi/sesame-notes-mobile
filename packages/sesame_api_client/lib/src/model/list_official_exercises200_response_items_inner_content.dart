//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_official_exercises200_response_items_inner_content.g.dart';

/// ListOfficialExercises200ResponseItemsInnerContent
///
/// Properties:
/// * [id]
/// * [nameZh]
/// * [nameZhHant]
/// * [nameEn]
/// * [bodyPart]
/// * [equipment]
/// * [target]
/// * [secondaryMuscles]
/// * [instructionsZh]
/// * [instructionsZhHant]
/// * [instructionsEn]
/// * [attribution]
/// * [gifAsset]
/// * [mediaId]
@BuiltValue()
abstract class ListOfficialExercises200ResponseItemsInnerContent
    implements
        Built<ListOfficialExercises200ResponseItemsInnerContent,
            ListOfficialExercises200ResponseItemsInnerContentBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name_zh')
  String get nameZh;

  @BuiltValueField(wireName: r'name_zh_hant')
  String get nameZhHant;

  @BuiltValueField(wireName: r'name_en')
  String get nameEn;

  @BuiltValueField(wireName: r'body_part')
  String get bodyPart;

  @BuiltValueField(wireName: r'equipment')
  String get equipment;

  @BuiltValueField(wireName: r'target')
  String get target;

  @BuiltValueField(wireName: r'secondary_muscles')
  BuiltList<String> get secondaryMuscles;

  @BuiltValueField(wireName: r'instructions_zh')
  BuiltList<String> get instructionsZh;

  @BuiltValueField(wireName: r'instructions_zh_hant')
  BuiltList<String> get instructionsZhHant;

  @BuiltValueField(wireName: r'instructions_en')
  BuiltList<String> get instructionsEn;

  @BuiltValueField(wireName: r'attribution')
  String get attribution;

  @BuiltValueField(wireName: r'gif_asset')
  String get gifAsset;

  @BuiltValueField(wireName: r'media_id')
  String? get mediaId;

  ListOfficialExercises200ResponseItemsInnerContent._();

  factory ListOfficialExercises200ResponseItemsInnerContent(
          [void updates(
              ListOfficialExercises200ResponseItemsInnerContentBuilder b)]) =
      _$ListOfficialExercises200ResponseItemsInnerContent;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          ListOfficialExercises200ResponseItemsInnerContentBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListOfficialExercises200ResponseItemsInnerContent>
      get serializer =>
          _$ListOfficialExercises200ResponseItemsInnerContentSerializer();
}

class _$ListOfficialExercises200ResponseItemsInnerContentSerializer
    implements
        PrimitiveSerializer<ListOfficialExercises200ResponseItemsInnerContent> {
  @override
  final Iterable<Type> types = const [
    ListOfficialExercises200ResponseItemsInnerContent,
    _$ListOfficialExercises200ResponseItemsInnerContent
  ];

  @override
  final String wireName = r'ListOfficialExercises200ResponseItemsInnerContent';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListOfficialExercises200ResponseItemsInnerContent object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name_zh';
    yield serializers.serialize(
      object.nameZh,
      specifiedType: const FullType(String),
    );
    yield r'name_zh_hant';
    yield serializers.serialize(
      object.nameZhHant,
      specifiedType: const FullType(String),
    );
    yield r'name_en';
    yield serializers.serialize(
      object.nameEn,
      specifiedType: const FullType(String),
    );
    yield r'body_part';
    yield serializers.serialize(
      object.bodyPart,
      specifiedType: const FullType(String),
    );
    yield r'equipment';
    yield serializers.serialize(
      object.equipment,
      specifiedType: const FullType(String),
    );
    yield r'target';
    yield serializers.serialize(
      object.target,
      specifiedType: const FullType(String),
    );
    yield r'secondary_muscles';
    yield serializers.serialize(
      object.secondaryMuscles,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'instructions_zh';
    yield serializers.serialize(
      object.instructionsZh,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'instructions_zh_hant';
    yield serializers.serialize(
      object.instructionsZhHant,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'instructions_en';
    yield serializers.serialize(
      object.instructionsEn,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    yield r'attribution';
    yield serializers.serialize(
      object.attribution,
      specifiedType: const FullType(String),
    );
    yield r'gif_asset';
    yield serializers.serialize(
      object.gifAsset,
      specifiedType: const FullType(String),
    );
    if (object.mediaId != null) {
      yield r'media_id';
      yield serializers.serialize(
        object.mediaId,
        specifiedType: const FullType.nullable(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    ListOfficialExercises200ResponseItemsInnerContent object, {
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
    required ListOfficialExercises200ResponseItemsInnerContentBuilder result,
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
        case r'name_zh':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nameZh = valueDes;
          break;
        case r'name_zh_hant':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nameZhHant = valueDes;
          break;
        case r'name_en':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nameEn = valueDes;
          break;
        case r'body_part':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bodyPart = valueDes;
          break;
        case r'equipment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.equipment = valueDes;
          break;
        case r'target':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.target = valueDes;
          break;
        case r'secondary_muscles':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.secondaryMuscles.replace(valueDes);
          break;
        case r'instructions_zh':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.instructionsZh.replace(valueDes);
          break;
        case r'instructions_zh_hant':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.instructionsZhHant.replace(valueDes);
          break;
        case r'instructions_en':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.instructionsEn.replace(valueDes);
          break;
        case r'attribution':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.attribution = valueDes;
          break;
        case r'gif_asset':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.gifAsset = valueDes;
          break;
        case r'media_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mediaId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListOfficialExercises200ResponseItemsInnerContent deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListOfficialExercises200ResponseItemsInnerContentBuilder();
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
