//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/member.dart';
import 'package:sesame_api_client/src/model/transaction.dart';
import 'package:sesame_api_client/src/model/category.dart';
import 'package:sesame_api_client/src/model/recurring_transaction.dart';
import 'package:sesame_api_client/src/model/exchange_rate_override.dart';
import 'package:sesame_api_client/src/model/get_sync_full200_response_ledger.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_full200_response.g.dart';

/// GetSyncFull200Response
///
/// Properties:
/// * [ledger]
/// * [members]
/// * [transactions]
/// * [categories]
/// * [recurringTransactions]
/// * [exchangeRateOverrides]
/// * [serverCursor]
@BuiltValue()
abstract class GetSyncFull200Response
    implements Built<GetSyncFull200Response, GetSyncFull200ResponseBuilder> {
  @BuiltValueField(wireName: r'ledger')
  GetSyncFull200ResponseLedger get ledger;

  @BuiltValueField(wireName: r'members')
  BuiltList<Member> get members;

  @BuiltValueField(wireName: r'transactions')
  BuiltList<Transaction> get transactions;

  @BuiltValueField(wireName: r'categories')
  BuiltList<Category> get categories;

  @BuiltValueField(wireName: r'recurring_transactions')
  BuiltList<RecurringTransaction> get recurringTransactions;

  @BuiltValueField(wireName: r'exchange_rate_overrides')
  BuiltList<ExchangeRateOverride> get exchangeRateOverrides;

  @BuiltValueField(wireName: r'server_cursor')
  String get serverCursor;

  GetSyncFull200Response._();

  factory GetSyncFull200Response(
          [void updates(GetSyncFull200ResponseBuilder b)]) =
      _$GetSyncFull200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetSyncFull200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncFull200Response> get serializer =>
      _$GetSyncFull200ResponseSerializer();
}

class _$GetSyncFull200ResponseSerializer
    implements PrimitiveSerializer<GetSyncFull200Response> {
  @override
  final Iterable<Type> types = const [
    GetSyncFull200Response,
    _$GetSyncFull200Response
  ];

  @override
  final String wireName = r'GetSyncFull200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncFull200Response object, {
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
    yield r'server_cursor';
    yield serializers.serialize(
      object.serverCursor,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetSyncFull200Response object, {
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
    required GetSyncFull200ResponseBuilder result,
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
        case r'server_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.serverCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetSyncFull200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetSyncFull200ResponseBuilder();
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
