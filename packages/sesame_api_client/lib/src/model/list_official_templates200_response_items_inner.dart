//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_library200_response_templates_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_official_templates200_response_items_inner.g.dart';

/// ListOfficialTemplates200ResponseItemsInner
///
/// Properties:
/// * [id]
/// * [kind]
/// * [version]
/// * [content]
/// * [isEnabled]
/// * [createdAt]
/// * [updatedAt]
/// * [updatedBy]
@BuiltValue()
abstract class ListOfficialTemplates200ResponseItemsInner
    implements
        Built<ListOfficialTemplates200ResponseItemsInner,
            ListOfficialTemplates200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'kind')
  ListOfficialTemplates200ResponseItemsInnerKindEnum get kind;
  // enum kindEnum {  exercise,  template,  plan,  };

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'content')
  GetFitnessLibrary200ResponseTemplatesInner get content;

  @BuiltValueField(wireName: r'is_enabled')
  bool get isEnabled;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'updated_by')
  String? get updatedBy;

  ListOfficialTemplates200ResponseItemsInner._();

  factory ListOfficialTemplates200ResponseItemsInner(
          [void updates(ListOfficialTemplates200ResponseItemsInnerBuilder b)]) =
      _$ListOfficialTemplates200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListOfficialTemplates200ResponseItemsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListOfficialTemplates200ResponseItemsInner>
      get serializer =>
          _$ListOfficialTemplates200ResponseItemsInnerSerializer();
}

class _$ListOfficialTemplates200ResponseItemsInnerSerializer
    implements PrimitiveSerializer<ListOfficialTemplates200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    ListOfficialTemplates200ResponseItemsInner,
    _$ListOfficialTemplates200ResponseItemsInner
  ];

  @override
  final String wireName = r'ListOfficialTemplates200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListOfficialTemplates200ResponseItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'kind';
    yield serializers.serialize(
      object.kind,
      specifiedType:
          const FullType(ListOfficialTemplates200ResponseItemsInnerKindEnum),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(GetFitnessLibrary200ResponseTemplatesInner),
    );
    yield r'is_enabled';
    yield serializers.serialize(
      object.isEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updated_by';
    yield object.updatedBy == null
        ? null
        : serializers.serialize(
            object.updatedBy,
            specifiedType: const FullType.nullable(String),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListOfficialTemplates200ResponseItemsInner object, {
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
    required ListOfficialTemplates200ResponseItemsInnerBuilder result,
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
        case r'kind':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                ListOfficialTemplates200ResponseItemsInnerKindEnum),
          ) as ListOfficialTemplates200ResponseItemsInnerKindEnum;
          result.kind = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(GetFitnessLibrary200ResponseTemplatesInner),
          ) as GetFitnessLibrary200ResponseTemplatesInner;
          result.content.replace(valueDes);
          break;
        case r'is_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isEnabled = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'updated_by':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.updatedBy = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListOfficialTemplates200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListOfficialTemplates200ResponseItemsInnerBuilder();
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

class ListOfficialTemplates200ResponseItemsInnerKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'exercise')
  static const ListOfficialTemplates200ResponseItemsInnerKindEnum exercise =
      _$listOfficialTemplates200ResponseItemsInnerKindEnum_exercise;
  @BuiltValueEnumConst(wireName: r'template')
  static const ListOfficialTemplates200ResponseItemsInnerKindEnum template =
      _$listOfficialTemplates200ResponseItemsInnerKindEnum_template;
  @BuiltValueEnumConst(wireName: r'plan')
  static const ListOfficialTemplates200ResponseItemsInnerKindEnum plan =
      _$listOfficialTemplates200ResponseItemsInnerKindEnum_plan;

  static Serializer<ListOfficialTemplates200ResponseItemsInnerKindEnum>
      get serializer =>
          _$listOfficialTemplates200ResponseItemsInnerKindEnumSerializer;

  const ListOfficialTemplates200ResponseItemsInnerKindEnum._(String name)
      : super(name);

  static BuiltSet<ListOfficialTemplates200ResponseItemsInnerKindEnum>
      get values => _$listOfficialTemplates200ResponseItemsInnerKindEnumValues;
  static ListOfficialTemplates200ResponseItemsInnerKindEnum valueOf(
          String name) =>
      _$listOfficialTemplates200ResponseItemsInnerKindEnumValueOf(name);
}
