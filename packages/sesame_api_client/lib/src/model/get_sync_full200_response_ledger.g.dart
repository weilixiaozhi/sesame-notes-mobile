// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_full200_response_ledger.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetSyncFull200ResponseLedger extends GetSyncFull200ResponseLedger {
  @override
  final String id;
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
  final DateTime updatedAt;

  factory _$GetSyncFull200ResponseLedger(
          [void Function(GetSyncFull200ResponseLedgerBuilder)? updates]) =>
      (GetSyncFull200ResponseLedgerBuilder()..update(updates))._build();

  _$GetSyncFull200ResponseLedger._(
      {required this.id,
      required this.syncId,
      required this.name,
      required this.currency,
      required this.monthStartDay,
      required this.aaEnabled,
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
        syncId == other.syncId &&
        name == other.name &&
        currency == other.currency &&
        monthStartDay == other.monthStartDay &&
        aaEnabled == other.aaEnabled &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, monthStartDay.hashCode);
    _$hash = $jc(_$hash, aaEnabled.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetSyncFull200ResponseLedger')
          ..add('id', id)
          ..add('syncId', syncId)
          ..add('name', name)
          ..add('currency', currency)
          ..add('monthStartDay', monthStartDay)
          ..add('aaEnabled', aaEnabled)
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
      _syncId = $v.syncId;
      _name = $v.name;
      _currency = $v.currency;
      _monthStartDay = $v.monthStartDay;
      _aaEnabled = $v.aaEnabled;
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
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'GetSyncFull200ResponseLedger', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
