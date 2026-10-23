//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_fitness_library200_response_plans_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_official_plans200_response_items_inner.g.dart';

/// ListOfficialPlans200ResponseItemsInner
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
abstract class ListOfficialPlans200ResponseItemsInner
    implements
        Built<ListOfficialPlans200ResponseItemsInner,
            ListOfficialPlans200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'kind')
  ListOfficialPlans200ResponseItemsInnerKindEnum get kind;
  // enum kindEnum {  exercise,  template,  plan,  };

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'content')
  GetFitnessLibrary200ResponsePlansInner get content;

  @BuiltValueField(wireName: r'is_enabled')
  bool get isEnabled;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'updated_by')
  String? get updatedBy;

  ListOfficialPlans200ResponseItemsInner._();

  factory ListOfficialPlans200ResponseItemsInner(
          [void updates(ListOfficialPlans200ResponseItemsInnerBuilder b)]) =
      _$ListOfficialPlans200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListOfficialPlans200ResponseItemsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListOfficialPlans200ResponseItemsInner> get serializer =>
      _$ListOfficialPlans200ResponseItemsInnerSerializer();
}

class _$ListOfficialPlans200ResponseItemsInnerSerializer
    implements PrimitiveSerializer<ListOfficialPlans200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    ListOfficialPlans200ResponseItemsInner,
    _$ListOfficialPlans200ResponseItemsInner
  ];

  @override
  final String wireName = r'ListOfficialPlans200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListOfficialPlans200ResponseItemsInner object, {
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
          const FullType(ListOfficialPlans200ResponseItemsInnerKindEnum),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(GetFitnessLibrary200ResponsePlansInner),
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
    ListOfficialPlans200ResponseItemsInner object, {
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
    required ListOfficialPlans200ResponseItemsInnerBuilder result,
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
            specifiedType:
                const FullType(ListOfficialPlans200ResponseItemsInnerKindEnum),
          ) as ListOfficialPlans200ResponseItemsInnerKindEnum;
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
                const FullType(GetFitnessLibrary200ResponsePlansInner),
          ) as GetFitnessLibrary200ResponsePlansInner;
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
  ListOfficialPlans200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListOfficialPlans200ResponseItemsInnerBuilder();
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

class ListOfficialPlans200ResponseItemsInnerKindEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'exercise')
  static const ListOfficialPlans200ResponseItemsInnerKindEnum exercise =
      _$listOfficialPlans200ResponseItemsInnerKindEnum_exercise;
  @BuiltValueEnumConst(wireName: r'template')
  static const ListOfficialPlans200ResponseItemsInnerKindEnum template =
      _$listOfficialPlans200ResponseItemsInnerKindEnum_template;
  @BuiltValueEnumConst(wireName: r'plan')
  static const ListOfficialPlans200ResponseItemsInnerKindEnum plan =
      _$listOfficialPlans200ResponseItemsInnerKindEnum_plan;

  static Serializer<ListOfficialPlans200ResponseItemsInnerKindEnum>
      get serializer =>
          _$listOfficialPlans200ResponseItemsInnerKindEnumSerializer;

  const ListOfficialPlans200ResponseItemsInnerKindEnum._(String name)
      : super(name);

  static BuiltSet<ListOfficialPlans200ResponseItemsInnerKindEnum> get values =>
      _$listOfficialPlans200ResponseItemsInnerKindEnumValues;
  static ListOfficialPlans200ResponseItemsInnerKindEnum valueOf(String name) =>
      _$listOfficialPlans200ResponseItemsInnerKindEnumValueOf(name);
}
