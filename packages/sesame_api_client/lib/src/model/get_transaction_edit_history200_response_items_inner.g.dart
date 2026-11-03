// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_transaction_edit_history200_response_items_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetTransactionEditHistory200ResponseItemsInner
    extends GetTransactionEditHistory200ResponseItemsInner {
  @override
  final String id;
  @override
  final String transactionId;
  @override
  final String ledgerId;
  @override
  final int version;
  @override
  final String? operatorMemberId;
  @override
  final String? operatorDisplayName;
  @override
  final DateTime createdAt;
  @override
  final JsonObject? changes;

  factory _$GetTransactionEditHistory200ResponseItemsInner(
          [void Function(GetTransactionEditHistory200ResponseItemsInnerBuilder)?
              updates]) =>
      (GetTransactionEditHistory200ResponseItemsInnerBuilder()..update(updates))
          ._build();

  _$GetTransactionEditHistory200ResponseItemsInner._(
      {required this.id,
      required this.transactionId,
      required this.ledgerId,
      required this.version,
      this.operatorMemberId,
      this.operatorDisplayName,
      required this.createdAt,
      this.changes})
      : super._();
  @override
  GetTransactionEditHistory200ResponseItemsInner rebuild(
          void Function(GetTransactionEditHistory200ResponseItemsInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetTransactionEditHistory200ResponseItemsInnerBuilder toBuilder() =>
      GetTransactionEditHistory200ResponseItemsInnerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetTransactionEditHistory200ResponseItemsInner &&
        id == other.id &&
        transactionId == other.transactionId &&
        ledgerId == other.ledgerId &&
        version == other.version &&
        operatorMemberId == other.operatorMemberId &&
        operatorDisplayName == other.operatorDisplayName &&
        createdAt == other.createdAt &&
        changes == other.changes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, transactionId.hashCode);
    _$hash = $jc(_$hash, ledgerId.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, operatorMemberId.hashCode);
    _$hash = $jc(_$hash, operatorDisplayName.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, changes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetTransactionEditHistory200ResponseItemsInner')
          ..add('id', id)
          ..add('transactionId', transactionId)
          ..add('ledgerId', ledgerId)
          ..add('version', version)
          ..add('operatorMemberId', operatorMemberId)
          ..add('operatorDisplayName', operatorDisplayName)
          ..add('createdAt', createdAt)
          ..add('changes', changes))
        .toString();
  }
}

class GetTransactionEditHistory200ResponseItemsInnerBuilder
    implements
        Builder<GetTransactionEditHistory200ResponseItemsInner,
            GetTransactionEditHistory200ResponseItemsInnerBuilder> {
  _$GetTransactionEditHistory200ResponseItemsInner? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _transactionId;
  String? get transactionId => _$this._transactionId;
  set transactionId(String? transactionId) =>
      _$this._transactionId = transactionId;

  String? _ledgerId;
  String? get ledgerId => _$this._ledgerId;
  set ledgerId(String? ledgerId) => _$this._ledgerId = ledgerId;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  String? _operatorMemberId;
  String? get operatorMemberId => _$this._operatorMemberId;
  set operatorMemberId(String? operatorMemberId) =>
      _$this._operatorMemberId = operatorMemberId;

  String? _operatorDisplayName;
  String? get operatorDisplayName => _$this._operatorDisplayName;
  set operatorDisplayName(String? operatorDisplayName) =>
      _$this._operatorDisplayName = operatorDisplayName;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  JsonObject? _changes;
  JsonObject? get changes => _$this._changes;
  set changes(JsonObject? changes) => _$this._changes = changes;

  GetTransactionEditHistory200ResponseItemsInnerBuilder() {
    GetTransactionEditHistory200ResponseItemsInner._defaults(this);
  }

  GetTransactionEditHistory200ResponseItemsInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _transactionId = $v.transactionId;
      _ledgerId = $v.ledgerId;
      _version = $v.version;
      _operatorMemberId = $v.operatorMemberId;
      _operatorDisplayName = $v.operatorDisplayName;
      _createdAt = $v.createdAt;
      _changes = $v.changes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetTransactionEditHistory200ResponseItemsInner other) {
    _$v = other as _$GetTransactionEditHistory200ResponseItemsInner;
  }

  @override
  void update(
      void Function(GetTransactionEditHistory200ResponseItemsInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetTransactionEditHistory200ResponseItemsInner build() => _build();

  _$GetTransactionEditHistory200ResponseItemsInner _build() {
    final _$result = _$v ??
        _$GetTransactionEditHistory200ResponseItemsInner._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GetTransactionEditHistory200ResponseItemsInner', 'id'),
          transactionId: BuiltValueNullFieldError.checkNotNull(
              transactionId,
              r'GetTransactionEditHistory200ResponseItemsInner',
              'transactionId'),
          ledgerId: BuiltValueNullFieldError.checkNotNull(ledgerId,
              r'GetTransactionEditHistory200ResponseItemsInner', 'ledgerId'),
          version: BuiltValueNullFieldError.checkNotNull(version,
              r'GetTransactionEditHistory200ResponseItemsInner', 'version'),
          operatorMemberId: operatorMemberId,
          operatorDisplayName: operatorDisplayName,
          createdAt: BuiltValueNullFieldError.checkNotNull(createdAt,
              r'GetTransactionEditHistory200ResponseItemsInner', 'createdAt'),
          changes: changes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
