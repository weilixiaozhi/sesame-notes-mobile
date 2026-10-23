//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/post_ledgers_by_ledger_id_recurring_transactions_generate_due200_response_rule_cursors_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_recurring_transactions_generate_due200_response.g.dart';

/// PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response
///
/// Properties:
/// * [generatedCount]
/// * [skippedCount]
/// * [hasMore]
/// * [ruleCursors]
/// * [replayed]
@BuiltValue()
abstract class PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response
    implements
        Built<PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response,
            PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseBuilder> {
  @BuiltValueField(wireName: r'generated_count')
  int get generatedCount;

  @BuiltValueField(wireName: r'skipped_count')
  int get skippedCount;

  @BuiltValueField(wireName: r'has_more')
  bool get hasMore;

  @BuiltValueField(wireName: r'rule_cursors')
  BuiltList<
          PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner>
      get ruleCursors;

  @BuiltValueField(wireName: r'replayed')
  bool get replayed;

  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response._();

  factory PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response(
          [void updates(
              PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseBuilder
                  b)]) =
      _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response>
      get serializer =>
          _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseSerializer();
}

class _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseSerializer
    implements
        PrimitiveSerializer<
            PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response,
    _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response
  ];

  @override
  final String wireName =
      r'PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'generated_count';
    yield serializers.serialize(
      object.generatedCount,
      specifiedType: const FullType(int),
    );
    yield r'skipped_count';
    yield serializers.serialize(
      object.skippedCount,
      specifiedType: const FullType(int),
    );
    yield r'has_more';
    yield serializers.serialize(
      object.hasMore,
      specifiedType: const FullType(bool),
    );
    yield r'rule_cursors';
    yield serializers.serialize(
      object.ruleCursors,
      specifiedType: const FullType(BuiltList, [
        FullType(
            PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner)
      ]),
    );
    yield r'replayed';
    yield serializers.serialize(
      object.replayed,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response object, {
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
    required PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'generated_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.generatedCount = valueDes;
          break;
        case r'skipped_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.skippedCount = valueDes;
          break;
        case r'has_more':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasMore = valueDes;
          break;
        case r'rule_cursors':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(
                  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner)
            ]),
          ) as BuiltList<
              PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner>;
          result.ruleCursors.replace(valueDes);
          break;
        case r'replayed':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.replayed = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseBuilder();
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
