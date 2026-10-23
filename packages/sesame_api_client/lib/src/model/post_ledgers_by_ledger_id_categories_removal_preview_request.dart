//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_categories_removal_preview_request.g.dart';

/// PostLedgersByLedgerIdCategoriesRemovalPreviewRequest
///
/// Properties:
/// * [categoryIds]
@BuiltValue()
abstract class PostLedgersByLedgerIdCategoriesRemovalPreviewRequest
    implements
        Built<PostLedgersByLedgerIdCategoriesRemovalPreviewRequest,
            PostLedgersByLedgerIdCategoriesRemovalPreviewRequestBuilder> {
  @BuiltValueField(wireName: r'category_ids')
  BuiltSet<String> get categoryIds;

  PostLedgersByLedgerIdCategoriesRemovalPreviewRequest._();

  factory PostLedgersByLedgerIdCategoriesRemovalPreviewRequest(
          [void updates(
              PostLedgersByLedgerIdCategoriesRemovalPreviewRequestBuilder b)]) =
      _$PostLedgersByLedgerIdCategoriesRemovalPreviewRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostLedgersByLedgerIdCategoriesRemovalPreviewRequestBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdCategoriesRemovalPreviewRequest>
      get serializer =>
          _$PostLedgersByLedgerIdCategoriesRemovalPreviewRequestSerializer();
}

class _$PostLedgersByLedgerIdCategoriesRemovalPreviewRequestSerializer
    implements
        PrimitiveSerializer<
            PostLedgersByLedgerIdCategoriesRemovalPreviewRequest> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdCategoriesRemovalPreviewRequest,
    _$PostLedgersByLedgerIdCategoriesRemovalPreviewRequest
  ];

  @override
  final String wireName =
      r'PostLedgersByLedgerIdCategoriesRemovalPreviewRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesRemovalPreviewRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'category_ids';
    yield serializers.serialize(
      object.categoryIds,
      specifiedType: const FullType(BuiltSet, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesRemovalPreviewRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object,
            specifiedType: specifiedType)
        .toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PostLedgersByLedgerIdCategoriesRemovalPreviewRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'category_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltSet, [FullType(String)]),
          ) as BuiltSet<String>;
          result.categoryIds.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdCategoriesRemovalPreviewRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostLedgersByLedgerIdCategoriesRemovalPreviewRequestBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}
