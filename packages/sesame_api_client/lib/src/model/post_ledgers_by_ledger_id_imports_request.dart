//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_categories_request.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_transactions_request.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_imports_request.g.dart';

/// PostLedgersByLedgerIdImportsRequest
///
/// Properties:
/// * [categories]
/// * [transactions]
@BuiltValue()
abstract class PostLedgersByLedgerIdImportsRequest
    implements
        Built<PostLedgersByLedgerIdImportsRequest,
            PostLedgersByLedgerIdImportsRequestBuilder> {
  @BuiltValueField(wireName: r'categories')
  BuiltList<PostLedgersByLedgerIdCategoriesRequest>? get categories;

  @BuiltValueField(wireName: r'transactions')
  BuiltList<PostLedgersByLedgerIdTransactionsRequest>? get transactions;

  PostLedgersByLedgerIdImportsRequest._();

  factory PostLedgersByLedgerIdImportsRequest(
          [void updates(PostLedgersByLedgerIdImportsRequestBuilder b)]) =
      _$PostLedgersByLedgerIdImportsRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PostLedgersByLedgerIdImportsRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdImportsRequest> get serializer =>
      _$PostLedgersByLedgerIdImportsRequestSerializer();
}

class _$PostLedgersByLedgerIdImportsRequestSerializer
    implements PrimitiveSerializer<PostLedgersByLedgerIdImportsRequest> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdImportsRequest,
    _$PostLedgersByLedgerIdImportsRequest
  ];

  @override
  final String wireName = r'PostLedgersByLedgerIdImportsRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdImportsRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.categories != null) {
      yield r'categories';
      yield serializers.serialize(
        object.categories,
        specifiedType: const FullType(
            BuiltList, [FullType(PostLedgersByLedgerIdCategoriesRequest)]),
      );
    }
    if (object.transactions != null) {
      yield r'transactions';
      yield serializers.serialize(
        object.transactions,
        specifiedType: const FullType(
            BuiltList, [FullType(PostLedgersByLedgerIdTransactionsRequest)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdImportsRequest object, {
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
    required PostLedgersByLedgerIdImportsRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'categories':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltList, [FullType(PostLedgersByLedgerIdCategoriesRequest)]),
          ) as BuiltList<PostLedgersByLedgerIdCategoriesRequest>?;
          if (valueDes == null) continue;
          result.categories.replace(valueDes);
          break;
        case r'transactions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(BuiltList,
                [FullType(PostLedgersByLedgerIdTransactionsRequest)]),
          ) as BuiltList<PostLedgersByLedgerIdTransactionsRequest>?;
          if (valueDes == null) continue;
          result.transactions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdImportsRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdImportsRequestBuilder();
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
