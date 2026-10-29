//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_admin_banner_statistics200_response_coverage.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_admin_banner_statistics200_response_items_inner.dart';
import 'package:sesame_api_client/src/model/get_admin_banner_statistics200_response_range.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_admin_banner_statistics200_response.g.dart';

/// GetAdminBannerStatistics200Response
///
/// Properties:
/// * [range]
/// * [scope]
/// * [items]
/// * [coverage]
@BuiltValue()
abstract class GetAdminBannerStatistics200Response
    implements
        Built<GetAdminBannerStatistics200Response,
            GetAdminBannerStatistics200ResponseBuilder> {
  @BuiltValueField(wireName: r'range')
  GetAdminBannerStatistics200ResponseRange get range;

  @BuiltValueField(wireName: r'scope')
  GetAdminBannerStatistics200ResponseScopeEnum get scope;
  // enum scopeEnum {  current,  };

  @BuiltValueField(wireName: r'items')
  BuiltList<GetAdminBannerStatistics200ResponseItemsInner> get items;

  @BuiltValueField(wireName: r'coverage')
  GetAdminBannerStatistics200ResponseCoverage get coverage;

  GetAdminBannerStatistics200Response._();

  factory GetAdminBannerStatistics200Response(
          [void updates(GetAdminBannerStatistics200ResponseBuilder b)]) =
      _$GetAdminBannerStatistics200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAdminBannerStatistics200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAdminBannerStatistics200Response> get serializer =>
      _$GetAdminBannerStatistics200ResponseSerializer();
}

class _$GetAdminBannerStatistics200ResponseSerializer
    implements PrimitiveSerializer<GetAdminBannerStatistics200Response> {
  @override
  final Iterable<Type> types = const [
    GetAdminBannerStatistics200Response,
    _$GetAdminBannerStatistics200Response
  ];

  @override
  final String wireName = r'GetAdminBannerStatistics200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAdminBannerStatistics200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'range';
    yield serializers.serialize(
      object.range,
      specifiedType: const FullType(GetAdminBannerStatistics200ResponseRange),
    );
    yield r'scope';
    yield serializers.serialize(
      object.scope,
      specifiedType:
          const FullType(GetAdminBannerStatistics200ResponseScopeEnum),
    );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(
          BuiltList, [FullType(GetAdminBannerStatistics200ResponseItemsInner)]),
    );
    yield r'coverage';
    yield serializers.serialize(
      object.coverage,
      specifiedType:
          const FullType(GetAdminBannerStatistics200ResponseCoverage),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAdminBannerStatistics200Response object, {
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
    required GetAdminBannerStatistics200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'range':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(GetAdminBannerStatistics200ResponseRange),
          ) as GetAdminBannerStatistics200ResponseRange;
          result.range.replace(valueDes);
          break;
        case r'scope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(GetAdminBannerStatistics200ResponseScopeEnum),
          ) as GetAdminBannerStatistics200ResponseScopeEnum;
          result.scope = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(GetAdminBannerStatistics200ResponseItemsInner)]),
          ) as BuiltList<GetAdminBannerStatistics200ResponseItemsInner>;
          result.items.replace(valueDes);
          break;
        case r'coverage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(GetAdminBannerStatistics200ResponseCoverage),
          ) as GetAdminBannerStatistics200ResponseCoverage;
          result.coverage.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAdminBannerStatistics200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAdminBannerStatistics200ResponseBuilder();
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

class GetAdminBannerStatistics200ResponseScopeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'current')
  static const GetAdminBannerStatistics200ResponseScopeEnum current =
      _$getAdminBannerStatistics200ResponseScopeEnum_current;

  static Serializer<GetAdminBannerStatistics200ResponseScopeEnum>
      get serializer =>
          _$getAdminBannerStatistics200ResponseScopeEnumSerializer;

  const GetAdminBannerStatistics200ResponseScopeEnum._(String name)
      : super(name);

  static BuiltSet<GetAdminBannerStatistics200ResponseScopeEnum> get values =>
      _$getAdminBannerStatistics200ResponseScopeEnumValues;
  static GetAdminBannerStatistics200ResponseScopeEnum valueOf(String name) =>
      _$getAdminBannerStatistics200ResponseScopeEnumValueOf(name);
}
