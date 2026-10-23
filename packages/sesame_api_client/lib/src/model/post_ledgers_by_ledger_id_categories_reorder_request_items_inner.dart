//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_categories_reorder_request_items_inner.g.dart';

/// PostLedgersByLedgerIdCategoriesReorderRequestItemsInner
///
/// Properties:
/// * [id]
/// * [sortOrder]
/// * [expectedUpdatedAt]
@BuiltValue()
abstract class PostLedgersByLedgerIdCategoriesReorderRequestItemsInner
    implements
        Built<PostLedgersByLedgerIdCategoriesReorderRequestItemsInner,
            PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'sort_order')
  int get sortOrder;

  @BuiltValueField(wireName: r'expected_updated_at')
  DateTime get expectedUpdatedAt;

  PostLedgersByLedgerIdCategoriesReorderRequestItemsInner._();

  factory PostLedgersByLedgerIdCategoriesReorderRequestItemsInner(
      [void updates(
          PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerBuilder
              b)]) = _$PostLedgersByLedgerIdCategoriesReorderRequestItemsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdCategoriesReorderRequestItemsInner>
      get serializer =>
          _$PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerSerializer();
}

class _$PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerSerializer
    implements
        PrimitiveSerializer<
            PostLedgersByLedgerIdCategoriesReorderRequestItemsInner> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdCategoriesReorderRequestItemsInner,
    _$PostLedgersByLedgerIdCategoriesReorderRequestItemsInner
  ];

  @override
  final String wireName =
      r'PostLedgersByLedgerIdCategoriesReorderRequestItemsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesReorderRequestItemsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'sort_order';
    yield serializers.serialize(
      object.sortOrder,
      specifiedType: const FullType(int),
    );
    yield r'expected_updated_at';
    yield serializers.serialize(
      object.expectedUpdatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesReorderRequestItemsInner object, {
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
    required PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'sort_order':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.sortOrder = valueDes;
          break;
        case r'expected_updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expectedUpdatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdCategoriesReorderRequestItemsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostLedgersByLedgerIdCategoriesReorderRequestItemsInnerBuilder();
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
