// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_official_fitness_taxonomy_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateOfficialFitnessTaxonomyRequest
    extends CreateOfficialFitnessTaxonomyRequest {
  @override
  final ListOfficialFitnessTaxonomies200ResponseItemsInnerName name;
  @override
  final int? sortOrder;
  @override
  final String reason;

  factory _$CreateOfficialFitnessTaxonomyRequest(
          [void Function(CreateOfficialFitnessTaxonomyRequestBuilder)?
              updates]) =>
      (CreateOfficialFitnessTaxonomyRequestBuilder()..update(updates))._build();

  _$CreateOfficialFitnessTaxonomyRequest._(
      {required this.name, this.sortOrder, required this.reason})
      : super._();
  @override
  CreateOfficialFitnessTaxonomyRequest rebuild(
          void Function(CreateOfficialFitnessTaxonomyRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateOfficialFitnessTaxonomyRequestBuilder toBuilder() =>
      CreateOfficialFitnessTaxonomyRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateOfficialFitnessTaxonomyRequest &&
        name == other.name &&
        sortOrder == other.sortOrder &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, sortOrder.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateOfficialFitnessTaxonomyRequest')
          ..add('name', name)
          ..add('sortOrder', sortOrder)
          ..add('reason', reason))
        .toString();
  }
}

class CreateOfficialFitnessTaxonomyRequestBuilder
    implements
        Builder<CreateOfficialFitnessTaxonomyRequest,
            CreateOfficialFitnessTaxonomyRequestBuilder> {
  _$CreateOfficialFitnessTaxonomyRequest? _$v;

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

  CreateOfficialFitnessTaxonomyRequestBuilder() {
    CreateOfficialFitnessTaxonomyRequest._defaults(this);
  }

  CreateOfficialFitnessTaxonomyRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name.toBuilder();
      _sortOrder = $v.sortOrder;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateOfficialFitnessTaxonomyRequest other) {
    _$v = other as _$CreateOfficialFitnessTaxonomyRequest;
  }

  @override
  void update(
      void Function(CreateOfficialFitnessTaxonomyRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateOfficialFitnessTaxonomyRequest build() => _build();

  _$CreateOfficialFitnessTaxonomyRequest _build() {
    _$CreateOfficialFitnessTaxonomyRequest _$result;
    try {
      _$result = _$v ??
          _$CreateOfficialFitnessTaxonomyRequest._(
            name: name.build(),
            sortOrder: sortOrder,
            reason: BuiltValueNullFieldError.checkNotNull(
                reason, r'CreateOfficialFitnessTaxonomyRequest', 'reason'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'name';
        name.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CreateOfficialFitnessTaxonomyRequest',
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
