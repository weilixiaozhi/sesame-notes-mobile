//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_admin_banner_request.g.dart';

/// CreateAdminBannerRequest
///
/// Properties:
/// * [slot]
/// * [imageId]
/// * [target]
/// * [targetId]
/// * [sortOrder]
@BuiltValue()
abstract class CreateAdminBannerRequest
    implements
        Built<CreateAdminBannerRequest, CreateAdminBannerRequestBuilder> {
  @BuiltValueField(wireName: r'slot')
  CreateAdminBannerRequestSlotEnum get slot;
  // enum slotEnum {  fitness-plan-library,  fitness-template-library,  };

  @BuiltValueField(wireName: r'image_id')
  String get imageId;

  @BuiltValueField(wireName: r'target')
  CreateAdminBannerRequestTargetEnum get target;
  // enum targetEnum {  fitness-plan-library,  fitness-template-library,  fitness-exercises,  fitness-plans,  fitness-templates,  official-plan,  official-template,  };

  @BuiltValueField(wireName: r'target_id')
  String? get targetId;

  @BuiltValueField(wireName: r'sort_order')
  int get sortOrder;

  CreateAdminBannerRequest._();

  factory CreateAdminBannerRequest(
          [void updates(CreateAdminBannerRequestBuilder b)]) =
      _$CreateAdminBannerRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateAdminBannerRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateAdminBannerRequest> get serializer =>
      _$CreateAdminBannerRequestSerializer();
}

class _$CreateAdminBannerRequestSerializer
    implements PrimitiveSerializer<CreateAdminBannerRequest> {
  @override
  final Iterable<Type> types = const [
    CreateAdminBannerRequest,
    _$CreateAdminBannerRequest
  ];

  @override
  final String wireName = r'CreateAdminBannerRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateAdminBannerRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType: const FullType(CreateAdminBannerRequestSlotEnum),
    );
    yield r'image_id';
    yield serializers.serialize(
      object.imageId,
      specifiedType: const FullType(String),
    );
    yield r'target';
    yield serializers.serialize(
      object.target,
      specifiedType: const FullType(CreateAdminBannerRequestTargetEnum),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateAdminBannerRequest object, {
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
    required CreateAdminBannerRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateAdminBannerRequestSlotEnum),
          ) as CreateAdminBannerRequestSlotEnum;
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
            specifiedType: const FullType(CreateAdminBannerRequestTargetEnum),
          ) as CreateAdminBannerRequestTargetEnum;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateAdminBannerRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateAdminBannerRequestBuilder();
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

class CreateAdminBannerRequestSlotEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness-plan-library')
  static const CreateAdminBannerRequestSlotEnum fitnessPlanLibrary =
      _$createAdminBannerRequestSlotEnum_fitnessPlanLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-template-library')
  static const CreateAdminBannerRequestSlotEnum fitnessTemplateLibrary =
      _$createAdminBannerRequestSlotEnum_fitnessTemplateLibrary;

  static Serializer<CreateAdminBannerRequestSlotEnum> get serializer =>
      _$createAdminBannerRequestSlotEnumSerializer;

  const CreateAdminBannerRequestSlotEnum._(String name) : super(name);

  static BuiltSet<CreateAdminBannerRequestSlotEnum> get values =>
      _$createAdminBannerRequestSlotEnumValues;
  static CreateAdminBannerRequestSlotEnum valueOf(String name) =>
      _$createAdminBannerRequestSlotEnumValueOf(name);
}

class CreateAdminBannerRequestTargetEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness-plan-library')
  static const CreateAdminBannerRequestTargetEnum fitnessPlanLibrary =
      _$createAdminBannerRequestTargetEnum_fitnessPlanLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-template-library')
  static const CreateAdminBannerRequestTargetEnum fitnessTemplateLibrary =
      _$createAdminBannerRequestTargetEnum_fitnessTemplateLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-exercises')
  static const CreateAdminBannerRequestTargetEnum fitnessExercises =
      _$createAdminBannerRequestTargetEnum_fitnessExercises;
  @BuiltValueEnumConst(wireName: r'fitness-plans')
  static const CreateAdminBannerRequestTargetEnum fitnessPlans =
      _$createAdminBannerRequestTargetEnum_fitnessPlans;
  @BuiltValueEnumConst(wireName: r'fitness-templates')
  static const CreateAdminBannerRequestTargetEnum fitnessTemplates =
      _$createAdminBannerRequestTargetEnum_fitnessTemplates;
  @BuiltValueEnumConst(wireName: r'official-plan')
  static const CreateAdminBannerRequestTargetEnum officialPlan =
      _$createAdminBannerRequestTargetEnum_officialPlan;
  @BuiltValueEnumConst(wireName: r'official-template')
  static const CreateAdminBannerRequestTargetEnum officialTemplate =
      _$createAdminBannerRequestTargetEnum_officialTemplate;

  static Serializer<CreateAdminBannerRequestTargetEnum> get serializer =>
      _$createAdminBannerRequestTargetEnumSerializer;

  const CreateAdminBannerRequestTargetEnum._(String name) : super(name);

  static BuiltSet<CreateAdminBannerRequestTargetEnum> get values =>
      _$createAdminBannerRequestTargetEnumValues;
  static CreateAdminBannerRequestTargetEnum valueOf(String name) =>
      _$createAdminBannerRequestTargetEnumValueOf(name);
}
