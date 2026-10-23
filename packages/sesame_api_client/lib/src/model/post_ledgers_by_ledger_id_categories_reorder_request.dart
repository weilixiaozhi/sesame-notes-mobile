//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_categories_reorder_request_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_categories_reorder_request.g.dart';

/// PostLedgersByLedgerIdCategoriesReorderRequest
///
/// Properties:
/// * [items]
@BuiltValue()
abstract class PostLedgersByLedgerIdCategoriesReorderRequest
    implements
        Built<PostLedgersByLedgerIdCategoriesReorderRequest,
            PostLedgersByLedgerIdCategoriesReorderRequestBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<PostLedgersByLedgerIdCategoriesReorderRequestItemsInner> get items;

  PostLedgersByLedgerIdCategoriesReorderRequest._();

  factory PostLedgersByLedgerIdCategoriesReorderRequest(
          [void updates(
              PostLedgersByLedgerIdCategoriesReorderRequestBuilder b)]) =
      _$PostLedgersByLedgerIdCategoriesReorderRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostLedgersByLedgerIdCategoriesReorderRequestBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdCategoriesReorderRequest>
      get serializer =>
          _$PostLedgersByLedgerIdCategoriesReorderRequestSerializer();
}

class _$PostLedgersByLedgerIdCategoriesReorderRequestSerializer
    implements
        PrimitiveSerializer<PostLedgersByLedgerIdCategoriesReorderRequest> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdCategoriesReorderRequest,
    _$PostLedgersByLedgerIdCategoriesReorderRequest
  ];

  @override
  final String wireName = r'PostLedgersByLedgerIdCategoriesReorderRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesReorderRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList,
          [FullType(PostLedgersByLedgerIdCategoriesReorderRequestItemsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesReorderRequest object, {
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
    required PostLedgersByLedgerIdCategoriesReorderRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(PostLedgersByLedgerIdCategoriesReorderRequestItemsInner)
            ]),
          ) as BuiltList<
              PostLedgersByLedgerIdCategoriesReorderRequestItemsInner>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdCategoriesReorderRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdCategoriesReorderRequestBuilder();
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
