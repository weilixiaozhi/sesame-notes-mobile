//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_app_banners200_response_any_of1.dart';
import 'package:sesame_api_client/src/model/get_app_banners200_response_any_of1_items_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_app_banners200_response_any_of.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'get_app_banners200_response.g.dart';

/// GetAppBanners200Response
///
/// Properties:
/// * [items]
@BuiltValue()
abstract class GetAppBanners200Response
    implements
        Built<GetAppBanners200Response, GetAppBanners200ResponseBuilder> {
  /// Any Of [GetAppBanners200ResponseAnyOf], [GetAppBanners200ResponseAnyOf1]
  AnyOf get anyOf;

  GetAppBanners200Response._();

  factory GetAppBanners200Response(
          [void updates(GetAppBanners200ResponseBuilder b)]) =
      _$GetAppBanners200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAppBanners200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAppBanners200Response> get serializer =>
      _$GetAppBanners200ResponseSerializer();
}

class _$GetAppBanners200ResponseSerializer
    implements PrimitiveSerializer<GetAppBanners200Response> {
  @override
  final Iterable<Type> types = const [
    GetAppBanners200Response,
    _$GetAppBanners200Response
  ];

  @override
  final String wireName = r'GetAppBanners200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAppBanners200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    GetAppBanners200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  GetAppBanners200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAppBanners200ResponseBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(GetAppBanners200ResponseAnyOf),
      FullType(GetAppBanners200ResponseAnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}
