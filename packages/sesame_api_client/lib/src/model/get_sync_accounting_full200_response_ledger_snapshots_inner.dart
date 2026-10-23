//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_sync_full200_response_recurring_state.dart';
import 'package:sesame_api_client/src/model/member.dart';
import 'package:sesame_api_client/src/model/transaction.dart';
import 'package:sesame_api_client/src/model/category.dart';
import 'package:sesame_api_client/src/model/recurring_transaction.dart';
import 'package:sesame_api_client/src/model/exchange_rate_override.dart';
import 'package:sesame_api_client/src/model/get_sync_full200_response_ledger.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_accounting_full200_response_ledger_snapshots_inner.g.dart';

/// GetSyncAccountingFull200ResponseLedgerSnapshotsInner
///
/// Properties:
/// * [ledger]
/// * [members]
/// * [transactions]
/// * [categories]
/// * [categoryTombstones]
/// * [recurringTransactions]
/// * [exchangeRateOverrides]
/// * [recurringState]
@BuiltValue()
abstract class GetSyncAccountingFull200ResponseLedgerSnapshotsInner
    implements
        Built<GetSyncAccountingFull200ResponseLedgerSnapshotsInner,
            GetSyncAccountingFull200ResponseLedgerSnapshotsInnerBuilder> {
  @BuiltValueField(wireName: r'ledger')
  GetSyncFull200ResponseLedger get ledger;

  @BuiltValueField(wireName: r'members')
  BuiltList<Member> get members;

  @BuiltValueField(wireName: r'transactions')
  BuiltList<Transaction> get transactions;

  @BuiltValueField(wireName: r'categories')
  BuiltList<Category> get categories;

  @BuiltValueField(wireName: r'category_tombstones')
  BuiltList<Category> get categoryTombstones;

  @BuiltValueField(wireName: r'recurring_transactions')
  BuiltList<RecurringTransaction> get recurringTransactions;

  @BuiltValueField(wireName: r'exchange_rate_overrides')
  BuiltList<ExchangeRateOverride> get exchangeRateOverrides;

  @BuiltValueField(wireName: r'recurring_state')
  GetSyncFull200ResponseRecurringState? get recurringState;

  GetSyncAccountingFull200ResponseLedgerSnapshotsInner._();

  factory GetSyncAccountingFull200ResponseLedgerSnapshotsInner(
          [void updates(
              GetSyncAccountingFull200ResponseLedgerSnapshotsInnerBuilder b)]) =
      _$GetSyncAccountingFull200ResponseLedgerSnapshotsInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetSyncAccountingFull200ResponseLedgerSnapshotsInnerBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncAccountingFull200ResponseLedgerSnapshotsInner>
      get serializer =>
          _$GetSyncAccountingFull200ResponseLedgerSnapshotsInnerSerializer();
}

class _$GetSyncAccountingFull200ResponseLedgerSnapshotsInnerSerializer
    implements
        PrimitiveSerializer<
            GetSyncAccountingFull200ResponseLedgerSnapshotsInner> {
  @override
  final Iterable<Type> types = const [
    GetSyncAccountingFull200ResponseLedgerSnapshotsInner,
    _$GetSyncAccountingFull200ResponseLedgerSnapshotsInner
  ];

  @override
  final String wireName =
      r'GetSyncAccountingFull200ResponseLedgerSnapshotsInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncAccountingFull200ResponseLedgerSnapshotsInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ledger';
    yield serializers.serialize(
      object.ledger,
      specifiedType: const FullType(GetSyncFull200ResponseLedger),
    );
    yield r'members';
    yield serializers.serialize(
      object.members,
      specifiedType: const FullType(BuiltList, [FullType(Member)]),
    );
    yield r'transactions';
    yield serializers.serialize(
      object.transactions,
      specifiedType: const FullType(BuiltList, [FullType(Transaction)]),
    );
    yield r'categories';
    yield serializers.serialize(
      object.categories,
      specifiedType: const FullType(BuiltList, [FullType(Category)]),
    );
    yield r'category_tombstones';
    yield serializers.serialize(
      object.categoryTombstones,
      specifiedType: const FullType(BuiltList, [FullType(Category)]),
    );
    yield r'recurring_transactions';
    yield serializers.serialize(
      object.recurringTransactions,
      specifiedType:
          const FullType(BuiltList, [FullType(RecurringTransaction)]),
    );
    yield r'exchange_rate_overrides';
    yield serializers.serialize(
      object.exchangeRateOverrides,
      specifiedType:
          const FullType(BuiltList, [FullType(ExchangeRateOverride)]),
    );
    if (object.recurringState != null) {
      yield r'recurring_state';
      yield serializers.serialize(
        object.recurringState,
        specifiedType: const FullType(GetSyncFull200ResponseRecurringState),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GetSyncAccountingFull200ResponseLedgerSnapshotsInner object, {
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
    required GetSyncAccountingFull200ResponseLedgerSnapshotsInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ledger':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(GetSyncFull200ResponseLedger),
          ) as GetSyncFull200ResponseLedger;
          result.ledger.replace(valueDes);
          break;
        case r'members':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Member)]),
          ) as BuiltList<Member>;
          result.members.replace(valueDes);
          break;
        case r'transactions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Transaction)]),
          ) as BuiltList<Transaction>;
          result.transactions.replace(valueDes);
          break;
        case r'categories':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Category)]),
          ) as BuiltList<Category>;
          result.categories.replace(valueDes);
          break;
        case r'category_tombstones':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Category)]),
          ) as BuiltList<Category>;
          result.categoryTombstones.replace(valueDes);
          break;
        case r'recurring_transactions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(RecurringTransaction)]),
          ) as BuiltList<RecurringTransaction>;
          result.recurringTransactions.replace(valueDes);
          break;
        case r'exchange_rate_overrides':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(ExchangeRateOverride)]),
          ) as BuiltList<ExchangeRateOverride>;
          result.exchangeRateOverrides.replace(valueDes);
          break;
        case r'recurring_state':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType.nullable(GetSyncFull200ResponseRecurringState),
          ) as GetSyncFull200ResponseRecurringState?;
          if (valueDes == null) continue;
          result.recurringState.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetSyncAccountingFull200ResponseLedgerSnapshotsInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result =
        GetSyncAccountingFull200ResponseLedgerSnapshotsInnerBuilder();
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
