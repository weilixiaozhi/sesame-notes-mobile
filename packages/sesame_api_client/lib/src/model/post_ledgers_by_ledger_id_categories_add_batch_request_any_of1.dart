//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_categories_add_batch_request_any_of_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_categories_add_batch_request_any_of1.g.dart';

/// PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1
///
/// Properties:
/// * [items]
/// * [initializeDefaults]
@BuiltValue()
abstract class PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1
    implements
        Built<PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1,
            PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Builder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner>
      get items;

  @BuiltValueField(wireName: r'initialize_defaults')
  bool get initializeDefaults;

  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1._();

  factory PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1(
          [void updates(
              PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Builder b)]) =
      _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Builder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1>
      get serializer =>
          _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Serializer();
}

class _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Serializer
    implements
        PrimitiveSerializer<
            PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1,
    _$PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1
  ];

  @override
  final String wireName =
      r'PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1 object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [
        FullType(PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner)
      ]),
    );
    yield r'initialize_defaults';
    yield serializers.serialize(
      object.initializeDefaults,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1 object, {
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
    required PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Builder result,
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
              FullType(
                  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner)
            ]),
          ) as BuiltList<
              PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOfItemsInner>;
          result.items.replace(valueDes);
          break;
        case r'initialize_defaults':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.initializeDefaults = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1 deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostLedgersByLedgerIdCategoriesAddBatchRequestAnyOf1Builder();
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
