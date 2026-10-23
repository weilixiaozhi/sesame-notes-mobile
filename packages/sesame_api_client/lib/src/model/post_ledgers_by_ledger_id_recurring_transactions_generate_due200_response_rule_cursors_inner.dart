//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'post_ledgers_by_ledger_id_recurring_transactions_generate_due200_response_rule_cursors_inner.g.dart';

/// PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner
///
/// Properties:
/// * [id]
/// * [lastGeneratedDate]
@BuiltValue()
abstract class PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner
    implements
        Built<
            PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner,
            PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'last_generated_date')
  DateTime? get lastGeneratedDate;

  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner._();

  factory PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner(
          [void updates(
              PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerBuilder
                  b)]) =
      _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerBuilder
              b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<
          PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner>
      get serializer =>
          _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerSerializer();
}

class _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerSerializer
    implements
        PrimitiveSerializer<
            PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner> {
  @override
  final Iterable<Type> types = const [
    PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner,
    _$PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner
  ];

  @override
  final String wireName =
      r'PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner
        object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'last_generated_date';
    yield object.lastGeneratedDate == null
        ? null
        : serializers.serialize(
            object.lastGeneratedDate,
            specifiedType: const FullType.nullable(DateTime),
          );
  }

  @override
  Object serialize(
    Serializers serializers,
    PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner
        object, {
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
    required PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerBuilder
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
        case r'last_generated_date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastGeneratedDate = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInner
      deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        PostLedgersByLedgerIdRecurringTransactionsGenerateDue200ResponseRuleCursorsInnerBuilder();
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
