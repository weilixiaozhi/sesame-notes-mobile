//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_sync_push_request_changes_inner_any_of11_any_of_payload_catalog_origin.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin
///
/// Properties:
/// * [source_]
/// * [itemId]
/// * [revision]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin,
            PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder> {
  @BuiltValueField(wireName: r'source')
  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum
      get source_;
  // enum source_Enum {  official,  };

  @BuiltValueField(wireName: r'item_id')
  String get itemId;

  @BuiltValueField(wireName: r'revision')
  int get revision;

  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin._();

  factory PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin(
          [void updates(
              PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder
                  b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin>
      get serializer =>
          _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSerializer
    implements
        PrimitiveSerializer<
            PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin,
    _$PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin
  ];

  @override
  final String wireName =
      r'PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum),
    );
    yield r'item_id';
    yield serializers.serialize(
      object.itemId,
      specifiedType: const FullType(String),
    );
    yield r'revision';
    yield serializers.serialize(
      object.revision,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin object, {
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
    required PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum),
          ) as PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum;
          result.source_ = valueDes;
          break;
        case r'item_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.itemId = valueDes;
          break;
        case r'revision':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.revision = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOrigin deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginBuilder();
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

class PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum
    extends EnumClass {
  @BuiltValueEnumConst(wireName: r'official')
  static const PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum
      official =
      _$postSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSourceEnum_official;

  static Serializer<
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSourceEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum._(
      String name)
      : super(name);

  static BuiltSet<
          PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSourceEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSource_Enum
      valueOf(String name) =>
          _$postSyncPushRequestChangesInnerAnyOf11AnyOfPayloadCatalogOriginSourceEnumValueOf(
              name);
}
