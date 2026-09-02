// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LedgerRoleEnum _$ledgerRoleEnum_owner = const LedgerRoleEnum._('owner');
const LedgerRoleEnum _$ledgerRoleEnum_editor = const LedgerRoleEnum._('editor');

LedgerRoleEnum _$ledgerRoleEnumValueOf(String name) {
  switch (name) {
    case 'owner':
      return _$ledgerRoleEnum_owner;
    case 'editor':
      return _$ledgerRoleEnum_editor;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LedgerRoleEnum> _$ledgerRoleEnumValues =
    BuiltSet<LedgerRoleEnum>(const <LedgerRoleEnum>[
  _$ledgerRoleEnum_owner,
  _$ledgerRoleEnum_editor,
]);

Serializer<LedgerRoleEnum> _$ledgerRoleEnumSerializer =
    _$LedgerRoleEnumSerializer();

class _$LedgerRoleEnumSerializer
    implements PrimitiveSerializer<LedgerRoleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'owner': 'owner',
    'editor': 'editor',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'owner': 'owner',
    'editor': 'editor',
  };

  @override
  final Iterable<Type> types = const <Type>[LedgerRoleEnum];
  @override
  final String wireName = 'LedgerRoleEnum';

  @override
  Object serialize(Serializers serializers, LedgerRoleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LedgerRoleEnum deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LedgerRoleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Ledger extends Ledger {
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
  final LedgerRoleEnum role;
  @override
  final int memberCount;
  @override
  final DateTime updatedAt;

  factory _$Ledger([void Function(LedgerBuilder)? updates]) =>
      (LedgerBuilder()..update(updates))._build();

  _$Ledger._(
      {required this.id,
      required this.syncId,
      required this.name,
      required this.currency,
      required this.monthStartDay,
      required this.aaEnabled,
      required this.role,
      required this.memberCount,
      required this.updatedAt})
      : super._();
  @override
  Ledger rebuild(void Function(LedgerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LedgerBuilder toBuilder() => LedgerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Ledger &&
        id == other.id &&
        syncId == other.syncId &&
        name == other.name &&
        currency == other.currency &&
        monthStartDay == other.monthStartDay &&
        aaEnabled == other.aaEnabled &&
        role == other.role &&
        memberCount == other.memberCount &&
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
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, memberCount.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Ledger')
          ..add('id', id)
          ..add('syncId', syncId)
          ..add('name', name)
          ..add('currency', currency)
          ..add('monthStartDay', monthStartDay)
          ..add('aaEnabled', aaEnabled)
          ..add('role', role)
          ..add('memberCount', memberCount)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class LedgerBuilder implements Builder<Ledger, LedgerBuilder> {
  _$Ledger? _$v;

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

  LedgerRoleEnum? _role;
  LedgerRoleEnum? get role => _$this._role;
  set role(LedgerRoleEnum? role) => _$this._role = role;

  int? _memberCount;
  int? get memberCount => _$this._memberCount;
  set memberCount(int? memberCount) => _$this._memberCount = memberCount;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  LedgerBuilder() {
    Ledger._defaults(this);
  }

  LedgerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _syncId = $v.syncId;
      _name = $v.name;
      _currency = $v.currency;
      _monthStartDay = $v.monthStartDay;
      _aaEnabled = $v.aaEnabled;
      _role = $v.role;
      _memberCount = $v.memberCount;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Ledger other) {
    _$v = other as _$Ledger;
  }

  @override
  void update(void Function(LedgerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Ledger build() => _build();

  _$Ledger _build() {
    final _$result = _$v ??
        _$Ledger._(
          id: BuiltValueNullFieldError.checkNotNull(id, r'Ledger', 'id'),
          syncId: BuiltValueNullFieldError.checkNotNull(
              syncId, r'Ledger', 'syncId'),
          name: BuiltValueNullFieldError.checkNotNull(name, r'Ledger', 'name'),
          currency: BuiltValueNullFieldError.checkNotNull(
              currency, r'Ledger', 'currency'),
          monthStartDay: BuiltValueNullFieldError.checkNotNull(
              monthStartDay, r'Ledger', 'monthStartDay'),
          aaEnabled: BuiltValueNullFieldError.checkNotNull(
              aaEnabled, r'Ledger', 'aaEnabled'),
          role: BuiltValueNullFieldError.checkNotNull(role, r'Ledger', 'role'),
          memberCount: BuiltValueNullFieldError.checkNotNull(
              memberCount, r'Ledger', 'memberCount'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'Ledger', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
