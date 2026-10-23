//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:sesame_api_client/src/model/get_ledgers_by_ledger_id_member_stats200_response_items_inner.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_ledgers_by_ledger_id_member_stats200_response.g.dart';

/// GetLedgersByLedgerIdMemberStats200Response
///
/// Properties:
/// * [ledgerId]
/// * [ledgerCurrency]
/// * [scope]
/// * [period]
/// * [startAt]
/// * [endAt]
/// * [items]
@BuiltValue()
abstract class GetLedgersByLedgerIdMemberStats200Response
    implements
        Built<GetLedgersByLedgerIdMemberStats200Response,
            GetLedgersByLedgerIdMemberStats200ResponseBuilder> {
  @BuiltValueField(wireName: r'ledger_id')
  String get ledgerId;

  @BuiltValueField(wireName: r'ledger_currency')
  String get ledgerCurrency;

  @BuiltValueField(wireName: r'scope')
  GetLedgersByLedgerIdMemberStats200ResponseScopeEnum get scope;
  // enum scopeEnum {  month,  year,  all,  };

  @BuiltValueField(wireName: r'period')
  String? get period;

  @BuiltValueField(wireName: r'start_at')
  DateTime? get startAt;

  @BuiltValueField(wireName: r'end_at')
  DateTime? get endAt;

  @BuiltValueField(wireName: r'items')
  BuiltList<GetLedgersByLedgerIdMemberStats200ResponseItemsInner> get items;

  GetLedgersByLedgerIdMemberStats200Response._();

  factory GetLedgersByLedgerIdMemberStats200Response(
          [void updates(GetLedgersByLedgerIdMemberStats200ResponseBuilder b)]) =
      _$GetLedgersByLedgerIdMemberStats200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetLedgersByLedgerIdMemberStats200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetLedgersByLedgerIdMemberStats200Response>
      get serializer =>
          _$GetLedgersByLedgerIdMemberStats200ResponseSerializer();
}

class _$GetLedgersByLedgerIdMemberStats200ResponseSerializer
    implements PrimitiveSerializer<GetLedgersByLedgerIdMemberStats200Response> {
  @override
  final Iterable<Type> types = const [
    GetLedgersByLedgerIdMemberStats200Response,
    _$GetLedgersByLedgerIdMemberStats200Response
  ];

  @override
  final String wireName = r'GetLedgersByLedgerIdMemberStats200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetLedgersByLedgerIdMemberStats200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'ledger_id';
    yield serializers.serialize(
      object.ledgerId,
      specifiedType: const FullType(String),
    );
    yield r'ledger_currency';
    yield serializers.serialize(
      object.ledgerCurrency,
      specifiedType: const FullType(String),
    );
    yield r'scope';
    yield serializers.serialize(
      object.scope,
      specifiedType:
          const FullType(GetLedgersByLedgerIdMemberStats200ResponseScopeEnum),
    );
    yield r'period';
    yield object.period == null
        ? null
        : serializers.serialize(
            object.period,
            specifiedType: const FullType.nullable(String),
          );
    yield r'start_at';
    yield object.startAt == null
        ? null
        : serializers.serialize(
            object.startAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'end_at';
    yield object.endAt == null
        ? null
        : serializers.serialize(
            object.endAt,
            specifiedType: const FullType.nullable(DateTime),
          );
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList,
          [FullType(GetLedgersByLedgerIdMemberStats200ResponseItemsInner)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetLedgersByLedgerIdMemberStats200Response object, {
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
    required GetLedgersByLedgerIdMemberStats200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'ledger_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ledgerId = valueDes;
          break;
        case r'ledger_currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.ledgerCurrency = valueDes;
          break;
        case r'scope':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetLedgersByLedgerIdMemberStats200ResponseScopeEnum),
          ) as GetLedgersByLedgerIdMemberStats200ResponseScopeEnum;
          result.scope = valueDes;
          break;
        case r'period':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.period = valueDes;
          break;
        case r'start_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.startAt = valueDes;
          break;
        case r'end_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endAt = valueDes;
          break;
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [
              FullType(GetLedgersByLedgerIdMemberStats200ResponseItemsInner)
            ]),
          ) as BuiltList<GetLedgersByLedgerIdMemberStats200ResponseItemsInner>;
          result.items.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetLedgersByLedgerIdMemberStats200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetLedgersByLedgerIdMemberStats200ResponseBuilder();
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

class GetLedgersByLedgerIdMemberStats200ResponseScopeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'month')
  static const GetLedgersByLedgerIdMemberStats200ResponseScopeEnum month =
      _$getLedgersByLedgerIdMemberStats200ResponseScopeEnum_month;
  @BuiltValueEnumConst(wireName: r'year')
  static const GetLedgersByLedgerIdMemberStats200ResponseScopeEnum year =
      _$getLedgersByLedgerIdMemberStats200ResponseScopeEnum_year;
  @BuiltValueEnumConst(wireName: r'all')
  static const GetLedgersByLedgerIdMemberStats200ResponseScopeEnum all =
      _$getLedgersByLedgerIdMemberStats200ResponseScopeEnum_all;

  static Serializer<GetLedgersByLedgerIdMemberStats200ResponseScopeEnum>
      get serializer =>
          _$getLedgersByLedgerIdMemberStats200ResponseScopeEnumSerializer;

  const GetLedgersByLedgerIdMemberStats200ResponseScopeEnum._(String name)
      : super(name);

  static BuiltSet<GetLedgersByLedgerIdMemberStats200ResponseScopeEnum>
      get values => _$getLedgersByLedgerIdMemberStats200ResponseScopeEnumValues;
  static GetLedgersByLedgerIdMemberStats200ResponseScopeEnum valueOf(
          String name) =>
      _$getLedgersByLedgerIdMemberStats200ResponseScopeEnumValueOf(name);
}
