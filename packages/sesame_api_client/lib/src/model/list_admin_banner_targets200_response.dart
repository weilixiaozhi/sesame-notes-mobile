//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/list_admin_banner_targets200_response_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_admin_banner_targets200_response.g.dart';

/// ListAdminBannerTargets200Response
///
/// Properties:
/// * [items]
@BuiltValue()
abstract class ListAdminBannerTargets200Response
    implements
        Built<ListAdminBannerTargets200Response,
            ListAdminBannerTargets200ResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ListAdminBannerTargets200ResponseItemsInner> get items;

  ListAdminBannerTargets200Response._();

  factory ListAdminBannerTargets200Response(
          [void updates(ListAdminBannerTargets200ResponseBuilder b)]) =
      _$ListAdminBannerTargets200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListAdminBannerTargets200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListAdminBannerTargets200Response> get serializer =>
      _$ListAdminBannerTargets200ResponseSerializer();
}

class _$ListAdminBannerTargets200ResponseSerializer
    implements PrimitiveSerializer<ListAdminBannerTargets200Response> {
  @override
  final Iterable<Type> types = const [
    ListAdminBannerTargets200Response,
    _$ListAdminBannerTargets200Response
  ];

  @override
  final String wireName = r'ListAdminBannerTargets200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListAdminBannerTargets200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(
          BuiltList, [FullType(ListAdminBannerTargets200ResponseItemsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListAdminBannerTargets200Response object, {
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
    required ListAdminBannerTargets200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList,
                [FullType(ListAdminBannerTargets200ResponseItemsInner)]),
          ) as BuiltList<ListAdminBannerTargets200ResponseItemsInner>;
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
  ListAdminBannerTargets200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListAdminBannerTargets200ResponseBuilder();
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
