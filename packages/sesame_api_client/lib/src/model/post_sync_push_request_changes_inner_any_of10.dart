//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of10_any_of1.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of10_any_of.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner_any_of10.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf10
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
abstract class PostSyncPushRequestChangesInnerAnyOf10
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf10,
            PostSyncPushRequestChangesInnerAnyOf10Builder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOf10AnyOf], [PostSyncPushRequestChangesInnerAnyOf10AnyOf1]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInnerAnyOf10._();

  factory PostSyncPushRequestChangesInnerAnyOf10(
          [void updates(PostSyncPushRequestChangesInnerAnyOf10Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf10;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf10Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf10> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOf10Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf10Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf10> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf10,
    _$PostSyncPushRequestChangesInnerAnyOf10
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf10';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf10 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf10 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf10 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf10Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOf10AnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOf10AnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'memo_entry')
  static const PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum memoEntry =
      _$postSyncPushRequestChangesInnerAnyOf10EntityTypeEnum_memoEntry;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf10EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf10EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf10EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf10EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf10ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOf10ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOf10ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf10ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf10ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf10ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf10ActionEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOf10ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf10ActionEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf10ActionEnumValueOf(name);
}
