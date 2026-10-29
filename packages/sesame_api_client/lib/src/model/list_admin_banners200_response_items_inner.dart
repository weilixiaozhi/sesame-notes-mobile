//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_admin_banners200_response_items_inner.g.dart';

/// ListAdminBanners200ResponseItemsInner
///
/// Properties:
/// * [id]
/// * [slot]
/// * [imagePath]
/// * [target]
/// * [targetId]
/// * [targetName]
/// * [version]
/// * [sortOrder]
/// * [source_]
/// * [updatedAt]
/// * [updatedBy]
@BuiltValue()
abstract class ListAdminBanners200ResponseItemsInner
    implements
        Built<ListAdminBanners200ResponseItemsInner,
            ListAdminBanners200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'slot')
  ListAdminBanners200ResponseItemsInnerSlotEnum get slot;
  // enum slotEnum {  fitness-plan-library,  fitness-template-library,  };

  @BuiltValueField(wireName: r'image_path')
  String? get imagePath;

  @BuiltValueField(wireName: r'target')
  ListAdminBanners200ResponseItemsInnerTargetEnum get target;
  // enum targetEnum {  fitness-plan-library,  fitness-template-library,  fitness-exercises,  fitness-plans,  fitness-templates,  official-plan,  official-template,  };

  @BuiltValueField(wireName: r'target_id')
  String? get targetId;

  @BuiltValueField(wireName: r'target_name')
  String? get targetName;

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'sort_order')
  int get sortOrder;

  @BuiltValueField(wireName: r'source')
  ListAdminBanners200ResponseItemsInnerSource_Enum get source_;
  // enum source_Enum {  builtin,  remote,  };

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: r'updated_by')
  String? get updatedBy;

  ListAdminBanners200ResponseItemsInner._();

  factory ListAdminBanners200ResponseItemsInner(
          [void updates(ListAdminBanners200ResponseItemsInnerBuilder b)]) =
      _$ListAdminBanners200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListAdminBanners200ResponseItemsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListAdminBanners200ResponseItemsInner> get serializer =>
      _$ListAdminBanners200ResponseItemsInnerSerializer();
}

class _$ListAdminBanners200ResponseItemsInnerSerializer
    implements PrimitiveSerializer<ListAdminBanners200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    ListAdminBanners200ResponseItemsInner,
    _$ListAdminBanners200ResponseItemsInner
  ];

  @override
  final String wireName = r'ListAdminBanners200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListAdminBanners200ResponseItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType:
          const FullType(ListAdminBanners200ResponseItemsInnerSlotEnum),
    );
    yield r'image_path';
    yield object.imagePath == null
        ? null
        : serializers.serialize(
            object.imagePath,
            specifiedType: const FullType.nullable(String),
          );
    yield r'target';
    yield serializers.serialize(
      object.target,
      specifiedType:
          const FullType(ListAdminBanners200ResponseItemsInnerTargetEnum),
    );
    yield r'target_id';
    yield object.targetId == null
        ? null
        : serializers.serialize(
            object.targetId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'target_name';
    yield object.targetName == null
        ? null
        : serializers.serialize(
            object.targetName,
            specifiedType: const FullType.nullable(String),
          );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'sort_order';
    yield serializers.serialize(
      object.sortOrder,
      specifiedType: const FullType(int),
    );
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType:
          const FullType(ListAdminBanners200ResponseItemsInnerSource_Enum),
    );
    yield r'updated_at';
    yield object.updatedAt == null
        ? null
        : serializers.serialize(
            object.updatedAt,
            specifiedType: const FullType.nullable(DateTime),
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
    ListAdminBanners200ResponseItemsInner object, {
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
    required ListAdminBanners200ResponseItemsInnerBuilder result,
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
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(ListAdminBanners200ResponseItemsInnerSlotEnum),
          ) as ListAdminBanners200ResponseItemsInnerSlotEnum;
          result.slot = valueDes;
          break;
        case r'image_path':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.imagePath = valueDes;
          break;
        case r'target':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(ListAdminBanners200ResponseItemsInnerTargetEnum),
          ) as ListAdminBanners200ResponseItemsInnerTargetEnum;
          result.target = valueDes;
          break;
        case r'target_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.targetId = valueDes;
          break;
        case r'target_name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.targetName = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'sort_order':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sortOrder = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                ListAdminBanners200ResponseItemsInnerSource_Enum),
          ) as ListAdminBanners200ResponseItemsInnerSource_Enum;
          result.source_ = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
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
  ListAdminBanners200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListAdminBanners200ResponseItemsInnerBuilder();
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

class ListAdminBanners200ResponseItemsInnerSlotEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness-plan-library')
  static const ListAdminBanners200ResponseItemsInnerSlotEnum
      fitnessPlanLibrary =
      _$listAdminBanners200ResponseItemsInnerSlotEnum_fitnessPlanLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-template-library')
  static const ListAdminBanners200ResponseItemsInnerSlotEnum
      fitnessTemplateLibrary =
      _$listAdminBanners200ResponseItemsInnerSlotEnum_fitnessTemplateLibrary;

  static Serializer<ListAdminBanners200ResponseItemsInnerSlotEnum>
      get serializer =>
          _$listAdminBanners200ResponseItemsInnerSlotEnumSerializer;

  const ListAdminBanners200ResponseItemsInnerSlotEnum._(String name)
      : super(name);

  static BuiltSet<ListAdminBanners200ResponseItemsInnerSlotEnum> get values =>
      _$listAdminBanners200ResponseItemsInnerSlotEnumValues;
  static ListAdminBanners200ResponseItemsInnerSlotEnum valueOf(String name) =>
      _$listAdminBanners200ResponseItemsInnerSlotEnumValueOf(name);
}

class ListAdminBanners200ResponseItemsInnerTargetEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness-plan-library')
  static const ListAdminBanners200ResponseItemsInnerTargetEnum
      fitnessPlanLibrary =
      _$listAdminBanners200ResponseItemsInnerTargetEnum_fitnessPlanLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-template-library')
  static const ListAdminBanners200ResponseItemsInnerTargetEnum
      fitnessTemplateLibrary =
      _$listAdminBanners200ResponseItemsInnerTargetEnum_fitnessTemplateLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-exercises')
  static const ListAdminBanners200ResponseItemsInnerTargetEnum
      fitnessExercises =
      _$listAdminBanners200ResponseItemsInnerTargetEnum_fitnessExercises;
  @BuiltValueEnumConst(wireName: r'fitness-plans')
  static const ListAdminBanners200ResponseItemsInnerTargetEnum fitnessPlans =
      _$listAdminBanners200ResponseItemsInnerTargetEnum_fitnessPlans;
  @BuiltValueEnumConst(wireName: r'fitness-templates')
  static const ListAdminBanners200ResponseItemsInnerTargetEnum
      fitnessTemplates =
      _$listAdminBanners200ResponseItemsInnerTargetEnum_fitnessTemplates;
  @BuiltValueEnumConst(wireName: r'official-plan')
  static const ListAdminBanners200ResponseItemsInnerTargetEnum officialPlan =
      _$listAdminBanners200ResponseItemsInnerTargetEnum_officialPlan;
  @BuiltValueEnumConst(wireName: r'official-template')
  static const ListAdminBanners200ResponseItemsInnerTargetEnum
      officialTemplate =
      _$listAdminBanners200ResponseItemsInnerTargetEnum_officialTemplate;

  static Serializer<ListAdminBanners200ResponseItemsInnerTargetEnum>
      get serializer =>
          _$listAdminBanners200ResponseItemsInnerTargetEnumSerializer;

  const ListAdminBanners200ResponseItemsInnerTargetEnum._(String name)
      : super(name);

  static BuiltSet<ListAdminBanners200ResponseItemsInnerTargetEnum> get values =>
      _$listAdminBanners200ResponseItemsInnerTargetEnumValues;
  static ListAdminBanners200ResponseItemsInnerTargetEnum valueOf(String name) =>
      _$listAdminBanners200ResponseItemsInnerTargetEnumValueOf(name);
}

class ListAdminBanners200ResponseItemsInnerSource_Enum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'builtin')
  static const ListAdminBanners200ResponseItemsInnerSource_Enum builtin =
      _$listAdminBanners200ResponseItemsInnerSourceEnum_builtin;
  @BuiltValueEnumConst(wireName: r'remote')
  static const ListAdminBanners200ResponseItemsInnerSource_Enum remote =
      _$listAdminBanners200ResponseItemsInnerSourceEnum_remote;

  static Serializer<ListAdminBanners200ResponseItemsInnerSource_Enum>
      get serializer =>
          _$listAdminBanners200ResponseItemsInnerSourceEnumSerializer;

  const ListAdminBanners200ResponseItemsInnerSource_Enum._(String name)
      : super(name);

  static BuiltSet<ListAdminBanners200ResponseItemsInnerSource_Enum>
      get values => _$listAdminBanners200ResponseItemsInnerSourceEnumValues;
  static ListAdminBanners200ResponseItemsInnerSource_Enum valueOf(
          String name) =>
      _$listAdminBanners200ResponseItemsInnerSourceEnumValueOf(name);
}
