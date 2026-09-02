//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of3_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of3_any_of1.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner_any_of3.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf3
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
abstract class PostSyncPushRequestChangesInnerAnyOf3
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf3,
            PostSyncPushRequestChangesInnerAnyOf3Builder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOf3AnyOf], [PostSyncPushRequestChangesInnerAnyOf3AnyOf1]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInnerAnyOf3._();

  factory PostSyncPushRequestChangesInnerAnyOf3(
          [void updates(PostSyncPushRequestChangesInnerAnyOf3Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf3;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf3Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf3> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOf3Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf3Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf3> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf3,
    _$PostSyncPushRequestChangesInnerAnyOf3
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf3';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf3 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf3 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf3 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf3Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOf3AnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOf3AnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'recurring_transaction')
  static const PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum
      recurringTransaction =
      _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnum_recurringTransaction;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf3EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf3EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf3ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOf3ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOf3ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf3ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf3ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf3ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf3ActionEnum> get values =>
      _$postSyncPushRequestChangesInnerAnyOf3ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf3ActionEnum valueOf(String name) =>
      _$postSyncPushRequestChangesInnerAnyOf3ActionEnumValueOf(name);
}
