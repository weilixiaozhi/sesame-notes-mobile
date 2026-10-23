//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_recurring_transactions_generate_due_request.g.dart';

/// PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest
///
/// Properties:
/// * [mutationId]
/// * [expectedSyncId]
/// * [expectedCurrency]
/// * [rates]
/// * [limit]
@BuiltValue()
abstract class PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest
    implements
        Built<PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest,
            PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestBuilder> {
  @BuiltValueField(wireName: r'mutation_id')
  String get mutationId;

  @BuiltValueField(wireName: r'expected_sync_id')
  String get expectedSyncId;

  @BuiltValueField(wireName: r'expected_currency')
  String get expectedCurrency;

  @BuiltValueField(wireName: r'rates')
  BuiltMap<String, String>? get rates;

  @BuiltValueField(wireName: r'limit')
  int? get limit;

  PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest._();

  factory PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest(
          [void updates(
              PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestBuilder
                  b)]) =
      _$PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest>
      get serializer =>
          _$PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestSerializer();
}

class _$PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestSerializer
    implements
        PrimitiveSerializer<
            PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest,
    _$PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest
  ];

  @override
  final String wireName =
      r'PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'mutation_id';
    yield serializers.serialize(
      object.mutationId,
      specifiedType: const FullType(String),
    );
    yield r'expected_sync_id';
    yield serializers.serialize(
      object.expectedSyncId,
      specifiedType: const FullType(String),
    );
    yield r'expected_currency';
    yield serializers.serialize(
      object.expectedCurrency,
      specifiedType: const FullType(String),
    );
    if (object.rates != null) {
      yield r'rates';
      yield serializers.serialize(
        object.rates,
        specifiedType:
            const FullType(BuiltMap, [FullType(String), FullType(String)]),
      );
    }
    if (object.limit != null) {
      yield r'limit';
      yield serializers.serialize(
        object.limit,
        specifiedType: const FullType(int),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest object, {
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
    required PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestBuilder
        result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mutation_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mutationId = valueDes;
          break;
        case r'expected_sync_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.expectedSyncId = valueDes;
          break;
        case r'expected_currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.expectedCurrency = valueDes;
          break;
        case r'rates':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(
                BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>?;
          if (valueDes == null) continue;
          result.rates.replace(valueDes);
          break;
        case r'limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(int),
          ) as int?;
          if (valueDes == null) continue;
          result.limit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostLedgersByLedgerIdRecurringTransactionsGenerateDueRequestBuilder();
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
