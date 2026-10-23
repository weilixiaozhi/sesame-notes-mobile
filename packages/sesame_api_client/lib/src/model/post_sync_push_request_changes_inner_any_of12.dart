//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of12_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of12_any_of1.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner_any_of12.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf12
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
abstract class PostSyncPushRequestChangesInnerAnyOf12
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf12,
            PostSyncPushRequestChangesInnerAnyOf12Builder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOf12AnyOf], [PostSyncPushRequestChangesInnerAnyOf12AnyOf1]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInnerAnyOf12._();

  factory PostSyncPushRequestChangesInnerAnyOf12(
          [void updates(PostSyncPushRequestChangesInnerAnyOf12Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf12;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf12Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf12> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOf12Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf12Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf12> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf12,
    _$PostSyncPushRequestChangesInnerAnyOf12
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf12';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf12 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf12 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf12 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf12Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOf12AnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOf12AnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness_plan')
  static const PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum
      fitnessPlan =
      _$postSyncPushRequestChangesInnerAnyOf12EntityTypeEnum_fitnessPlan;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf12EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf12EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf12EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf12EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf12ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOf12ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOf12ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf12ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf12ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf12ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf12ActionEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOf12ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf12ActionEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf12ActionEnumValueOf(name);
}
