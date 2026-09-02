// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_pull200_response_changes_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GetSyncPull200ResponseChangesInnerEntityTypeEnum
    _$getSyncPull200ResponseChangesInnerEntityTypeEnum_ledger =
    const GetSyncPull200ResponseChangesInnerEntityTypeEnum._('ledger');
const GetSyncPull200ResponseChangesInnerEntityTypeEnum
    _$getSyncPull200ResponseChangesInnerEntityTypeEnum_transaction =
    const GetSyncPull200ResponseChangesInnerEntityTypeEnum._('transaction');
const GetSyncPull200ResponseChangesInnerEntityTypeEnum
    _$getSyncPull200ResponseChangesInnerEntityTypeEnum_category =
    const GetSyncPull200ResponseChangesInnerEntityTypeEnum._('category');
const GetSyncPull200ResponseChangesInnerEntityTypeEnum
    _$getSyncPull200ResponseChangesInnerEntityTypeEnum_recurringTransaction =
    const GetSyncPull200ResponseChangesInnerEntityTypeEnum._(
        'recurringTransaction');
const GetSyncPull200ResponseChangesInnerEntityTypeEnum
    _$getSyncPull200ResponseChangesInnerEntityTypeEnum_exchangeRateOverride =
    const GetSyncPull200ResponseChangesInnerEntityTypeEnum._(
        'exchangeRateOverride');
const GetSyncPull200ResponseChangesInnerEntityTypeEnum
    _$getSyncPull200ResponseChangesInnerEntityTypeEnum_member =
    const GetSyncPull200ResponseChangesInnerEntityTypeEnum._('member');

GetSyncPull200ResponseChangesInnerEntityTypeEnum
    _$getSyncPull200ResponseChangesInnerEntityTypeEnumValueOf(String name) {
  switch (name) {
    case 'ledger':
      return _$getSyncPull200ResponseChangesInnerEntityTypeEnum_ledger;
    case 'transaction':
      return _$getSyncPull200ResponseChangesInnerEntityTypeEnum_transaction;
    case 'category':
      return _$getSyncPull200ResponseChangesInnerEntityTypeEnum_category;
    case 'recurringTransaction':
      return _$getSyncPull200ResponseChangesInnerEntityTypeEnum_recurringTransaction;
    case 'exchangeRateOverride':
      return _$getSyncPull200ResponseChangesInnerEntityTypeEnum_exchangeRateOverride;
    case 'member':
      return _$getSyncPull200ResponseChangesInnerEntityTypeEnum_member;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetSyncPull200ResponseChangesInnerEntityTypeEnum>
    _$getSyncPull200ResponseChangesInnerEntityTypeEnumValues = BuiltSet<
        GetSyncPull200ResponseChangesInnerEntityTypeEnum>(const <GetSyncPull200ResponseChangesInnerEntityTypeEnum>[
  _$getSyncPull200ResponseChangesInnerEntityTypeEnum_ledger,
  _$getSyncPull200ResponseChangesInnerEntityTypeEnum_transaction,
  _$getSyncPull200ResponseChangesInnerEntityTypeEnum_category,
  _$getSyncPull200ResponseChangesInnerEntityTypeEnum_recurringTransaction,
  _$getSyncPull200ResponseChangesInnerEntityTypeEnum_exchangeRateOverride,
  _$getSyncPull200ResponseChangesInnerEntityTypeEnum_member,
]);

const GetSyncPull200ResponseChangesInnerActionEnum
    _$getSyncPull200ResponseChangesInnerActionEnum_upsert =
    const GetSyncPull200ResponseChangesInnerActionEnum._('upsert');
const GetSyncPull200ResponseChangesInnerActionEnum
    _$getSyncPull200ResponseChangesInnerActionEnum_delete =
    const GetSyncPull200ResponseChangesInnerActionEnum._('delete');

GetSyncPull200ResponseChangesInnerActionEnum
    _$getSyncPull200ResponseChangesInnerActionEnumValueOf(String name) {
  switch (name) {
    case 'upsert':
      return _$getSyncPull200ResponseChangesInnerActionEnum_upsert;
    case 'delete':
      return _$getSyncPull200ResponseChangesInnerActionEnum_delete;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<GetSyncPull200ResponseChangesInnerActionEnum>
    _$getSyncPull200ResponseChangesInnerActionEnumValues = BuiltSet<
        GetSyncPull200ResponseChangesInnerActionEnum>(const <GetSyncPull200ResponseChangesInnerActionEnum>[
  _$getSyncPull200ResponseChangesInnerActionEnum_upsert,
  _$getSyncPull200ResponseChangesInnerActionEnum_delete,
]);

Serializer<GetSyncPull200ResponseChangesInnerEntityTypeEnum>
    _$getSyncPull200ResponseChangesInnerEntityTypeEnumSerializer =
    _$GetSyncPull200ResponseChangesInnerEntityTypeEnumSerializer();
Serializer<GetSyncPull200ResponseChangesInnerActionEnum>
    _$getSyncPull200ResponseChangesInnerActionEnumSerializer =
    _$GetSyncPull200ResponseChangesInnerActionEnumSerializer();

class _$GetSyncPull200ResponseChangesInnerEntityTypeEnumSerializer
    implements
        PrimitiveSerializer<GetSyncPull200ResponseChangesInnerEntityTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'ledger': 'ledger',
    'transaction': 'transaction',
    'category': 'category',
    'recurringTransaction': 'recurring_transaction',
    'exchangeRateOverride': 'exchange_rate_override',
    'member': 'member',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'ledger': 'ledger',
    'transaction': 'transaction',
    'category': 'category',
    'recurring_transaction': 'recurringTransaction',
    'exchange_rate_override': 'exchangeRateOverride',
    'member': 'member',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetSyncPull200ResponseChangesInnerEntityTypeEnum
  ];
  @override
  final String wireName = 'GetSyncPull200ResponseChangesInnerEntityTypeEnum';

  @override
  Object serialize(Serializers serializers,
          GetSyncPull200ResponseChangesInnerEntityTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetSyncPull200ResponseChangesInnerEntityTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetSyncPull200ResponseChangesInnerEntityTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetSyncPull200ResponseChangesInnerActionEnumSerializer
    implements
        PrimitiveSerializer<GetSyncPull200ResponseChangesInnerActionEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'upsert': 'upsert',
    'delete': 'delete',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'upsert': 'upsert',
    'delete': 'delete',
  };

  @override
  final Iterable<Type> types = const <Type>[
    GetSyncPull200ResponseChangesInnerActionEnum
  ];
  @override
  final String wireName = 'GetSyncPull200ResponseChangesInnerActionEnum';

  @override
  Object serialize(Serializers serializers,
          GetSyncPull200ResponseChangesInnerActionEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  GetSyncPull200ResponseChangesInnerActionEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GetSyncPull200ResponseChangesInnerActionEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$GetSyncPull200ResponseChangesInner
    extends GetSyncPull200ResponseChangesInner {
  @override
  final String changeId;
  @override
  final String? ledgerId;
  @override
  final GetSyncPull200ResponseChangesInnerEntityTypeEnum entityType;
  @override
  final String entityId;
  @override
  final GetSyncPull200ResponseChangesInnerActionEnum action;
  @override
  final String mutationId;
  @override
  final BuiltMap<String, JsonObject?> payload;
  @override
  final DateTime updatedAt;
  @override
  final String deviceId;

  factory _$GetSyncPull200ResponseChangesInner(
          [void Function(GetSyncPull200ResponseChangesInnerBuilder)?
              updates]) =>
      (GetSyncPull200ResponseChangesInnerBuilder()..update(updates))._build();

  _$GetSyncPull200ResponseChangesInner._(
      {required this.changeId,
      this.ledgerId,
      required this.entityType,
      required this.entityId,
      required this.action,
      required this.mutationId,
      required this.payload,
      required this.updatedAt,
      required this.deviceId})
      : super._();
  @override
  GetSyncPull200ResponseChangesInner rebuild(
          void Function(GetSyncPull200ResponseChangesInnerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncPull200ResponseChangesInnerBuilder toBuilder() =>
      GetSyncPull200ResponseChangesInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncPull200ResponseChangesInner &&
        changeId == other.changeId &&
        ledgerId == other.ledgerId &&
        entityType == other.entityType &&
        entityId == other.entityId &&
        action == other.action &&
        mutationId == other.mutationId &&
        payload == other.payload &&
        updatedAt == other.updatedAt &&
        deviceId == other.deviceId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, changeId.hashCode);
    _$hash = $jc(_$hash, ledgerId.hashCode);
    _$hash = $jc(_$hash, entityType.hashCode);
    _$hash = $jc(_$hash, entityId.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, mutationId.hashCode);
    _$hash = $jc(_$hash, payload.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetSyncPull200ResponseChangesInner')
          ..add('changeId', changeId)
          ..add('ledgerId', ledgerId)
          ..add('entityType', entityType)
          ..add('entityId', entityId)
          ..add('action', action)
          ..add('mutationId', mutationId)
          ..add('payload', payload)
          ..add('updatedAt', updatedAt)
          ..add('deviceId', deviceId))
        .toString();
  }
}

class GetSyncPull200ResponseChangesInnerBuilder
    implements
        Builder<GetSyncPull200ResponseChangesInner,
            GetSyncPull200ResponseChangesInnerBuilder> {
  _$GetSyncPull200ResponseChangesInner? _$v;

  String? _changeId;
  String? get changeId => _$this._changeId;
  set changeId(String? changeId) => _$this._changeId = changeId;

  String? _ledgerId;
  String? get ledgerId => _$this._ledgerId;
  set ledgerId(String? ledgerId) => _$this._ledgerId = ledgerId;

  GetSyncPull200ResponseChangesInnerEntityTypeEnum? _entityType;
  GetSyncPull200ResponseChangesInnerEntityTypeEnum? get entityType =>
      _$this._entityType;
  set entityType(
          GetSyncPull200ResponseChangesInnerEntityTypeEnum? entityType) =>
      _$this._entityType = entityType;

  String? _entityId;
  String? get entityId => _$this._entityId;
  set entityId(String? entityId) => _$this._entityId = entityId;

  GetSyncPull200ResponseChangesInnerActionEnum? _action;
  GetSyncPull200ResponseChangesInnerActionEnum? get action => _$this._action;
  set action(GetSyncPull200ResponseChangesInnerActionEnum? action) =>
      _$this._action = action;

  String? _mutationId;
  String? get mutationId => _$this._mutationId;
  set mutationId(String? mutationId) => _$this._mutationId = mutationId;

  MapBuilder<String, JsonObject?>? _payload;
  MapBuilder<String, JsonObject?> get payload =>
      _$this._payload ??= MapBuilder<String, JsonObject?>();
  set payload(MapBuilder<String, JsonObject?>? payload) =>
      _$this._payload = payload;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  GetSyncPull200ResponseChangesInnerBuilder() {
    GetSyncPull200ResponseChangesInner._defaults(this);
  }

  GetSyncPull200ResponseChangesInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _changeId = $v.changeId;
      _ledgerId = $v.ledgerId;
      _entityType = $v.entityType;
      _entityId = $v.entityId;
      _action = $v.action;
      _mutationId = $v.mutationId;
      _payload = $v.payload.toBuilder();
      _updatedAt = $v.updatedAt;
      _deviceId = $v.deviceId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncPull200ResponseChangesInner other) {
    _$v = other as _$GetSyncPull200ResponseChangesInner;
  }

  @override
  void update(
      void Function(GetSyncPull200ResponseChangesInnerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncPull200ResponseChangesInner build() => _build();

  _$GetSyncPull200ResponseChangesInner _build() {
    _$GetSyncPull200ResponseChangesInner _$result;
    try {
      _$result = _$v ??
          _$GetSyncPull200ResponseChangesInner._(
            changeId: BuiltValueNullFieldError.checkNotNull(
                changeId, r'GetSyncPull200ResponseChangesInner', 'changeId'),
            ledgerId: ledgerId,
            entityType: BuiltValueNullFieldError.checkNotNull(entityType,
                r'GetSyncPull200ResponseChangesInner', 'entityType'),
            entityId: BuiltValueNullFieldError.checkNotNull(
                entityId, r'GetSyncPull200ResponseChangesInner', 'entityId'),
            action: BuiltValueNullFieldError.checkNotNull(
                action, r'GetSyncPull200ResponseChangesInner', 'action'),
            mutationId: BuiltValueNullFieldError.checkNotNull(mutationId,
                r'GetSyncPull200ResponseChangesInner', 'mutationId'),
            payload: payload.build(),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'GetSyncPull200ResponseChangesInner', 'updatedAt'),
            deviceId: BuiltValueNullFieldError.checkNotNull(
                deviceId, r'GetSyncPull200ResponseChangesInner', 'deviceId'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payload';
        payload.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetSyncPull200ResponseChangesInner', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
