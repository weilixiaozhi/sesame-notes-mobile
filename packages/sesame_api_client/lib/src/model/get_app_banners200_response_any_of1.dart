//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_app_banners200_response_any_of1_items_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_app_banners200_response_any_of1.g.dart';

/// GetAppBanners200ResponseAnyOf1
///
/// Properties:
/// * [items]
@BuiltValue()
abstract class GetAppBanners200ResponseAnyOf1
    implements
        Built<GetAppBanners200ResponseAnyOf1,
            GetAppBanners200ResponseAnyOf1Builder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<GetAppBanners200ResponseAnyOf1ItemsInner> get items;

  GetAppBanners200ResponseAnyOf1._();

  factory GetAppBanners200ResponseAnyOf1(
          [void updates(GetAppBanners200ResponseAnyOf1Builder b)]) =
      _$GetAppBanners200ResponseAnyOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetAppBanners200ResponseAnyOf1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetAppBanners200ResponseAnyOf1> get serializer =>
      _$GetAppBanners200ResponseAnyOf1Serializer();
}

class _$GetAppBanners200ResponseAnyOf1Serializer
    implements PrimitiveSerializer<GetAppBanners200ResponseAnyOf1> {
  @override
  final Iterable<Type> types = const [
    GetAppBanners200ResponseAnyOf1,
    _$GetAppBanners200ResponseAnyOf1
  ];

  @override
  final String wireName = r'GetAppBanners200ResponseAnyOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetAppBanners200ResponseAnyOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(
          BuiltList, [FullType(GetAppBanners200ResponseAnyOf1ItemsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetAppBanners200ResponseAnyOf1 object, {
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
    required GetAppBanners200ResponseAnyOf1Builder result,
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
                [FullType(GetAppBanners200ResponseAnyOf1ItemsInner)]),
          ) as BuiltList<GetAppBanners200ResponseAnyOf1ItemsInner>;
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
  GetAppBanners200ResponseAnyOf1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetAppBanners200ResponseAnyOf1Builder();
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
