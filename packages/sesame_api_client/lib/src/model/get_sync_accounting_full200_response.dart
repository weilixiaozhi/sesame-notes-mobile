//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sesame_api_client/src/model/get_sync_accounting_full200_response_ledger_snapshots_inner.dart';
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/category.dart';
import 'package:sesame_api_client/src/model/exchange_rate_override.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_accounting_full200_response.g.dart';

/// GetSyncAccountingFull200Response
///
/// Properties:
/// * [ledgerSnapshots]
/// * [categories]
/// * [exchangeRateOverrides]
/// * [categoryTombstones]
/// * [deletedExchangeRateOverrideIds]
/// * [serverCursor]
@BuiltValue()
abstract class GetSyncAccountingFull200Response
    implements
        Built<GetSyncAccountingFull200Response,
            GetSyncAccountingFull200ResponseBuilder> {
  @BuiltValueField(wireName: r'ledger_snapshots')
  BuiltList<GetSyncAccountingFull200ResponseLedgerSnapshotsInner>
      get ledgerSnapshots;

  @BuiltValueField(wireName: r'categories')
  BuiltList<Category> get categories;

  @BuiltValueField(wireName: r'exchange_rate_overrides')
  BuiltList<ExchangeRateOverride> get exchangeRateOverrides;

  @BuiltValueField(wireName: r'category_tombstones')
  BuiltList<Category> get categoryTombstones;

  @BuiltValueField(wireName: r'deleted_exchange_rate_override_ids')
  BuiltList<String> get deletedExchangeRateOverrideIds;

  @BuiltValueField(wireName: r'server_cursor')
  String get serverCursor;

  GetSyncAccountingFull200Response._();

  factory GetSyncAccountingFull200Response(
          [void updates(GetSyncAccountingFull200ResponseBuilder b)]) =
      _$GetSyncAccountingFull200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetSyncAccountingFull200ResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncAccountingFull200Response> get serializer =>
      _$GetSyncAccountingFull200ResponseSerializer();
}

class _$GetSyncAccountingFull200ResponseSerializer
    implements PrimitiveSerializer<GetSyncAccountingFull200Response> {
  @override
  final Iterable<Type> types = const [
    GetSyncAccountingFull200Response,
    _$GetSyncAccountingFull200Response
  ];

  @override
  final String wireName = r'GetSyncAccountingFull200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncAccountingFull200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ledger_snapshots';
    yield serializers.serialize(
      object.ledgerSnapshots,
      specifiedType: const FullType(BuiltList,
          [FullType(GetSyncAccountingFull200ResponseLedgerSnapshotsInner)]),
    );
    yield r'categories';
    yield serializers.serialize(
      object.categories,
      specifiedType: const FullType(BuiltList, [FullType(Category)]),
    );
    yield r'exchange_rate_overrides';
    yield serializers.serialize(
      object.exchangeRateOverrides,
      specifiedType:
          const FullType(BuiltList, [FullType(ExchangeRateOverride)]),
    );
    yield r'category_tombstones';
    yield serializers.serialize(
      object.categoryTombstones,
      specifiedType: const FullType(BuiltList, [FullType(Category)]),
    );
    yield r'deleted_exchange_rate_override_ids';
    yield serializers.serialize(
      object.deletedExchangeRateOverrideIds,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
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
    GetSyncAccountingFull200Response object, {
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
    required GetSyncAccountingFull200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ledger_snapshots':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(GetSyncAccountingFull200ResponseLedgerSnapshotsInner)
            ]),
          ) as BuiltList<GetSyncAccountingFull200ResponseLedgerSnapshotsInner>;
          result.ledgerSnapshots.replace(valueDes);
          break;
        case r'categories':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Category)]),
          ) as BuiltList<Category>;
          result.categories.replace(valueDes);
          break;
        case r'exchange_rate_overrides':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(BuiltList, [FullType(ExchangeRateOverride)]),
          ) as BuiltList<ExchangeRateOverride>;
          result.exchangeRateOverrides.replace(valueDes);
          break;
        case r'category_tombstones':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(Category)]),
          ) as BuiltList<Category>;
          result.categoryTombstones.replace(valueDes);
          break;
        case r'deleted_exchange_rate_override_ids':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.deletedExchangeRateOverrideIds.replace(valueDes);
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
  GetSyncAccountingFull200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetSyncAccountingFull200ResponseBuilder();
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
