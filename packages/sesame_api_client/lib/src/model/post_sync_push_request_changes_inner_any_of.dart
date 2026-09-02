//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of_any_of1.dart';
import 'package:built_value/json_object.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of_any_of.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner_any_of.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf
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
abstract class PostSyncPushRequestChangesInnerAnyOf
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf,
            PostSyncPushRequestChangesInnerAnyOfBuilder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOfAnyOf], [PostSyncPushRequestChangesInnerAnyOfAnyOf1]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInnerAnyOf._();

  factory PostSyncPushRequestChangesInnerAnyOf(
          [void updates(PostSyncPushRequestChangesInnerAnyOfBuilder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOfBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOfSerializer();
}

class _$PostSyncPushRequestChangesInnerAnyOfSerializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf,
    _$PostSyncPushRequestChangesInnerAnyOf
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOfBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOfAnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOfAnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ledger')
  static const PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum ledger =
      _$postSyncPushRequestChangesInnerAnyOfEntityTypeEnum_ledger;

  static Serializer<PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOfEntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOfEntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOfEntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOfEntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOfActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOfActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOfActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOfActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOfActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOfActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOfActionEnum> get values =>
      _$postSyncPushRequestChangesInnerAnyOfActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOfActionEnum valueOf(String name) =>
      _$postSyncPushRequestChangesInnerAnyOfActionEnumValueOf(name);
}
