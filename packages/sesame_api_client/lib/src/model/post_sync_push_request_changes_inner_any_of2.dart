//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of2_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of2_any_of1.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner_any_of2.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf2
///
/// Properties:
/// * [mutationId]
/// * [entityType]
/// * [entityId]
/// * [ledgerId]
/// * [syncId]
/// * [baseRevision]
/// * [action]
/// * [updatedAt]
/// * [payload]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf2
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf2,
            PostSyncPushRequestChangesInnerAnyOf2Builder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOf2AnyOf], [PostSyncPushRequestChangesInnerAnyOf2AnyOf1]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInnerAnyOf2._();

  factory PostSyncPushRequestChangesInnerAnyOf2(
          [void updates(PostSyncPushRequestChangesInnerAnyOf2Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf2;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf2Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf2> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOf2Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf2Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf2> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf2,
    _$PostSyncPushRequestChangesInnerAnyOf2
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf2';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf2 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf2 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf2 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf2Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOf2AnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOf2AnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'category')
  static const PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum category =
      _$postSyncPushRequestChangesInnerAnyOf2EntityTypeEnum_category;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf2EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOf2EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf2EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf2EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf2ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOf2ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOf2ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf2ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf2ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf2ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf2ActionEnum> get values =>
      _$postSyncPushRequestChangesInnerAnyOf2ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf2ActionEnum valueOf(String name) =>
      _$postSyncPushRequestChangesInnerAnyOf2ActionEnumValueOf(name);
}
