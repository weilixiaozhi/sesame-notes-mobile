//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of9_any_of1.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of9_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of9_any_of1_payload.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner_any_of9.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf9
///
/// Properties:
/// * [mutationId]
/// * [entityType]
/// * [entityId]
/// * [ledgerId]
/// * [dayBookId]
/// * [memoBookId]
/// * [syncId]
/// * [baseRevision]
/// * [updatedAt]
/// * [action]
/// * [payload]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf9
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf9,
            PostSyncPushRequestChangesInnerAnyOf9Builder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOf9AnyOf], [PostSyncPushRequestChangesInnerAnyOf9AnyOf1]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInnerAnyOf9._();

  factory PostSyncPushRequestChangesInnerAnyOf9(
          [void updates(PostSyncPushRequestChangesInnerAnyOf9Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf9;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf9Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf9> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOf9Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf9Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf9> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf9,
    _$PostSyncPushRequestChangesInnerAnyOf9
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf9';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf9 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf9 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf9 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf9Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOf9AnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOf9AnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'memo_book')
  static const PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum memoBook =
      _$postSyncPushRequestChangesInnerAnyOf9EntityTypeEnum_memoBook;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf9EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOf9EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf9EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf9EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf9ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOf9ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOf9ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf9ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf9ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf9ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf9ActionEnum> get values =>
      _$postSyncPushRequestChangesInnerAnyOf9ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf9ActionEnum valueOf(String name) =>
      _$postSyncPushRequestChangesInnerAnyOf9ActionEnumValueOf(name);
}
