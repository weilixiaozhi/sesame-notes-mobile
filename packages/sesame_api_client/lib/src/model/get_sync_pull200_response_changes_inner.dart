//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'get_sync_pull200_response_changes_inner.g.dart';

/// GetSyncPull200ResponseChangesInner
///
/// Properties:
/// * [changeId]
/// * [ledgerId]
/// * [entityType]
/// * [entityId]
/// * [action]
/// * [mutationId]
/// * [payload]
/// * [updatedAt]
/// * [deviceId]
@BuiltValue()
abstract class GetSyncPull200ResponseChangesInner
    implements
        Built<GetSyncPull200ResponseChangesInner,
            GetSyncPull200ResponseChangesInnerBuilder> {
  @BuiltValueField(wireName: r'change_id')
  String get changeId;

  @BuiltValueField(wireName: r'ledger_id')
  String? get ledgerId;

  @BuiltValueField(wireName: r'entity_type')
  GetSyncPull200ResponseChangesInnerEntityTypeEnum get entityType;
  // enum entityTypeEnum {  ledger,  transaction,  category,  recurring_transaction,  exchange_rate_override,  member,  };

  @BuiltValueField(wireName: r'entity_id')
  String get entityId;

  @BuiltValueField(wireName: r'action')
  GetSyncPull200ResponseChangesInnerActionEnum get action;
  // enum actionEnum {  upsert,  delete,  };

  @BuiltValueField(wireName: r'mutation_id')
  String get mutationId;

  @BuiltValueField(wireName: r'payload')
  BuiltMap<String, JsonObject?> get payload;

  @BuiltValueField(wireName: r'updated_at')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'device_id')
  String get deviceId;

  GetSyncPull200ResponseChangesInner._();

  factory GetSyncPull200ResponseChangesInner(
          [void updates(GetSyncPull200ResponseChangesInnerBuilder b)]) =
      _$GetSyncPull200ResponseChangesInner;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GetSyncPull200ResponseChangesInnerBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GetSyncPull200ResponseChangesInner> get serializer =>
      _$GetSyncPull200ResponseChangesInnerSerializer();
}

class _$GetSyncPull200ResponseChangesInnerSerializer
    implements PrimitiveSerializer<GetSyncPull200ResponseChangesInner> {
  @override
  final Iterable<Type> types = const [
    GetSyncPull200ResponseChangesInner,
    _$GetSyncPull200ResponseChangesInner
  ];

  @override
  final String wireName = r'GetSyncPull200ResponseChangesInner';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GetSyncPull200ResponseChangesInner object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'change_id';
    yield serializers.serialize(
      object.changeId,
      specifiedType: const FullType(String),
    );
    yield r'ledger_id';
    yield object.ledgerId == null
        ? null
        : serializers.serialize(
            object.ledgerId,
            specifiedType: const FullType.nullable(String),
          );
    yield r'entity_type';
    yield serializers.serialize(
      object.entityType,
      specifiedType:
          const FullType(GetSyncPull200ResponseChangesInnerEntityTypeEnum),
    );
    yield r'entity_id';
    yield serializers.serialize(
      object.entityId,
      specifiedType: const FullType(String),
    );
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType:
          const FullType(GetSyncPull200ResponseChangesInnerActionEnum),
    );
    yield r'mutation_id';
    yield serializers.serialize(
      object.mutationId,
      specifiedType: const FullType(String),
    );
    yield r'payload';
    yield serializers.serialize(
      object.payload,
      specifiedType: const FullType(
          BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
    );
    yield r'updated_at';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'device_id';
    yield serializers.serialize(
      object.deviceId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    GetSyncPull200ResponseChangesInner object, {
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
    required GetSyncPull200ResponseChangesInnerBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'change_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.changeId = valueDes;
          break;
        case r'ledger_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.ledgerId = valueDes;
          break;
        case r'entity_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                GetSyncPull200ResponseChangesInnerEntityTypeEnum),
          ) as GetSyncPull200ResponseChangesInnerEntityTypeEnum;
          result.entityType = valueDes;
          break;
        case r'entity_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.entityId = valueDes;
          break;
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType:
                const FullType(GetSyncPull200ResponseChangesInnerActionEnum),
          ) as GetSyncPull200ResponseChangesInnerActionEnum;
          result.action = valueDes;
          break;
        case r'mutation_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mutationId = valueDes;
          break;
        case r'payload':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(
                BuiltMap, [FullType(String), FullType.nullable(JsonObject)]),
          ) as BuiltMap<String, JsonObject?>;
          result.payload.replace(valueDes);
          break;
        case r'updated_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'device_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GetSyncPull200ResponseChangesInner deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GetSyncPull200ResponseChangesInnerBuilder();
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

class GetSyncPull200ResponseChangesInnerEntityTypeEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'ledger')
  static const GetSyncPull200ResponseChangesInnerEntityTypeEnum ledger =
      _$getSyncPull200ResponseChangesInnerEntityTypeEnum_ledger;
  @BuiltValueEnumConst(wireName: r'transaction')
  static const GetSyncPull200ResponseChangesInnerEntityTypeEnum transaction =
      _$getSyncPull200ResponseChangesInnerEntityTypeEnum_transaction;
  @BuiltValueEnumConst(wireName: r'category')
  static const GetSyncPull200ResponseChangesInnerEntityTypeEnum category =
      _$getSyncPull200ResponseChangesInnerEntityTypeEnum_category;
  @BuiltValueEnumConst(wireName: r'recurring_transaction')
  static const GetSyncPull200ResponseChangesInnerEntityTypeEnum
      recurringTransaction =
      _$getSyncPull200ResponseChangesInnerEntityTypeEnum_recurringTransaction;
  @BuiltValueEnumConst(wireName: r'exchange_rate_override')
  static const GetSyncPull200ResponseChangesInnerEntityTypeEnum
      exchangeRateOverride =
      _$getSyncPull200ResponseChangesInnerEntityTypeEnum_exchangeRateOverride;
  @BuiltValueEnumConst(wireName: r'member')
  static const GetSyncPull200ResponseChangesInnerEntityTypeEnum member =
      _$getSyncPull200ResponseChangesInnerEntityTypeEnum_member;

  static Serializer<GetSyncPull200ResponseChangesInnerEntityTypeEnum>
      get serializer =>
          _$getSyncPull200ResponseChangesInnerEntityTypeEnumSerializer;

  const GetSyncPull200ResponseChangesInnerEntityTypeEnum._(String name)
      : super(name);

  static BuiltSet<GetSyncPull200ResponseChangesInnerEntityTypeEnum>
      get values => _$getSyncPull200ResponseChangesInnerEntityTypeEnumValues;
  static GetSyncPull200ResponseChangesInnerEntityTypeEnum valueOf(
          String name) =>
      _$getSyncPull200ResponseChangesInnerEntityTypeEnumValueOf(name);
}

class GetSyncPull200ResponseChangesInnerActionEnum extends EnumClass {
  @BuiltValueEnumConst(wireName: r'upsert')
  static const GetSyncPull200ResponseChangesInnerActionEnum upsert =
      _$getSyncPull200ResponseChangesInnerActionEnum_upsert;
  @BuiltValueEnumConst(wireName: r'delete')
  static const GetSyncPull200ResponseChangesInnerActionEnum delete =
      _$getSyncPull200ResponseChangesInnerActionEnum_delete;

  static Serializer<GetSyncPull200ResponseChangesInnerActionEnum>
      get serializer =>
          _$getSyncPull200ResponseChangesInnerActionEnumSerializer;

  const GetSyncPull200ResponseChangesInnerActionEnum._(String name)
      : super(name);

  static BuiltSet<GetSyncPull200ResponseChangesInnerActionEnum> get values =>
      _$getSyncPull200ResponseChangesInnerActionEnumValues;
  static GetSyncPull200ResponseChangesInnerActionEnum valueOf(String name) =>
      _$getSyncPull200ResponseChangesInnerActionEnumValueOf(name);
}
