//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_app_banners200_response_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_app_banners200_response.g.dart';

/// GetAppBanners200Response
///
/// Properties:
/// * [items]
@BuiltValue()
abstract class GetAppBanners200Response
    implements
        Built<GetAppBanners200Response, GetAppBanners200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<GetAppBanners200ResponseItemsInner> get items;

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
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(
          BuiltList, [FullType(GetAppBanners200ResponseItemsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAppBanners200Response object, {
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
    required GetAppBanners200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltList, [FullType(GetAppBanners200ResponseItemsInner)]),
          ) as BuiltList<GetAppBanners200ResponseItemsInner>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetAppBanners200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAppBanners200ResponseBuilder();
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
