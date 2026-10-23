//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of9.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of8.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of9_any_of1_payload.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of3.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of14.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of6.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of11.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of4.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of12.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of7.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of1.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of13.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of5.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of10.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of15.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of2.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner.g.dart';

/// PostSyncPushRequestChangesInner
///
/// Properties:
/// * [mutationId]
/// * [entityType]
/// * [entityId]
/// * [ledgerId]
/// * [dayBookId]
/// * [syncId]
/// * [baseRevision]
/// * [updatedAt]
/// * [action]
/// * [payload]
/// * [memoBookId]
/// * [fitnessSpaceId]
/// * [deletedAt]
@BuiltValue()
abstract class PostSyncPushRequestChangesInner
    implements
        Built<PostSyncPushRequestChangesInner,
            PostSyncPushRequestChangesInnerBuilder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOf], [PostSyncPushRequestChangesInnerAnyOf1], [PostSyncPushRequestChangesInnerAnyOf10], [PostSyncPushRequestChangesInnerAnyOf11], [PostSyncPushRequestChangesInnerAnyOf12], [PostSyncPushRequestChangesInnerAnyOf13], [PostSyncPushRequestChangesInnerAnyOf14], [PostSyncPushRequestChangesInnerAnyOf15], [PostSyncPushRequestChangesInnerAnyOf2], [PostSyncPushRequestChangesInnerAnyOf3], [PostSyncPushRequestChangesInnerAnyOf4], [PostSyncPushRequestChangesInnerAnyOf5], [PostSyncPushRequestChangesInnerAnyOf6], [PostSyncPushRequestChangesInnerAnyOf7], [PostSyncPushRequestChangesInnerAnyOf8], [PostSyncPushRequestChangesInnerAnyOf9]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInner._();

  factory PostSyncPushRequestChangesInner(
          [void updates(PostSyncPushRequestChangesInnerBuilder b)]) =
      _$PostSyncPushRequestChangesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInner> get serializer =>
      _$PostSyncPushRequestChangesInnerSerializer();
}

class _$PostSyncPushRequestChangesInnerSerializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInner> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInner,
    _$PostSyncPushRequestChangesInner
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOf1),
      FullType(PostSyncPushRequestChangesInnerAnyOf2),
      FullType(PostSyncPushRequestChangesInnerAnyOf3),
      FullType(PostSyncPushRequestChangesInnerAnyOf4),
      FullType(PostSyncPushRequestChangesInnerAnyOf5),
      FullType(PostSyncPushRequestChangesInnerAnyOf6),
      FullType(PostSyncPushRequestChangesInnerAnyOf7),
      FullType(PostSyncPushRequestChangesInnerAnyOf8),
      FullType(PostSyncPushRequestChangesInnerAnyOf9),
      FullType(PostSyncPushRequestChangesInnerAnyOf10),
      FullType(PostSyncPushRequestChangesInnerAnyOf11),
      FullType(PostSyncPushRequestChangesInnerAnyOf12),
      FullType(PostSyncPushRequestChangesInnerAnyOf13),
      FullType(PostSyncPushRequestChangesInnerAnyOf14),
      FullType(PostSyncPushRequestChangesInnerAnyOf15),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerEntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness_space')
  static const PostSyncPushRequestChangesInnerEntityTypeEnum fitnessSpace =
      _$postSyncPushRequestChangesInnerEntityTypeEnum_fitnessSpace;

  static Serializer<PostSyncPushRequestChangesInnerEntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerEntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerEntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerEntityTypeEnum> get values =>
      _$postSyncPushRequestChangesInnerEntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerEntityTypeEnum valueOf(String name) =>
      _$postSyncPushRequestChangesInnerEntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerActionEnum delete =
      _$postSyncPushRequestChangesInnerActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerActionEnum> get serializer =>
      _$postSyncPushRequestChangesInnerActionEnumSerializer;

  const PostSyncPushRequestChangesInnerActionEnum._(String name) : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerActionEnum> get values =>
      _$postSyncPushRequestChangesInnerActionEnumValues;
  static PostSyncPushRequestChangesInnerActionEnum valueOf(String name) =>
      _$postSyncPushRequestChangesInnerActionEnumValueOf(name);
}
