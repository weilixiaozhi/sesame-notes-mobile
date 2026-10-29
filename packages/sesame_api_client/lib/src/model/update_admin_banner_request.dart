//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_admin_banner_request.g.dart';

/// UpdateAdminBannerRequest
///
/// Properties:
/// * [slot]
/// * [imageId]
/// * [target]
/// * [targetId]
/// * [sortOrder]
/// * [version]
@BuiltValue()
abstract class UpdateAdminBannerRequest
    implements
        Built<UpdateAdminBannerRequest, UpdateAdminBannerRequestBuilder> {
  @BuiltValueField(wireName: r'slot')
  UpdateAdminBannerRequestSlotEnum get slot;
  // enum slotEnum {  fitness-plan-library,  fitness-template-library,  };

  @BuiltValueField(wireName: r'image_id')
  String get imageId;

  @BuiltValueField(wireName: r'target')
  UpdateAdminBannerRequestTargetEnum get target;
  // enum targetEnum {  fitness-plan-library,  fitness-template-library,  fitness-exercises,  fitness-plans,  fitness-templates,  official-plan,  official-template,  };

  @BuiltValueField(wireName: r'target_id')
  String? get targetId;

  @BuiltValueField(wireName: r'sort_order')
  int get sortOrder;

  @BuiltValueField(wireName: r'version')
  int get version;

  UpdateAdminBannerRequest._();

  factory UpdateAdminBannerRequest(
          [void updates(UpdateAdminBannerRequestBuilder b)]) =
      _$UpdateAdminBannerRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateAdminBannerRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateAdminBannerRequest> get serializer =>
      _$UpdateAdminBannerRequestSerializer();
}

class _$UpdateAdminBannerRequestSerializer
    implements PrimitiveSerializer<UpdateAdminBannerRequest> {
  @override
  final Iterable<Type> types = const [
    UpdateAdminBannerRequest,
    _$UpdateAdminBannerRequest
  ];

  @override
  final String wireName = r'UpdateAdminBannerRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateAdminBannerRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(UpdateAdminBannerRequestSlotEnum),
    );
    yield r'image_id';
    yield serializers.serialize(
      object.imageId,
      specifiedType: const FullType(String),
    );
    yield r'target';
    yield serializers.serialize(
      object.target,
      specifiedType: const FullType(UpdateAdminBannerRequestTargetEnum),
    );
    yield r'target_id';
    yield object.targetId == null
        ? null
        : serializers.serialize(
            object.targetId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'sort_order';
    yield serializers.serialize(
      object.sortOrder,
      specifiedType: const FullType(int),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateAdminBannerRequest object, {
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
    required UpdateAdminBannerRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpdateAdminBannerRequestSlotEnum),
          ) as UpdateAdminBannerRequestSlotEnum;
          result.slot = valueDes;
          break;
        case r'image_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.imageId = valueDes;
          break;
        case r'target':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpdateAdminBannerRequestTargetEnum),
          ) as UpdateAdminBannerRequestTargetEnum;
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
        case r'sort_order':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sortOrder = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateAdminBannerRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateAdminBannerRequestBuilder();
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

class UpdateAdminBannerRequestSlotEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness-plan-library')
  static const UpdateAdminBannerRequestSlotEnum fitnessPlanLibrary =
      _$updateAdminBannerRequestSlotEnum_fitnessPlanLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-template-library')
  static const UpdateAdminBannerRequestSlotEnum fitnessTemplateLibrary =
      _$updateAdminBannerRequestSlotEnum_fitnessTemplateLibrary;

  static Serializer<UpdateAdminBannerRequestSlotEnum> get serializer =>
      _$updateAdminBannerRequestSlotEnumSerializer;

  const UpdateAdminBannerRequestSlotEnum._(String name) : super(name);

  static BuiltSet<UpdateAdminBannerRequestSlotEnum> get values =>
      _$updateAdminBannerRequestSlotEnumValues;
  static UpdateAdminBannerRequestSlotEnum valueOf(String name) =>
      _$updateAdminBannerRequestSlotEnumValueOf(name);
}

class UpdateAdminBannerRequestTargetEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness-plan-library')
  static const UpdateAdminBannerRequestTargetEnum fitnessPlanLibrary =
      _$updateAdminBannerRequestTargetEnum_fitnessPlanLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-template-library')
  static const UpdateAdminBannerRequestTargetEnum fitnessTemplateLibrary =
      _$updateAdminBannerRequestTargetEnum_fitnessTemplateLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-exercises')
  static const UpdateAdminBannerRequestTargetEnum fitnessExercises =
      _$updateAdminBannerRequestTargetEnum_fitnessExercises;
  @BuiltValueEnumConst(wireName: r'fitness-plans')
  static const UpdateAdminBannerRequestTargetEnum fitnessPlans =
      _$updateAdminBannerRequestTargetEnum_fitnessPlans;
  @BuiltValueEnumConst(wireName: r'fitness-templates')
  static const UpdateAdminBannerRequestTargetEnum fitnessTemplates =
      _$updateAdminBannerRequestTargetEnum_fitnessTemplates;
  @BuiltValueEnumConst(wireName: r'official-plan')
  static const UpdateAdminBannerRequestTargetEnum officialPlan =
      _$updateAdminBannerRequestTargetEnum_officialPlan;
  @BuiltValueEnumConst(wireName: r'official-template')
  static const UpdateAdminBannerRequestTargetEnum officialTemplate =
      _$updateAdminBannerRequestTargetEnum_officialTemplate;

  static Serializer<UpdateAdminBannerRequestTargetEnum> get serializer =>
      _$updateAdminBannerRequestTargetEnumSerializer;

  const UpdateAdminBannerRequestTargetEnum._(String name) : super(name);

  static BuiltSet<UpdateAdminBannerRequestTargetEnum> get values =>
      _$updateAdminBannerRequestTargetEnumValues;
  static UpdateAdminBannerRequestTargetEnum valueOf(String name) =>
      _$updateAdminBannerRequestTargetEnumValueOf(name);
}
