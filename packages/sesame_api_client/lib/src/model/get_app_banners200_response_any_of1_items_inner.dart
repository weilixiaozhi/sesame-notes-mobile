//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_app_banners200_response_any_of1_items_inner.g.dart';

/// GetAppBanners200ResponseAnyOf1ItemsInner
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
abstract class GetAppBanners200ResponseAnyOf1ItemsInner
    implements
        Built<GetAppBanners200ResponseAnyOf1ItemsInner,
            GetAppBanners200ResponseAnyOf1ItemsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'slot')
  GetAppBanners200ResponseAnyOf1ItemsInnerSlotEnum get slot;
  // enum slotEnum {  fitness-plan-library,  fitness-template-library,  };

  @BuiltValueField(wireName: r'image_path')
  String? get imagePath;

  @BuiltValueField(wireName: r'target')
  GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum get target;
  // enum targetEnum {  fitness-plan-library,  fitness-template-library,  fitness-exercises,  fitness-plans,  fitness-templates,  official-plan,  official-template,  };

  @BuiltValueField(wireName: r'target_id')
  String? get targetId;

  @BuiltValueField(wireName: r'target_name')
  String? get targetName;

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'sort_order')
  int get sortOrder;

  GetAppBanners200ResponseAnyOf1ItemsInner._();

  factory GetAppBanners200ResponseAnyOf1ItemsInner(
          [void updates(GetAppBanners200ResponseAnyOf1ItemsInnerBuilder b)]) =
      _$GetAppBanners200ResponseAnyOf1ItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAppBanners200ResponseAnyOf1ItemsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAppBanners200ResponseAnyOf1ItemsInner> get serializer =>
      _$GetAppBanners200ResponseAnyOf1ItemsInnerSerializer();
}

class _$GetAppBanners200ResponseAnyOf1ItemsInnerSerializer
    implements PrimitiveSerializer<GetAppBanners200ResponseAnyOf1ItemsInner> {
  @override
  final Iterable<Type> types = const [
    GetAppBanners200ResponseAnyOf1ItemsInner,
    _$GetAppBanners200ResponseAnyOf1ItemsInner
  ];

  @override
  final String wireName = r'GetAppBanners200ResponseAnyOf1ItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAppBanners200ResponseAnyOf1ItemsInner object, {
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
          const FullType(GetAppBanners200ResponseAnyOf1ItemsInnerSlotEnum),
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
          const FullType(GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum),
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
    GetAppBanners200ResponseAnyOf1ItemsInner object, {
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
    required GetAppBanners200ResponseAnyOf1ItemsInnerBuilder result,
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
            specifiedType: const FullType(
                GetAppBanners200ResponseAnyOf1ItemsInnerSlotEnum),
          ) as GetAppBanners200ResponseAnyOf1ItemsInnerSlotEnum;
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
            specifiedType: const FullType(
                GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum),
          ) as GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum;
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
  GetAppBanners200ResponseAnyOf1ItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAppBanners200ResponseAnyOf1ItemsInnerBuilder();
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

class GetAppBanners200ResponseAnyOf1ItemsInnerSlotEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness-plan-library')
  static const GetAppBanners200ResponseAnyOf1ItemsInnerSlotEnum
      fitnessPlanLibrary =
      _$getAppBanners200ResponseAnyOf1ItemsInnerSlotEnum_fitnessPlanLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-template-library')
  static const GetAppBanners200ResponseAnyOf1ItemsInnerSlotEnum
      fitnessTemplateLibrary =
      _$getAppBanners200ResponseAnyOf1ItemsInnerSlotEnum_fitnessTemplateLibrary;

  static Serializer<GetAppBanners200ResponseAnyOf1ItemsInnerSlotEnum>
      get serializer =>
          _$getAppBanners200ResponseAnyOf1ItemsInnerSlotEnumSerializer;

  const GetAppBanners200ResponseAnyOf1ItemsInnerSlotEnum._(String name)
      : super(name);

  static BuiltSet<GetAppBanners200ResponseAnyOf1ItemsInnerSlotEnum>
      get values => _$getAppBanners200ResponseAnyOf1ItemsInnerSlotEnumValues;
  static GetAppBanners200ResponseAnyOf1ItemsInnerSlotEnum valueOf(
          String name) =>
      _$getAppBanners200ResponseAnyOf1ItemsInnerSlotEnumValueOf(name);
}

class GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness-plan-library')
  static const GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum
      fitnessPlanLibrary =
      _$getAppBanners200ResponseAnyOf1ItemsInnerTargetEnum_fitnessPlanLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-template-library')
  static const GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum
      fitnessTemplateLibrary =
      _$getAppBanners200ResponseAnyOf1ItemsInnerTargetEnum_fitnessTemplateLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-exercises')
  static const GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum
      fitnessExercises =
      _$getAppBanners200ResponseAnyOf1ItemsInnerTargetEnum_fitnessExercises;
  @BuiltValueEnumConst(wireName: r'fitness-plans')
  static const GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum fitnessPlans =
      _$getAppBanners200ResponseAnyOf1ItemsInnerTargetEnum_fitnessPlans;
  @BuiltValueEnumConst(wireName: r'fitness-templates')
  static const GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum
      fitnessTemplates =
      _$getAppBanners200ResponseAnyOf1ItemsInnerTargetEnum_fitnessTemplates;
  @BuiltValueEnumConst(wireName: r'official-plan')
  static const GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum officialPlan =
      _$getAppBanners200ResponseAnyOf1ItemsInnerTargetEnum_officialPlan;
  @BuiltValueEnumConst(wireName: r'official-template')
  static const GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum
      officialTemplate =
      _$getAppBanners200ResponseAnyOf1ItemsInnerTargetEnum_officialTemplate;

  static Serializer<GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum>
      get serializer =>
          _$getAppBanners200ResponseAnyOf1ItemsInnerTargetEnumSerializer;

  const GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum._(String name)
      : super(name);

  static BuiltSet<GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum>
      get values => _$getAppBanners200ResponseAnyOf1ItemsInnerTargetEnumValues;
  static GetAppBanners200ResponseAnyOf1ItemsInnerTargetEnum valueOf(
          String name) =>
      _$getAppBanners200ResponseAnyOf1ItemsInnerTargetEnumValueOf(name);
}
