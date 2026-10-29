//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/list_admin_banner_targets200_response_items_inner_name.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'list_admin_banner_targets200_response_items_inner.g.dart';

/// ListAdminBannerTargets200ResponseItemsInner
///
/// Properties:
/// * [id]
/// * [name]
@BuiltValue()
abstract class ListAdminBannerTargets200ResponseItemsInner
    implements
        Built<ListAdminBannerTargets200ResponseItemsInner,
            ListAdminBannerTargets200ResponseItemsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  ListAdminBannerTargets200ResponseItemsInnerName get name;

  ListAdminBannerTargets200ResponseItemsInner._();

  factory ListAdminBannerTargets200ResponseItemsInner(
          [void updates(
              ListAdminBannerTargets200ResponseItemsInnerBuilder b)]) =
      _$ListAdminBannerTargets200ResponseItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListAdminBannerTargets200ResponseItemsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListAdminBannerTargets200ResponseItemsInner>
      get serializer =>
          _$ListAdminBannerTargets200ResponseItemsInnerSerializer();
}

class _$ListAdminBannerTargets200ResponseItemsInnerSerializer
    implements
        PrimitiveSerializer<ListAdminBannerTargets200ResponseItemsInner> {
  @override
  final Iterable<Type> types = const [
    ListAdminBannerTargets200ResponseItemsInner,
    _$ListAdminBannerTargets200ResponseItemsInner
  ];

  @override
  final String wireName = r'ListAdminBannerTargets200ResponseItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListAdminBannerTargets200ResponseItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType:
          const FullType(ListAdminBannerTargets200ResponseItemsInnerName),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListAdminBannerTargets200ResponseItemsInner object, {
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
    required ListAdminBannerTargets200ResponseItemsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(ListAdminBannerTargets200ResponseItemsInnerName),
          ) as ListAdminBannerTargets200ResponseItemsInnerName;
          result.name.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListAdminBannerTargets200ResponseItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListAdminBannerTargets200ResponseItemsInnerBuilder();
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
