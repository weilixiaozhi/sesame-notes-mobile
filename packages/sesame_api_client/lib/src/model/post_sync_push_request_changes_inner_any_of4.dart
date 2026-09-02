//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of4_any_of.dart';
import 'package:sesame_api_client/src/model/post_sync_push_request_changes_inner_any_of4_any_of1.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_sync_push_request_changes_inner_any_of4.g.dart';

/// PostSyncPushRequestChangesInnerAnyOf4
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
abstract class PostSyncPushRequestChangesInnerAnyOf4
    implements
        Built<PostSyncPushRequestChangesInnerAnyOf4,
            PostSyncPushRequestChangesInnerAnyOf4Builder> {
  /// Any Of [PostSyncPushRequestChangesInnerAnyOf4AnyOf], [PostSyncPushRequestChangesInnerAnyOf4AnyOf1]
  AnyOf get anyOf;

  PostSyncPushRequestChangesInnerAnyOf4._();

  factory PostSyncPushRequestChangesInnerAnyOf4(
          [void updates(PostSyncPushRequestChangesInnerAnyOf4Builder b)]) =
      _$PostSyncPushRequestChangesInnerAnyOf4;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostSyncPushRequestChangesInnerAnyOf4Builder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostSyncPushRequestChangesInnerAnyOf4> get serializer =>
      _$PostSyncPushRequestChangesInnerAnyOf4Serializer();
}

class _$PostSyncPushRequestChangesInnerAnyOf4Serializer
    implements PrimitiveSerializer<PostSyncPushRequestChangesInnerAnyOf4> {
  @override
  final Iterable<Type> types = const [
    PostSyncPushRequestChangesInnerAnyOf4,
    _$PostSyncPushRequestChangesInnerAnyOf4
  ];

  @override
  final String wireName = r'PostSyncPushRequestChangesInnerAnyOf4';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf4 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostSyncPushRequestChangesInnerAnyOf4 object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf4 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostSyncPushRequestChangesInnerAnyOf4Builder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostSyncPushRequestChangesInnerAnyOf4AnyOf),
      FullType(PostSyncPushRequestChangesInnerAnyOf4AnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

class PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'exchange_rate_override')
  static const PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum
      exchangeRateOverride =
      _$postSyncPushRequestChangesInnerAnyOf4EntityTypeEnum_exchangeRateOverride;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf4EntityTypeEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum>
      get values => _$postSyncPushRequestChangesInnerAnyOf4EntityTypeEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf4EntityTypeEnum valueOf(
          String name) =>
      _$postSyncPushRequestChangesInnerAnyOf4EntityTypeEnumValueOf(name);
}

class PostSyncPushRequestChangesInnerAnyOf4ActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'delete')
  static const PostSyncPushRequestChangesInnerAnyOf4ActionEnum delete =
      _$postSyncPushRequestChangesInnerAnyOf4ActionEnum_delete;

  static Serializer<PostSyncPushRequestChangesInnerAnyOf4ActionEnum>
      get serializer =>
          _$postSyncPushRequestChangesInnerAnyOf4ActionEnumSerializer;

  const PostSyncPushRequestChangesInnerAnyOf4ActionEnum._(String name)
      : super(name);

  static BuiltSet<PostSyncPushRequestChangesInnerAnyOf4ActionEnum> get values =>
      _$postSyncPushRequestChangesInnerAnyOf4ActionEnumValues;
  static PostSyncPushRequestChangesInnerAnyOf4ActionEnum valueOf(String name) =>
      _$postSyncPushRequestChangesInnerAnyOf4ActionEnumValueOf(name);
}
