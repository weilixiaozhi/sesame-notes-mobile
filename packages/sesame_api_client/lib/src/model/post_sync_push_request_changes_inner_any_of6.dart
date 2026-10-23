//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of6_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of6_any_of1.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner_any_of6.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf6
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
abstract class PostSyncPushRequestChangesInnerAnyOf6
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf6,
            PostSyncPushRequestChangesInnerAnyOf6Builder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOf6AnyOf], [PostSyncPushRequestChangesInnerAnyOf6AnyOf1]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInnerAnyOf6._();

  factory PostSyncPushRequestChangesInnerAnyOf6(
          [void updates(PostSyncPushRequestChangesInnerAnyOf6Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf6;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf6Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf6> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOf6Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf6Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf6> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf6,
    _$PostSyncPushRequestChangesInnerAnyOf6
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf6';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf6 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf6 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf6 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf6Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOf6AnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOf6AnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'recurring_transaction')
  static const PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum
      recurringTransaction =
      _$postSyncPushRequestChangesInnerAnyOf6EntityTypeEnum_recurringTransaction;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf6EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOf6EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf6EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf6EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf6ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOf6ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOf6ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf6ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf6ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf6ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf6ActionEnum> get values =>
      _$postSyncPushRequestChangesInnerAnyOf6ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf6ActionEnum valueOf(String name) =>
      _$postSyncPushRequestChangesInnerAnyOf6ActionEnumValueOf(name);
}
