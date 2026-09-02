//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of1_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of1_any_of1.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner_any_of1.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf1
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
abstract class PostSyncPushRequestChangesInnerAnyOf1
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf1,
            PostSyncPushRequestChangesInnerAnyOf1Builder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOf1AnyOf], [PostSyncPushRequestChangesInnerAnyOf1AnyOf1]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInnerAnyOf1._();

  factory PostSyncPushRequestChangesInnerAnyOf1(
          [void updates(PostSyncPushRequestChangesInnerAnyOf1Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf1Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf1> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOf1Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf1Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf1> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf1,
    _$PostSyncPushRequestChangesInnerAnyOf1
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf1Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOf1AnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOf1AnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'transaction')
  static const PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum transaction =
      _$postSyncPushRequestChangesInnerAnyOf1EntityTypeEnum_transaction;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf1EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOf1EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf1EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf1EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf1ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOf1ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOf1ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf1ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf1ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf1ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf1ActionEnum> get values =>
      _$postSyncPushRequestChangesInnerAnyOf1ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf1ActionEnum valueOf(String name) =>
      _$postSyncPushRequestChangesInnerAnyOf1ActionEnumValueOf(name);
}
