//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_banner_statistics200_response_items_inner.g.dart';

/// GetAdminBannerStatistics200ResponseItemsInner
///
/// Properties:
/// * [bannerId]
/// * [slot]
/// * [source_]
/// * [version]
/// * [impressions]
/// * [clicks]
/// * [ctr]
@BuiltValue()
abstract class GetAdminBannerStatistics200ResponseItemsInner
    implements
        Built<GetAdminBannerStatistics200ResponseItemsInner,
            GetAdminBannerStatistics200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'banner_id')
  String get bannerId;

  @BuiltValueField(wireName: r'slot')
  GetAdminBannerStatistics200ResponseItemsInnerSlotEnum get slot;
  // enum slotEnum {  fitness-plan-library,  fitness-template-library,  };

  @BuiltValueField(wireName: r'source')
  GetAdminBannerStatistics200ResponseItemsInnerSource_Enum get source_;
  // enum source_Enum {  builtin,  remote,  };

  @BuiltValueField(wireName: r'version')
  int get version;

  @BuiltValueField(wireName: r'impressions')
  int get impressions;

  @BuiltValueField(wireName: r'clicks')
  int get clicks;

  @BuiltValueField(wireName: r'ctr')
  num? get ctr;

  GetAdminBannerStatistics200ResponseItemsInner._();

  factory GetAdminBannerStatistics200ResponseItemsInner(
          [void updates(
              GetAdminBannerStatistics200ResponseItemsInnerBuilder b)]) =
      _$GetAdminBannerStatistics200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetAdminBannerStatistics200ResponseItemsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminBannerStatistics200ResponseItemsInner>
      get serializer =>
          _$GetAdminBannerStatistics200ResponseItemsInnerSerializer();
}

class _$GetAdminBannerStatistics200ResponseItemsInnerSerializer
    implements
        PrimitiveSerializer<GetAdminBannerStatistics200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    GetAdminBannerStatistics200ResponseItemsInner,
    _$GetAdminBannerStatistics200ResponseItemsInner
  ];

  @override
  final String wireName = r'GetAdminBannerStatistics200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminBannerStatistics200ResponseItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'banner_id';
    yield serializers.serialize(
      object.bannerId,
      specifiedType: const FullType(String),
    );
    yield r'slot';
    yield serializers.serialize(
      object.slot,
      specifiedType:
          const FullType(GetAdminBannerStatistics200ResponseItemsInnerSlotEnum),
    );
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(
          GetAdminBannerStatistics200ResponseItemsInnerSource_Enum),
    );
    yield r'version';
    yield serializers.serialize(
      object.version,
      specifiedType: const FullType(int),
    );
    yield r'impressions';
    yield serializers.serialize(
      object.impressions,
      specifiedType: const FullType(int),
    );
    yield r'clicks';
    yield serializers.serialize(
      object.clicks,
      specifiedType: const FullType(int),
    );
    yield r'ctr';
    yield object.ctr == null
        ? null
        : serializers.serialize(
            object.ctr,
            specifiedType: const FullType.nullable(num),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminBannerStatistics200ResponseItemsInner object, {
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
    required GetAdminBannerStatistics200ResponseItemsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'banner_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bannerId = valueDes;
          break;
        case r'slot':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetAdminBannerStatistics200ResponseItemsInnerSlotEnum),
          ) as GetAdminBannerStatistics200ResponseItemsInnerSlotEnum;
          result.slot = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetAdminBannerStatistics200ResponseItemsInnerSource_Enum),
          ) as GetAdminBannerStatistics200ResponseItemsInnerSource_Enum;
          result.source_ = valueDes;
          break;
        case r'version':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.version = valueDes;
          break;
        case r'impressions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.impressions = valueDes;
          break;
        case r'clicks':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.clicks = valueDes;
          break;
        case r'ctr':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.ctr = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminBannerStatistics200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminBannerStatistics200ResponseItemsInnerBuilder();
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

class GetAdminBannerStatistics200ResponseItemsInnerSlotEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness-plan-library')
  static const GetAdminBannerStatistics200ResponseItemsInnerSlotEnum
      fitnessPlanLibrary =
      _$getAdminBannerStatistics200ResponseItemsInnerSlotEnum_fitnessPlanLibrary;
  @BuiltValueEnumConst(wireName: r'fitness-template-library')
  static const GetAdminBannerStatistics200ResponseItemsInnerSlotEnum
      fitnessTemplateLibrary =
      _$getAdminBannerStatistics200ResponseItemsInnerSlotEnum_fitnessTemplateLibrary;

  static Serializer<GetAdminBannerStatistics200ResponseItemsInnerSlotEnum>
      get serializer =>
          _$getAdminBannerStatistics200ResponseItemsInnerSlotEnumSerializer;

  const GetAdminBannerStatistics200ResponseItemsInnerSlotEnum._(String name)
      : super(name);

  static BuiltSet<GetAdminBannerStatistics200ResponseItemsInnerSlotEnum>
      get values =>
          _$getAdminBannerStatistics200ResponseItemsInnerSlotEnumValues;
  static GetAdminBannerStatistics200ResponseItemsInnerSlotEnum valueOf(
          String name) =>
      _$getAdminBannerStatistics200ResponseItemsInnerSlotEnumValueOf(name);
}

class GetAdminBannerStatistics200ResponseItemsInnerSource_Enum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'builtin')
  static const GetAdminBannerStatistics200ResponseItemsInnerSource_Enum
      builtin =
      _$getAdminBannerStatistics200ResponseItemsInnerSourceEnum_builtin;
  @BuiltValueEnumConst(wireName: r'remote')
  static const GetAdminBannerStatistics200ResponseItemsInnerSource_Enum remote =
      _$getAdminBannerStatistics200ResponseItemsInnerSourceEnum_remote;

  static Serializer<GetAdminBannerStatistics200ResponseItemsInnerSource_Enum>
      get serializer =>
          _$getAdminBannerStatistics200ResponseItemsInnerSourceEnumSerializer;

  const GetAdminBannerStatistics200ResponseItemsInnerSource_Enum._(String name)
      : super(name);

  static BuiltSet<GetAdminBannerStatistics200ResponseItemsInnerSource_Enum>
      get values =>
          _$getAdminBannerStatistics200ResponseItemsInnerSourceEnumValues;
  static GetAdminBannerStatistics200ResponseItemsInnerSource_Enum valueOf(
          String name) =>
      _$getAdminBannerStatistics200ResponseItemsInnerSourceEnumValueOf(name);
}
