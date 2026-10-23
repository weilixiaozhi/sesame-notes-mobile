//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of7_any_of1.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of7_any_of.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner_any_of7.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf7
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
abstract class PostSyncPushRequestChangesInnerAnyOf7
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf7,
            PostSyncPushRequestChangesInnerAnyOf7Builder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOf7AnyOf], [PostSyncPushRequestChangesInnerAnyOf7AnyOf1]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInnerAnyOf7._();

  factory PostSyncPushRequestChangesInnerAnyOf7(
          [void updates(PostSyncPushRequestChangesInnerAnyOf7Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf7;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf7Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf7> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOf7Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf7Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf7> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf7,
    _$PostSyncPushRequestChangesInnerAnyOf7
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf7';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf7 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf7 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf7 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf7Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOf7AnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOf7AnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'exchange_rate_override')
  static const PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum
      exchangeRateOverride =
      _$postSyncPushRequestChangesInnerAnyOf7EntityTypeEnum_exchangeRateOverride;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf7EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOf7EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf7EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf7EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf7ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOf7ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOf7ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf7ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf7ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf7ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf7ActionEnum> get values =>
      _$postSyncPushRequestChangesInnerAnyOf7ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf7ActionEnum valueOf(String name) =>
      _$postSyncPushRequestChangesInnerAnyOf7ActionEnumValueOf(name);
}
