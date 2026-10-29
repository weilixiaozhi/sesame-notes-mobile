//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/list_admin_banners200_response_items_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_admin_banners200_response.g.dart';

/// ListAdminBanners200Response
///
/// Properties:
/// * [items]
@BuiltValue()
abstract class ListAdminBanners200Response
    implements
        Built<ListAdminBanners200Response, ListAdminBanners200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ListAdminBanners200ResponseItemsInner> get items;

  ListAdminBanners200Response._();

  factory ListAdminBanners200Response(
          [void updates(ListAdminBanners200ResponseBuilder b)]) =
      _$ListAdminBanners200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListAdminBanners200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListAdminBanners200Response> get serializer =>
      _$ListAdminBanners200ResponseSerializer();
}

class _$ListAdminBanners200ResponseSerializer
    implements PrimitiveSerializer<ListAdminBanners200Response> {
  @override
  final Iterable<Type> types = const [
    ListAdminBanners200Response,
    _$ListAdminBanners200Response
  ];

  @override
  final String wireName = r'ListAdminBanners200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListAdminBanners200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(
          BuiltList, [FullType(ListAdminBanners200ResponseItemsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListAdminBanners200Response object, {
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
    required ListAdminBanners200ResponseBuilder result,
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
                BuiltList, [FullType(ListAdminBanners200ResponseItemsInner)]),
          ) as BuiltList<ListAdminBanners200ResponseItemsInner>;
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
  ListAdminBanners200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListAdminBanners200ResponseBuilder();
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
