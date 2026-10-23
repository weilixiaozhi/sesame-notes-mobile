//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_ledgers_by_ledger_id_action_preview200_response.g.dart';

/// GetLedgersByLedgerIdActionPreview200Response
///
/// Properties:
/// * [name]
/// * [currency]
/// * [syncId]
/// * [fingerprint]
/// * [transactionCount]
/// * [recurringCount]
/// * [memberCount]
@BuiltValue()
abstract class GetLedgersByLedgerIdActionPreview200Response
    implements
        Built<GetLedgersByLedgerIdActionPreview200Response,
            GetLedgersByLedgerIdActionPreview200ResponseBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'sync_id')
  String get syncId;

  @BuiltValueField(wireName: r'fingerprint')
  String get fingerprint;

  @BuiltValueField(wireName: r'transaction_count')
  int get transactionCount;

  @BuiltValueField(wireName: r'recurring_count')
  int get recurringCount;

  @BuiltValueField(wireName: r'member_count')
  int get memberCount;

  GetLedgersByLedgerIdActionPreview200Response._();

  factory GetLedgersByLedgerIdActionPreview200Response(
          [void updates(
              GetLedgersByLedgerIdActionPreview200ResponseBuilder b)]) =
      _$GetLedgersByLedgerIdActionPreview200Response;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(
          GetLedgersByLedgerIdActionPreview200ResponseBuilder b) =>
      b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetLedgersByLedgerIdActionPreview200Response>
      get serializer =>
          _$GetLedgersByLedgerIdActionPreview200ResponseSerializer();
}

class _$GetLedgersByLedgerIdActionPreview200ResponseSerializer
    implements
        PrimitiveSerializer<GetLedgersByLedgerIdActionPreview200Response> {
  @override
  final Iterable<Type> types = const [
    GetLedgersByLedgerIdActionPreview200Response,
    _$GetLedgersByLedgerIdActionPreview200Response
  ];

  @override
  final String wireName = r'GetLedgersByLedgerIdActionPreview200Response';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetLedgersByLedgerIdActionPreview200Response object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'sync_id';
    yield serializers.serialize(
      object.syncId,
      specifiedType: const FullType(String),
    );
    yield r'fingerprint';
    yield serializers.serialize(
      object.fingerprint,
      specifiedType: const FullType(String),
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
    yield r'member_count';
    yield serializers.serialize(
      object.memberCount,
      specifiedType: const FullType(int),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetLedgersByLedgerIdActionPreview200Response object, {
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
    required GetLedgersByLedgerIdActionPreview200ResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'sync_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.syncId = valueDes;
          break;
        case r'fingerprint':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.fingerprint = valueDes;
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
        case r'member_count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.memberCount = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetLedgersByLedgerIdActionPreview200Response deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetLedgersByLedgerIdActionPreview200ResponseBuilder();
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
