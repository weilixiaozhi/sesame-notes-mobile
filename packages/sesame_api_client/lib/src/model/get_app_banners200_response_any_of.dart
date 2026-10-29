//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_app_banners200_response_any_of_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_app_banners200_response_any_of.g.dart';

/// GetAppBanners200ResponseAnyOf
///
/// Properties:
/// * [items]
@BuiltValue()
abstract class GetAppBanners200ResponseAnyOf
    implements
        Built<GetAppBanners200ResponseAnyOf,
            GetAppBanners200ResponseAnyOfBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<GetAppBanners200ResponseAnyOfItemsInner> get items;

  GetAppBanners200ResponseAnyOf._();

  factory GetAppBanners200ResponseAnyOf(
          [void updates(GetAppBanners200ResponseAnyOfBuilder b)]) =
      _$GetAppBanners200ResponseAnyOf;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAppBanners200ResponseAnyOfBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAppBanners200ResponseAnyOf> get serializer =>
      _$GetAppBanners200ResponseAnyOfSerializer();
}

class _$GetAppBanners200ResponseAnyOfSerializer
    implements PrimitiveSerializer<GetAppBanners200ResponseAnyOf> {
  @override
  final Iterable<Type> types = const [
    GetAppBanners200ResponseAnyOf,
    _$GetAppBanners200ResponseAnyOf
  ];

  @override
  final String wireName = r'GetAppBanners200ResponseAnyOf';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAppBanners200ResponseAnyOf object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(
          BuiltList, [FullType(GetAppBanners200ResponseAnyOfItemsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAppBanners200ResponseAnyOf object, {
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
    required GetAppBanners200ResponseAnyOfBuilder result,
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
                BuiltList, [FullType(GetAppBanners200ResponseAnyOfItemsInner)]),
          ) as BuiltList<GetAppBanners200ResponseAnyOfItemsInner>;
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
  GetAppBanners200ResponseAnyOf deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAppBanners200ResponseAnyOfBuilder();
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
