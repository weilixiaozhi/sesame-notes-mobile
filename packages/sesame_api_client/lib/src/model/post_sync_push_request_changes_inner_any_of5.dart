//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of5_any_of.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of5_any_of1.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner_any_of5.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf5
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
abstract class PostSyncPushRequestChangesInnerAnyOf5
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf5,
            PostSyncPushRequestChangesInnerAnyOf5Builder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOf5AnyOf], [PostSyncPushRequestChangesInnerAnyOf5AnyOf1]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInnerAnyOf5._();

  factory PostSyncPushRequestChangesInnerAnyOf5(
          [void updates(PostSyncPushRequestChangesInnerAnyOf5Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf5;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf5Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf5> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOf5Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf5Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf5> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf5,
    _$PostSyncPushRequestChangesInnerAnyOf5
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf5';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf5 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf5 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf5 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf5Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOf5AnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOf5AnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'member')
  static const PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum member =
      _$postSyncPushRequestChangesInnerAnyOf5EntityTypeEnum_member;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf5EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOf5EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf5EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf5EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf5ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOf5ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOf5ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf5ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf5ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf5ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf5ActionEnum> get values =>
      _$postSyncPushRequestChangesInnerAnyOf5ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf5ActionEnum valueOf(String name) =>
      _$postSyncPushRequestChangesInnerAnyOf5ActionEnumValueOf(name);
}
