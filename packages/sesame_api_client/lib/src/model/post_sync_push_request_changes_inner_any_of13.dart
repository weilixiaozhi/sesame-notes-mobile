//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of13_any_of.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of13_any_of1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner_any_of13.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf13
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
abstract class PostSyncPushRequestChangesInnerAnyOf13
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf13,
            PostSyncPushRequestChangesInnerAnyOf13Builder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOf13AnyOf], [PostSyncPushRequestChangesInnerAnyOf13AnyOf1]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInnerAnyOf13._();

  factory PostSyncPushRequestChangesInnerAnyOf13(
          [void updates(PostSyncPushRequestChangesInnerAnyOf13Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf13;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf13Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf13> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOf13Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf13Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf13> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf13,
    _$PostSyncPushRequestChangesInnerAnyOf13
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf13';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf13 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf13 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf13 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf13Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOf13AnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOf13AnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness_workout')
  static const PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum
      fitnessWorkout =
      _$postSyncPushRequestChangesInnerAnyOf13EntityTypeEnum_fitnessWorkout;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf13EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf13EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf13EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf13EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf13ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOf13ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOf13ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf13ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf13ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf13ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf13ActionEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOf13ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf13ActionEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf13ActionEnumValueOf(name);
}
