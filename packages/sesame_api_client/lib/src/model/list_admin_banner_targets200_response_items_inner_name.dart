//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_admin_banner_targets200_response_items_inner_name.g.dart';

/// ListAdminBannerTargets200ResponseItemsInnerName
///
/// Properties:
/// * [zh]
/// * [zhHant]
/// * [en]
@BuiltValue()
abstract class ListAdminBannerTargets200ResponseItemsInnerName
    implements
        Built<ListAdminBannerTargets200ResponseItemsInnerName,
            ListAdminBannerTargets200ResponseItemsInnerNameBuilder> {
  @BuiltValueField(wireName: r'zh')
  String get zh;

  @BuiltValueField(wireName: r'zh_hant')
  String get zhHant;

  @BuiltValueField(wireName: r'en')
  String get en;

  ListAdminBannerTargets200ResponseItemsInnerName._();

  factory ListAdminBannerTargets200ResponseItemsInnerName(
          [void updates(
              ListAdminBannerTargets200ResponseItemsInnerNameBuilder b)]) =
      _$ListAdminBannerTargets200ResponseItemsInnerName;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          ListAdminBannerTargets200ResponseItemsInnerNameBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListAdminBannerTargets200ResponseItemsInnerName>
      get serializer =>
          _$ListAdminBannerTargets200ResponseItemsInnerNameSerializer();
}

class _$ListAdminBannerTargets200ResponseItemsInnerNameSerializer
    implements
        PrimitiveSerializer<ListAdminBannerTargets200ResponseItemsInnerName> {
  @override
  final Iterable<Type> types = const [
    ListAdminBannerTargets200ResponseItemsInnerName,
    _$ListAdminBannerTargets200ResponseItemsInnerName
  ];

  @override
  final String wireName = r'ListAdminBannerTargets200ResponseItemsInnerName';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListAdminBannerTargets200ResponseItemsInnerName object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'zh';
    yield serializers.serialize(
      object.zh,
      specifiedType: const FullType(String),
    );
    yield r'zh_hant';
    yield serializers.serialize(
      object.zhHant,
      specifiedType: const FullType(String),
    );
    yield r'en';
    yield serializers.serialize(
      object.en,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListAdminBannerTargets200ResponseItemsInnerName object, {
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
    required ListAdminBannerTargets200ResponseItemsInnerNameBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'zh':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.zh = valueDes;
          break;
        case r'zh_hant':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.zhHant = valueDes;
          break;
        case r'en':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.en = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListAdminBannerTargets200ResponseItemsInnerName deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListAdminBannerTargets200ResponseItemsInnerNameBuilder();
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
