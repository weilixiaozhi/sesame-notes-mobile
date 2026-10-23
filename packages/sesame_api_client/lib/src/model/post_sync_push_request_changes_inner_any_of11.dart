//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of11_any_of1.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of11_any_of.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner_any_of11.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf11
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
abstract class PostSyncPushRequestChangesInnerAnyOf11
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf11,
            PostSyncPushRequestChangesInnerAnyOf11Builder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOf11AnyOf], [PostSyncPushRequestChangesInnerAnyOf11AnyOf1]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInnerAnyOf11._();

  factory PostSyncPushRequestChangesInnerAnyOf11(
          [void updates(PostSyncPushRequestChangesInnerAnyOf11Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf11;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf11Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf11> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOf11Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf11Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf11> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf11,
    _$PostSyncPushRequestChangesInnerAnyOf11
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf11';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf11 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf11 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf11 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf11Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOf11AnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOf11AnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'fitness_template')
  static const PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum
      fitnessTemplate =
      _$postSyncPushRequestChangesInnerAnyOf11EntityTypeEnum_fitnessTemplate;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf11EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum>
      get values =>
          _$postSyncPushRequestChangesInnerAnyOf11EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf11EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf11EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf11ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOf11ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOf11ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf11ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf11ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf11ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf11ActionEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOf11ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf11ActionEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf11ActionEnumValueOf(name);
}
