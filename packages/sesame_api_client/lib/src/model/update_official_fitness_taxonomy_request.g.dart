// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_official_fitness_taxonomy_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateOfficialFitnessTaxonomyRequest
    extends UpdateOfficialFitnessTaxonomyRequest {
  @override
  final int version;
  @override
  final ListOfficialFitnessTaxonomies200ResponseItemsInnerName? name;
  @override
  final int? sortOrder;
  @override
  final String reason;

  factory _$UpdateOfficialFitnessTaxonomyRequest(
          [void Function(UpdateOfficialFitnessTaxonomyRequestBuilder)?
              updates]) =>
      (UpdateOfficialFitnessTaxonomyRequestBuilder()..update(updates))._build();

  _$UpdateOfficialFitnessTaxonomyRequest._(
      {required this.version, this.name, this.sortOrder, required this.reason})
      : super._();
  @override
  UpdateOfficialFitnessTaxonomyRequest rebuild(
          void Function(UpdateOfficialFitnessTaxonomyRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateOfficialFitnessTaxonomyRequestBuilder toBuilder() =>
      UpdateOfficialFitnessTaxonomyRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateOfficialFitnessTaxonomyRequest &&
        version == other.version &&
        name == other.name &&
        sortOrder == other.sortOrder &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateOfficialFitnessTaxonomyRequest')
          ..add('version', version)
          ..add('name', name)
          ..add('sortOrder', sortOrder)
          ..add('reason', reason))
        .toString();
  }
}

class UpdateOfficialFitnessTaxonomyRequestBuilder
    implements
        Builder<UpdateOfficialFitnessTaxonomyRequest,
            UpdateOfficialFitnessTaxonomyRequestBuilder> {
  _$UpdateOfficialFitnessTaxonomyRequest? _$v;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder? _name;
  ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder get name =>
      _$this._name ??=
          ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder();
  set name(
          ListOfficialFitnessTaxonomies200ResponseItemsInnerNameBuilder?
              name) =>
      _$this._name = name;

  int? _sortOrder;
  int? get sortOrder => _$this._sortOrder;
  set sortOrder(int? sortOrder) => _$this._sortOrder = sortOrder;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  UpdateOfficialFitnessTaxonomyRequestBuilder() {
    UpdateOfficialFitnessTaxonomyRequest._defaults(this);
  }

  UpdateOfficialFitnessTaxonomyRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _name = $v.name?.toBuilder();
      _sortOrder = $v.sortOrder;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateOfficialFitnessTaxonomyRequest other) {
    _$v = other as _$UpdateOfficialFitnessTaxonomyRequest;
  }

  @override
  void update(
      void Function(UpdateOfficialFitnessTaxonomyRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateOfficialFitnessTaxonomyRequest build() => _build();

  _$UpdateOfficialFitnessTaxonomyRequest _build() {
    _$UpdateOfficialFitnessTaxonomyRequest _$result;
    try {
      _$result = _$v ??
          _$UpdateOfficialFitnessTaxonomyRequest._(
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'UpdateOfficialFitnessTaxonomyRequest', 'version'),
            name: _name?.build(),
            sortOrder: sortOrder,
            reason: BuiltValueNullFieldError.checkNotNull(
                reason, r'UpdateOfficialFitnessTaxonomyRequest', 'reason'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'name';
        _name?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UpdateOfficialFitnessTaxonomyRequest',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
