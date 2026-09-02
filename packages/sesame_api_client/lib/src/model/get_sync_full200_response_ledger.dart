//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_full200_response_ledger.g.dart';

/// GetSyncFull200ResponseLedger
///
/// Properties:
/// * [id]
/// * [syncId]
/// * [name]
/// * [currency]
/// * [monthStartDay]
/// * [aaEnabled]
/// * [updatedAt]
@BuiltValue()
abstract class GetSyncFull200ResponseLedger
    implements
        Built<GetSyncFull200ResponseLedger,
            GetSyncFull200ResponseLedgerBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'sync_id')
  String get syncId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'month_start_day')
  int get monthStartDay;

  @BuiltValueField(wireName: r'aa_enabled')
  bool get aaEnabled;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  GetSyncFull200ResponseLedger._();

  factory GetSyncFull200ResponseLedger(
          [void updates(GetSyncFull200ResponseLedgerBuilder b)]) =
      _$GetSyncFull200ResponseLedger;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetSyncFull200ResponseLedgerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncFull200ResponseLedger> get serializer =>
      _$GetSyncFull200ResponseLedgerSerializer();
}

class _$GetSyncFull200ResponseLedgerSerializer
    implements PrimitiveSerializer<GetSyncFull200ResponseLedger> {
  @override
  final Iterable<Type> types = const [
    GetSyncFull200ResponseLedger,
    _$GetSyncFull200ResponseLedger
  ];

  @override
  final String wireName = r'GetSyncFull200ResponseLedger';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncFull200ResponseLedger object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'sync_id';
    yield serializers.serialize(
      object.syncId,
      specifiedType: const FullType(String),
    );
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
    yield r'month_start_day';
    yield serializers.serialize(
      object.monthStartDay,
      specifiedType: const FullType(int),
    );
    yield r'aa_enabled';
    yield serializers.serialize(
      object.aaEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetSyncFull200ResponseLedger object, {
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
    required GetSyncFull200ResponseLedgerBuilder result,
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
        case r'sync_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.syncId = valueDes;
          break;
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
        case r'month_start_day':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.monthStartDay = valueDes;
          break;
        case r'aa_enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.aaEnabled = valueDes;
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetSyncFull200ResponseLedger deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetSyncFull200ResponseLedgerBuilder();
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
