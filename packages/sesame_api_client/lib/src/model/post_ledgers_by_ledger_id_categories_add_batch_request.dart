//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_categories_add_batch_request_any_of_items_inner.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_categories_add_batch_request_any_of.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_categories_add_batch_request_any_of1.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'post_ledgers_by_ledger_id_categories_add_batch_request.g.dart';

/// PostLedgersByLedgerIdCategoriesAddBatchRequest
///
/// Properties:
/// * [items]
/// * [initializeDefaults]
@BuiltValue()
abstract class PostLedgersByLedgerIdCategoriesAddBatchRequest
    implements
        Built<PostLedgersByLedgerIdCategoriesAddBatchRequest,
            PostLedgersByLedgerIdCategoriesAddBatchRequestBuilder> {
  /// Any Of [PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf], [PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1]
  AnyOf get anyOf;

  PostLedgersByLedgerIdCategoriesAddBatchRequest._();

  factory PostLedgersByLedgerIdCategoriesAddBatchRequest(
          [void updates(
              PostLedgersByLedgerIdCategoriesAddBatchRequestBuilder b)]) =
      _$PostLedgersByLedgerIdCategoriesAddBatchRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostLedgersByLedgerIdCategoriesAddBatchRequestBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdCategoriesAddBatchRequest>
      get serializer =>
          _$PostLedgersByLedgerIdCategoriesAddBatchRequestSerializer();
}

class _$PostLedgersByLedgerIdCategoriesAddBatchRequestSerializer
    implements
        PrimitiveSerializer<PostLedgersByLedgerIdCategoriesAddBatchRequest> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdCategoriesAddBatchRequest,
    _$PostLedgersByLedgerIdCategoriesAddBatchRequest
  ];

  @override
  final String wireName = r'PostLedgersByLedgerIdCategoriesAddBatchRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesAddBatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {}

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesAddBatchRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf,
        specifiedType: FullType(
            AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PostLedgersByLedgerIdCategoriesAddBatchRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdCategoriesAddBatchRequestBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [
      FullType(PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf),
      FullType(PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1),
    ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc,
        specifiedType: targetType) as AnyOf;
    return result.build();
  }
}
