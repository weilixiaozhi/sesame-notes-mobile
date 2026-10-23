//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of15_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of15_any_of1.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of9_any_of1_payload.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner_any_of15.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf15
///
/// Properties:
/// * [mutationId]
/// * [entityType]
/// * [entityId]
/// * [ledgerId]
/// * [dayBookId]
/// * [memoBookId]
/// * [fitnessSpaceId]
/// * [syncId]
/// * [baseRevision]
/// * [updatedAt]
/// * [action]
/// * [payload]
/// * [deletedAt]
@BuiltValue()
abstract class PostSyncPushRequestChangesInnerAnyOf15
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf15,
            PostSyncPushRequestChangesInnerAnyOf15Builder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOf15AnyOf], [PostSyncPushRequestChangesInnerAnyOf15AnyOf1]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInnerAnyOf15._();

  factory PostSyncPushRequestChangesInnerAnyOf15(
          [void updates(PostSyncPushRequestChangesInnerAnyOf15Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf15;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf15Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf15> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOf15Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf15Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf15> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf15,
    _$PostSyncPushRequestChangesInnerAnyOf15
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf15';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf15 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf15 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf15 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf15Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOf15AnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOf15AnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness_space')
  static const PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum
      fitnessSpace =
      _$postSyncPushRequestChangesInnerAnyOf15EntityTypeEnum_fitnessSpace;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf15EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf15EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf15EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf15EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf15ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOf15ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOf15ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf15ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf15ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf15ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf15ActionEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOf15ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf15ActionEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf15ActionEnumValueOf(name);
}
