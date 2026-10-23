// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_official_fitness_taxonomy_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeleteOfficialFitnessTaxonomyRequest
    extends DeleteOfficialFitnessTaxonomyRequest {
  @override
  final int version;
  @override
  final String? replacementId;
  @override
  final String reason;

  factory _$DeleteOfficialFitnessTaxonomyRequest(
          [void Function(DeleteOfficialFitnessTaxonomyRequestBuilder)?
              updates]) =>
      (DeleteOfficialFitnessTaxonomyRequestBuilder()..update(updates))._build();

  _$DeleteOfficialFitnessTaxonomyRequest._(
      {required this.version, this.replacementId, required this.reason})
      : super._();
  @override
  DeleteOfficialFitnessTaxonomyRequest rebuild(
          void Function(DeleteOfficialFitnessTaxonomyRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeleteOfficialFitnessTaxonomyRequestBuilder toBuilder() =>
      DeleteOfficialFitnessTaxonomyRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeleteOfficialFitnessTaxonomyRequest &&
        version == other.version &&
        replacementId == other.replacementId &&
        reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, replacementId.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeleteOfficialFitnessTaxonomyRequest')
          ..add('version', version)
          ..add('replacementId', replacementId)
          ..add('reason', reason))
        .toString();
  }
}

class DeleteOfficialFitnessTaxonomyRequestBuilder
    implements
        Builder<DeleteOfficialFitnessTaxonomyRequest,
            DeleteOfficialFitnessTaxonomyRequestBuilder> {
  _$DeleteOfficialFitnessTaxonomyRequest? _$v;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  String? _replacementId;
  String? get replacementId => _$this._replacementId;
  set replacementId(String? replacementId) =>
      _$this._replacementId = replacementId;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  DeleteOfficialFitnessTaxonomyRequestBuilder() {
    DeleteOfficialFitnessTaxonomyRequest._defaults(this);
  }

  DeleteOfficialFitnessTaxonomyRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _replacementId = $v.replacementId;
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeleteOfficialFitnessTaxonomyRequest other) {
    _$v = other as _$DeleteOfficialFitnessTaxonomyRequest;
  }

  @override
  void update(
      void Function(DeleteOfficialFitnessTaxonomyRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeleteOfficialFitnessTaxonomyRequest build() => _build();

  _$DeleteOfficialFitnessTaxonomyRequest _build() {
    final _$result = _$v ??
        _$DeleteOfficialFitnessTaxonomyRequest._(
          version: BuiltValueNullFieldError.checkNotNull(
              version, r'DeleteOfficialFitnessTaxonomyRequest', 'version'),
          replacementId: replacementId,
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'DeleteOfficialFitnessTaxonomyRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
