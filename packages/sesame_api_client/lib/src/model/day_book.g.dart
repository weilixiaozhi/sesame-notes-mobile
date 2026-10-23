// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_book.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DayBook extends DayBook {
  @override
  final String name;
  @override
  final DateTime createdAt;
  @override
  final String id;
  @override
  final String syncId;
  @override
  final int revision;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  factory _$DayBook([void Function(DayBookBuilder)? updates]) =>
      (DayBookBuilder()..update(updates))._build();

  _$DayBook._(
      {required this.name,
      required this.createdAt,
      required this.id,
      required this.syncId,
      required this.revision,
      required this.updatedAt,
      this.deletedAt})
      : super._();
  @override
  DayBook rebuild(void Function(DayBookBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DayBookBuilder toBuilder() => DayBookBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DayBook &&
        name == other.name &&
        createdAt == other.createdAt &&
        id == other.id &&
        syncId == other.syncId &&
        revision == other.revision &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, syncId.hashCode);
    _$hash = $jc(_$hash, revision.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DayBook')
          ..add('name', name)
          ..add('createdAt', createdAt)
          ..add('id', id)
          ..add('syncId', syncId)
          ..add('revision', revision)
          ..add('updatedAt', updatedAt)
          ..add('deletedAt', deletedAt))
        .toString();
  }
}

class DayBookBuilder implements Builder<DayBook, DayBookBuilder> {
  _$DayBook? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _syncId;
  String? get syncId => _$this._syncId;
  set syncId(String? syncId) => _$this._syncId = syncId;

  int? _revision;
  int? get revision => _$this._revision;
  set revision(int? revision) => _$this._revision = revision;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  DayBookBuilder() {
    DayBook._defaults(this);
  }

  DayBookBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _createdAt = $v.createdAt;
      _id = $v.id;
      _syncId = $v.syncId;
      _revision = $v.revision;
      _updatedAt = $v.updatedAt;
      _deletedAt = $v.deletedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DayBook other) {
    _$v = other as _$DayBook;
  }

  @override
  void update(void Function(DayBookBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DayBook build() => _build();

  _$DayBook _build() {
    final _$result = _$v ??
        _$DayBook._(
          name: BuiltValueNullFieldError.checkNotNull(name, r'DayBook', 'name'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'DayBook', 'createdAt'),
          id: BuiltValueNullFieldError.checkNotNull(id, r'DayBook', 'id'),
          syncId: BuiltValueNullFieldError.checkNotNull(
              syncId, r'DayBook', 'syncId'),
          revision: BuiltValueNullFieldError.checkNotNull(
              revision, r'DayBook', 'revision'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'DayBook', 'updatedAt'),
          deletedAt: deletedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
