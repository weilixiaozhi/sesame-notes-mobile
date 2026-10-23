//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/category.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_categories_removal_preview200_response.g.dart';

/// PostLedgersByLedgerIdCategoriesRemovalPreview200Response
///
/// Properties:
/// * [previewToken]
/// * [categories]
/// * [transactionCount]
/// * [recurringCount]
@BuiltValue()
abstract class PostLedgersByLedgerIdCategoriesRemovalPreview200Response
    implements
        Built<PostLedgersByLedgerIdCategoriesRemovalPreview200Response,
            PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseBuilder> {
  @BuiltValueField(wireName: r'preview_token')
  String get previewToken;

  @BuiltValueField(wireName: r'categories')
  BuiltList<Category> get categories;

  @BuiltValueField(wireName: r'transaction_count')
  int get transactionCount;

  @BuiltValueField(wireName: r'recurring_count')
  int get recurringCount;

  PostLedgersByLedgerIdCategoriesRemovalPreview200Response._();

  factory PostLedgersByLedgerIdCategoriesRemovalPreview200Response(
      [void updates(
          PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseBuilder
              b)]) = _$PostLedgersByLedgerIdCategoriesRemovalPreview200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdCategoriesRemovalPreview200Response>
      get serializer =>
          _$PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseSerializer();
}

class _$PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseSerializer
    implements
        PrimitiveSerializer<
            PostLedgersByLedgerIdCategoriesRemovalPreview200Response> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdCategoriesRemovalPreview200Response,
    _$PostLedgersByLedgerIdCategoriesRemovalPreview200Response
  ];

  @override
  final String wireName =
      r'PostLedgersByLedgerIdCategoriesRemovalPreview200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesRemovalPreview200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'preview_token';
    yield serializers.serialize(
      object.previewToken,
      specifiedType: const FullType(String),
    );
    yield r'categories';
    yield serializers.serialize(
      object.categories,
      specifiedType: const FullType(BuiltList, [FullType(Category)]),
    );
    yield r'transaction_count';
    yield serializers.serialize(
      object.transactionCount,
      specifiedType: const FullType(int),
    );
    yield r'recurring_count';
    yield serializers.serialize(
      object.recurringCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesRemovalPreview200Response object, {
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
    required PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'preview_token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.previewToken = valueDes;
          break;
        case r'categories':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Category)]),
          ) as BuiltList<Category>;
          result.categories.replace(valueDes);
          break;
        case r'transaction_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.transactionCount = valueDes;
          break;
        case r'recurring_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.recurringCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdCategoriesRemovalPreview200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostLedgersByLedgerIdCategoriesRemovalPreview200ResponseBuilder();
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
