// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_full200_response_ledger.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetSyncFull200ResponseLedger extends GetSyncFull200ResponseLedger {
  @override
  final String id;
  @override
  final String? ownerId;
  @override
  final String syncId;
  @override
  final String name;
  @override
  final String currency;
  @override
  final int monthStartDay;
  @override
  final bool aaEnabled;
  @override
  final DateTime? archivedAt;
  @override
  final DateTime? archiveUpdatedAt;
  @override
  final String? archiveDeviceId;
  @override
  final DateTime updatedAt;

  factory _$GetSyncFull200ResponseLedger(
          [void Function(GetSyncFull200ResponseLedgerBuilder)? updates]) =>
      (GetSyncFull200ResponseLedgerBuilder()..update(updates))._build();

  _$GetSyncFull200ResponseLedger._(
      {required this.id,
      this.ownerId,
      required this.syncId,
      required this.name,
      required this.currency,
      required this.monthStartDay,
      required this.aaEnabled,
      this.archivedAt,
      this.archiveUpdatedAt,
      this.archiveDeviceId,
      required this.updatedAt})
      : super._();
  @override
  GetSyncFull200ResponseLedger rebuild(
          void Function(GetSyncFull200ResponseLedgerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncFull200ResponseLedgerBuilder toBuilder() =>
      GetSyncFull200ResponseLedgerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncFull200ResponseLedger &&
        id == other.id &&
        ownerId == other.ownerId &&
        syncId == other.syncId &&
        name == other.name &&
        currency == other.currency &&
        monthStartDay == other.monthStartDay &&
        aaEnabled == other.aaEnabled &&
        archivedAt == other.archivedAt &&
        archiveUpdatedAt == other.archiveUpdatedAt &&
        archiveDeviceId == other.archiveDeviceId &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, ownerId.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, monthStartDay.hashCode);
    _$hash = $jc(_$hash, aaEnabled.hashCode);
    _$hash = $jc(_$hash, archivedAt.hashCode);
    _$hash = $jc(_$hash, archiveUpdatedAt.hashCode);
    _$hash = $jc(_$hash, archiveDeviceId.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetSyncFull200ResponseLedger')
          ..add('id', id)
          ..add('ownerId', ownerId)
          ..add('syncId', syncId)
          ..add('name', name)
          ..add('currency', currency)
          ..add('monthStartDay', monthStartDay)
          ..add('aaEnabled', aaEnabled)
          ..add('archivedAt', archivedAt)
          ..add('archiveUpdatedAt', archiveUpdatedAt)
          ..add('archiveDeviceId', archiveDeviceId)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class GetSyncFull200ResponseLedgerBuilder
    implements
        Builder<GetSyncFull200ResponseLedger,
            GetSyncFull200ResponseLedgerBuilder> {
  _$GetSyncFull200ResponseLedger? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _ownerId;
  String? get ownerId => _$this._ownerId;
  set ownerId(String? ownerId) => _$this._ownerId = ownerId;

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  int? _monthStartDay;
  int? get monthStartDay => _$this._monthStartDay;
  set monthStartDay(int? monthStartDay) =>
      _$this._monthStartDay = monthStartDay;

  bool? _aaEnabled;
  bool? get aaEnabled => _$this._aaEnabled;
  set aaEnabled(bool? aaEnabled) => _$this._aaEnabled = aaEnabled;

  DateTime? _archivedAt;
  DateTime? get archivedAt => _$this._archivedAt;
  set archivedAt(DateTime? archivedAt) => _$this._archivedAt = archivedAt;

  DateTime? _archiveUpdatedAt;
  DateTime? get archiveUpdatedAt => _$this._archiveUpdatedAt;
  set archiveUpdatedAt(DateTime? archiveUpdatedAt) =>
      _$this._archiveUpdatedAt = archiveUpdatedAt;

  String? _archiveDeviceId;
  String? get archiveDeviceId => _$this._archiveDeviceId;
  set archiveDeviceId(String? archiveDeviceId) =>
      _$this._archiveDeviceId = archiveDeviceId;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  GetSyncFull200ResponseLedgerBuilder() {
    GetSyncFull200ResponseLedger._defaults(this);
  }

  GetSyncFull200ResponseLedgerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _ownerId = $v.ownerId;
      _syncId = $v.syncId;
      _name = $v.name;
      _currency = $v.currency;
      _monthStartDay = $v.monthStartDay;
      _aaEnabled = $v.aaEnabled;
      _archivedAt = $v.archivedAt;
      _archiveUpdatedAt = $v.archiveUpdatedAt;
      _archiveDeviceId = $v.archiveDeviceId;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncFull200ResponseLedger other) {
    _$v = other as _$GetSyncFull200ResponseLedger;
  }

  @override
  void update(void Function(GetSyncFull200ResponseLedgerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncFull200ResponseLedger build() => _build();

  _$GetSyncFull200ResponseLedger _build() {
    final _$result = _$v ??
        _$GetSyncFull200ResponseLedger._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GetSyncFull200ResponseLedger', 'id'),
          ownerId: ownerId,
          syncId: BuiltValueNullFieldError.checkNotNull(
              syncId, r'GetSyncFull200ResponseLedger', 'syncId'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'GetSyncFull200ResponseLedger', 'name'),
          currency: BuiltValueNullFieldError.checkNotNull(
              currency, r'GetSyncFull200ResponseLedger', 'currency'),
          monthStartDay: BuiltValueNullFieldError.checkNotNull(
              monthStartDay, r'GetSyncFull200ResponseLedger', 'monthStartDay'),
          aaEnabled: BuiltValueNullFieldError.checkNotNull(
              aaEnabled, r'GetSyncFull200ResponseLedger', 'aaEnabled'),
          archivedAt: archivedAt,
          archiveUpdatedAt: archiveUpdatedAt,
          archiveDeviceId: archiveDeviceId,
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'GetSyncFull200ResponseLedger', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
