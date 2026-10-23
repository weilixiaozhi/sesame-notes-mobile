//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of8_any_of1.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of8_any_of.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner_any_of8.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf8
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
abstract class PostSyncPushRequestChangesInnerAnyOf8
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf8,
            PostSyncPushRequestChangesInnerAnyOf8Builder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOf8AnyOf], [PostSyncPushRequestChangesInnerAnyOf8AnyOf1]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInnerAnyOf8._();

  factory PostSyncPushRequestChangesInnerAnyOf8(
          [void updates(PostSyncPushRequestChangesInnerAnyOf8Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf8;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf8Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf8> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOf8Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf8Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf8> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf8,
    _$PostSyncPushRequestChangesInnerAnyOf8
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf8';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf8 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf8 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf8 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf8Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOf8AnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOf8AnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'member')
  static const PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum member =
      _$postSyncPushRequestChangesInnerAnyOf8EntityTypeEnum_member;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf8EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOf8EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf8EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf8EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf8ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOf8ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOf8ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf8ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf8ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf8ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf8ActionEnum> get values =>
      _$postSyncPushRequestChangesInnerAnyOf8ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf8ActionEnum valueOf(String name) =>
      _$postSyncPushRequestChangesInnerAnyOf8ActionEnumValueOf(name);
}
