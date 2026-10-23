//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_categories_remove200_response.g.dart';

/// PostLedgersByLedgerIdCategoriesRemove200Response
///
/// Properties:
/// * [removedCategories]
/// * [promotedCategories]
/// * [affectedTransactions]
/// * [affectedRecurringRules]
@BuiltValue()
abstract class PostLedgersByLedgerIdCategoriesRemove200Response
    implements
        Built<PostLedgersByLedgerIdCategoriesRemove200Response,
            PostLedgersByLedgerIdCategoriesRemove200ResponseBuilder> {
  @BuiltValueField(wireName: r'removed_categories')
  int get removedCategories;

  @BuiltValueField(wireName: r'promoted_categories')
  int get promotedCategories;

  @BuiltValueField(wireName: r'affected_transactions')
  int get affectedTransactions;

  @BuiltValueField(wireName: r'affected_recurring_rules')
  int get affectedRecurringRules;

  PostLedgersByLedgerIdCategoriesRemove200Response._();

  factory PostLedgersByLedgerIdCategoriesRemove200Response(
          [void updates(
              PostLedgersByLedgerIdCategoriesRemove200ResponseBuilder b)]) =
      _$PostLedgersByLedgerIdCategoriesRemove200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostLedgersByLedgerIdCategoriesRemove200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PostLedgersByLedgerIdCategoriesRemove200Response>
      get serializer =>
          _$PostLedgersByLedgerIdCategoriesRemove200ResponseSerializer();
}

class _$PostLedgersByLedgerIdCategoriesRemove200ResponseSerializer
    implements
        PrimitiveSerializer<PostLedgersByLedgerIdCategoriesRemove200Response> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdCategoriesRemove200Response,
    _$PostLedgersByLedgerIdCategoriesRemove200Response
  ];

  @override
  final String wireName = r'PostLedgersByLedgerIdCategoriesRemove200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesRemove200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'removed_categories';
    yield serializers.serialize(
      object.removedCategories,
      specifiedType: const FullType(int),
    );
    yield r'promoted_categories';
    yield serializers.serialize(
      object.promotedCategories,
      specifiedType: const FullType(int),
    );
    yield r'affected_transactions';
    yield serializers.serialize(
      object.affectedTransactions,
      specifiedType: const FullType(int),
    );
    yield r'affected_recurring_rules';
    yield serializers.serialize(
      object.affectedRecurringRules,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdCategoriesRemove200Response object, {
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
    required PostLedgersByLedgerIdCategoriesRemove200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'removed_categories':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.removedCategories = valueDes;
          break;
        case r'promoted_categories':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.promotedCategories = valueDes;
          break;
        case r'affected_transactions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.affectedTransactions = valueDes;
          break;
        case r'affected_recurring_rules':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.affectedRecurringRules = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdCategoriesRemove200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PostLedgersByLedgerIdCategoriesRemove200ResponseBuilder();
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
