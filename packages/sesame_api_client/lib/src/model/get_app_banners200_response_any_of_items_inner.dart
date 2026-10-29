//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_app_banners200_response_any_of_items_inner.g.dart';

/// GetAppBanners200ResponseAnyOfItemsInner
///
/// Properties:
/// * [slot]
/// * [imagePath]
/// * [target]
/// * [isEnabled]
/// * [version]
/// * [updatedAt]
@BuiltValue()
abstract class GetAppBanners200ResponseAnyOfItemsInner
    implements
        Built<GetAppBanners200ResponseAnyOfItemsInner,
            GetAppBanners200ResponseAnyOfItemsInnerBuilder> {
  @BuiltValueField(wireName: r'slot')
  GetAppBanners200ResponseAnyOfItemsInnerSlotEnum get slot;
  // enum slotEnum {  fitness-plan-library,  fitness-template-library,  };

  @BuiltValueField(wireName: r'image_path')
  String? get imagePath;

  @BuiltValueField(wireName: r'target')
  GetAppBanners200ResponseAnyOfItemsInnerTargetEnum get target;
  // enum targetEnum {  fitness-plan-library,  fitness-template-library,  fitness-exercises,  fitness-plans,  fitness-templates,  };

  @BuiltValueField(wireName: r'is_enabled')
  bool get isEnabled;

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'updated_at')
  DateTime? get updatedAt;

  GetAppBanners200ResponseAnyOfItemsInner._();

  factory GetAppBanners200ResponseAnyOfItemsInner(
          [void updates(GetAppBanners200ResponseAnyOfItemsInnerBuilder b)]) =
      _$GetAppBanners200ResponseAnyOfItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAppBanners200ResponseAnyOfItemsInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAppBanners200ResponseAnyOfItemsInner> get serializer =>
      _$GetAppBanners200ResponseAnyOfItemsInnerSerializer();
}

class _$GetAppBanners200ResponseAnyOfItemsInnerSerializer
    implements PrimitiveSerializer<GetAppBanners200ResponseAnyOfItemsInner> {
  @override
  final Iterable<Type> types = const [
    GetAppBanners200ResponseAnyOfItemsInner,
    _$GetAppBanners200ResponseAnyOfItemsInner
  ];

  @override
  final String wireName = r'GetAppBanners200ResponseAnyOfItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAppBanners200ResponseAnyOfItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType:
          const FullType(GetAppBanners200ResponseAnyOfItemsInnerSlotEnum),
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
          const FullType(GetAppBanners200ResponseAnyOfItemsInnerTargetEnum),
    );
    yield r'is_enabled';
    yield serializers.serialize(
      object.isEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'updated_at';
    yield object.updatedAt == null
        ? null
        : serializers.serialize(
            object.updatedAt,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAppBanners200ResponseAnyOfItemsInner object, {
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
    required GetAppBanners200ResponseAnyOfItemsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(GetAppBanners200ResponseAnyOfItemsInnerSlotEnum),
          ) as GetAppBanners200ResponseAnyOfItemsInnerSlotEnum;
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
                GetAppBanners200ResponseAnyOfItemsInnerTargetEnum),
          ) as GetAppBanners200ResponseAnyOfItemsInnerTargetEnum;
          result.target = valueDes;
          break;
        case r'is_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isEnabled = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAppBanners200ResponseAnyOfItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAppBanners200ResponseAnyOfItemsInnerBuilder();
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

class GetAppBanners200ResponseAnyOfItemsInnerSlotEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness-plan-library')
  static const GetAppBanners200ResponseAnyOfItemsInnerSlotEnum
      fitnessPlanLibrary =
      _$getAppBanners200ResponseAnyOfItemsInnerSlotEnum_fitnessPlanLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-template-library')
  static const GetAppBanners200ResponseAnyOfItemsInnerSlotEnum
      fitnessTemplateLibrary =
      _$getAppBanners200ResponseAnyOfItemsInnerSlotEnum_fitnessTemplateLibrary;

  static Serializer<GetAppBanners200ResponseAnyOfItemsInnerSlotEnum>
      get serializer =>
          _$getAppBanners200ResponseAnyOfItemsInnerSlotEnumSerializer;

  const GetAppBanners200ResponseAnyOfItemsInnerSlotEnum._(String name)
      : super(name);

  static BuiltSet<GetAppBanners200ResponseAnyOfItemsInnerSlotEnum> get values =>
      _$getAppBanners200ResponseAnyOfItemsInnerSlotEnumValues;
  static GetAppBanners200ResponseAnyOfItemsInnerSlotEnum valueOf(String name) =>
      _$getAppBanners200ResponseAnyOfItemsInnerSlotEnumValueOf(name);
}

class GetAppBanners200ResponseAnyOfItemsInnerTargetEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness-plan-library')
  static const GetAppBanners200ResponseAnyOfItemsInnerTargetEnum
      fitnessPlanLibrary =
      _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessPlanLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-template-library')
  static const GetAppBanners200ResponseAnyOfItemsInnerTargetEnum
      fitnessTemplateLibrary =
      _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessTemplateLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-exercises')
  static const GetAppBanners200ResponseAnyOfItemsInnerTargetEnum
      fitnessExercises =
      _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessExercises;
  @BuiltValueEnumConst(wireName: r'fitness-plans')
  static const GetAppBanners200ResponseAnyOfItemsInnerTargetEnum fitnessPlans =
      _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessPlans;
  @BuiltValueEnumConst(wireName: r'fitness-templates')
  static const GetAppBanners200ResponseAnyOfItemsInnerTargetEnum
      fitnessTemplates =
      _$getAppBanners200ResponseAnyOfItemsInnerTargetEnum_fitnessTemplates;

  static Serializer<GetAppBanners200ResponseAnyOfItemsInnerTargetEnum>
      get serializer =>
          _$getAppBanners200ResponseAnyOfItemsInnerTargetEnumSerializer;

  const GetAppBanners200ResponseAnyOfItemsInnerTargetEnum._(String name)
      : super(name);

  static BuiltSet<GetAppBanners200ResponseAnyOfItemsInnerTargetEnum>
      get values => _$getAppBanners200ResponseAnyOfItemsInnerTargetEnumValues;
  static GetAppBanners200ResponseAnyOfItemsInnerTargetEnum valueOf(
          String name) =>
      _$getAppBanners200ResponseAnyOfItemsInnerTargetEnumValueOf(name);
}
