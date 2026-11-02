//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_app_banners200_response_items_inner.g.dart';

/// GetAppBanners200ResponseItemsInner
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
@BuiltValue()
abstract class GetAppBanners200ResponseItemsInner
    implements
        Built<GetAppBanners200ResponseItemsInner,
            GetAppBanners200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'slot')
  GetAppBanners200ResponseItemsInnerSlotEnum get slot;
  // enum slotEnum {  fitness-plan-library,  fitness-template-library,  };

  @BuiltValueField(wireName: r'image_path')
  String? get imagePath;

  @BuiltValueField(wireName: r'target')
  GetAppBanners200ResponseItemsInnerTargetEnum get target;
  // enum targetEnum {  fitness-plan-library,  fitness-template-library,  fitness-exercises,  fitness-plans,  fitness-templates,  official-plan,  official-template,  };

  @BuiltValueField(wireName: r'target_id')
  String? get targetId;

  @BuiltValueField(wireName: r'target_name')
  String? get targetName;

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'sort_order')
  int get sortOrder;

  GetAppBanners200ResponseItemsInner._();

  factory GetAppBanners200ResponseItemsInner(
          [void updates(GetAppBanners200ResponseItemsInnerBuilder b)]) =
      _$GetAppBanners200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAppBanners200ResponseItemsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAppBanners200ResponseItemsInner> get serializer =>
      _$GetAppBanners200ResponseItemsInnerSerializer();
}

class _$GetAppBanners200ResponseItemsInnerSerializer
    implements PrimitiveSerializer<GetAppBanners200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    GetAppBanners200ResponseItemsInner,
    _$GetAppBanners200ResponseItemsInner
  ];

  @override
  final String wireName = r'GetAppBanners200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAppBanners200ResponseItemsInner object, {
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
      specifiedType: const FullType(GetAppBanners200ResponseItemsInnerSlotEnum),
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
          const FullType(GetAppBanners200ResponseItemsInnerTargetEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAppBanners200ResponseItemsInner object, {
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
    required GetAppBanners200ResponseItemsInnerBuilder result,
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
                const FullType(GetAppBanners200ResponseItemsInnerSlotEnum),
          ) as GetAppBanners200ResponseItemsInnerSlotEnum;
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
                const FullType(GetAppBanners200ResponseItemsInnerTargetEnum),
          ) as GetAppBanners200ResponseItemsInnerTargetEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAppBanners200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAppBanners200ResponseItemsInnerBuilder();
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

class GetAppBanners200ResponseItemsInnerSlotEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness-plan-library')
  static const GetAppBanners200ResponseItemsInnerSlotEnum fitnessPlanLibrary =
      _$getAppBanners200ResponseItemsInnerSlotEnum_fitnessPlanLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-template-library')
  static const GetAppBanners200ResponseItemsInnerSlotEnum
      fitnessTemplateLibrary =
      _$getAppBanners200ResponseItemsInnerSlotEnum_fitnessTemplateLibrary;

  static Serializer<GetAppBanners200ResponseItemsInnerSlotEnum>
      get serializer => _$getAppBanners200ResponseItemsInnerSlotEnumSerializer;

  const GetAppBanners200ResponseItemsInnerSlotEnum._(String name) : super(name);

  static BuiltSet<GetAppBanners200ResponseItemsInnerSlotEnum> get values =>
      _$getAppBanners200ResponseItemsInnerSlotEnumValues;
  static GetAppBanners200ResponseItemsInnerSlotEnum valueOf(String name) =>
      _$getAppBanners200ResponseItemsInnerSlotEnumValueOf(name);
}

class GetAppBanners200ResponseItemsInnerTargetEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness-plan-library')
  static const GetAppBanners200ResponseItemsInnerTargetEnum fitnessPlanLibrary =
      _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessPlanLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-template-library')
  static const GetAppBanners200ResponseItemsInnerTargetEnum
      fitnessTemplateLibrary =
      _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessTemplateLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-exercises')
  static const GetAppBanners200ResponseItemsInnerTargetEnum fitnessExercises =
      _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessExercises;
  @BuiltValueEnumConst(wireName: r'fitness-plans')
  static const GetAppBanners200ResponseItemsInnerTargetEnum fitnessPlans =
      _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessPlans;
  @BuiltValueEnumConst(wireName: r'fitness-templates')
  static const GetAppBanners200ResponseItemsInnerTargetEnum fitnessTemplates =
      _$getAppBanners200ResponseItemsInnerTargetEnum_fitnessTemplates;
  @BuiltValueEnumConst(wireName: r'official-plan')
  static const GetAppBanners200ResponseItemsInnerTargetEnum officialPlan =
      _$getAppBanners200ResponseItemsInnerTargetEnum_officialPlan;
  @BuiltValueEnumConst(wireName: r'official-template')
  static const GetAppBanners200ResponseItemsInnerTargetEnum officialTemplate =
      _$getAppBanners200ResponseItemsInnerTargetEnum_officialTemplate;

  static Serializer<GetAppBanners200ResponseItemsInnerTargetEnum>
      get serializer =>
          _$getAppBanners200ResponseItemsInnerTargetEnumSerializer;

  const GetAppBanners200ResponseItemsInnerTargetEnum._(String name)
      : super(name);

  static BuiltSet<GetAppBanners200ResponseItemsInnerTargetEnum> get values =>
      _$getAppBanners200ResponseItemsInnerTargetEnumValues;
  static GetAppBanners200ResponseItemsInnerTargetEnum valueOf(String name) =>
      _$getAppBanners200ResponseItemsInnerTargetEnumValueOf(name);
}
