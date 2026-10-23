//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of14_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of14_any_of1.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner_any_of14.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf14
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
abstract class PostSyncPushRequestChangesInnerAnyOf14
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf14,
            PostSyncPushRequestChangesInnerAnyOf14Builder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOf14AnyOf], [PostSyncPushRequestChangesInnerAnyOf14AnyOf1]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInnerAnyOf14._();

  factory PostSyncPushRequestChangesInnerAnyOf14(
          [void updates(PostSyncPushRequestChangesInnerAnyOf14Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf14;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf14Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf14> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOf14Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf14Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf14> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf14,
    _$PostSyncPushRequestChangesInnerAnyOf14
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf14';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf14 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf14 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf14 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf14Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOf14AnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOf14AnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness_preferences')
  static const PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum
      fitnessPreferences =
      _$postSyncPushRequestChangesInnerAnyOf14EntityTypeEnum_fitnessPreferences;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf14EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf14EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf14EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf14EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf14ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOf14ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOf14ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf14ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf14ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf14ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf14ActionEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOf14ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf14ActionEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf14ActionEnumValueOf(name);
}
