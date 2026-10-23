// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_admin_fitness_plans_by_content_id_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatchAdminFitnessPlansByContentIdRequest
    extends PatchAdminFitnessPlansByContentIdRequest {
  @override
  final int version;
  @override
  final PostAdminFitnessPlansRequestContent? content;
  @override
  final bool? isEnabled;

  factory _$PatchAdminFitnessPlansByContentIdRequest(
          [void Function(PatchAdminFitnessPlansByContentIdRequestBuilder)?
              updates]) =>
      (PatchAdminFitnessPlansByContentIdRequestBuilder()..update(updates))
          ._build();

  _$PatchAdminFitnessPlansByContentIdRequest._(
      {required this.version, this.content, this.isEnabled})
      : super._();
  @override
  PatchAdminFitnessPlansByContentIdRequest rebuild(
          void Function(PatchAdminFitnessPlansByContentIdRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatchAdminFitnessPlansByContentIdRequestBuilder toBuilder() =>
      PatchAdminFitnessPlansByContentIdRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatchAdminFitnessPlansByContentIdRequest &&
        version == other.version &&
        content == other.content &&
        isEnabled == other.isEnabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, isEnabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PatchAdminFitnessPlansByContentIdRequest')
          ..add('version', version)
          ..add('content', content)
          ..add('isEnabled', isEnabled))
        .toString();
  }
}

class PatchAdminFitnessPlansByContentIdRequestBuilder
    implements
        Builder<PatchAdminFitnessPlansByContentIdRequest,
            PatchAdminFitnessPlansByContentIdRequestBuilder> {
  _$PatchAdminFitnessPlansByContentIdRequest? _$v;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  PostAdminFitnessPlansRequestContentBuilder? _content;
  PostAdminFitnessPlansRequestContentBuilder get content =>
      _$this._content ??= PostAdminFitnessPlansRequestContentBuilder();
  set content(PostAdminFitnessPlansRequestContentBuilder? content) =>
      _$this._content = content;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  PatchAdminFitnessPlansByContentIdRequestBuilder() {
    PatchAdminFitnessPlansByContentIdRequest._defaults(this);
  }

  PatchAdminFitnessPlansByContentIdRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _version = $v.version;
      _content = $v.content?.toBuilder();
      _isEnabled = $v.isEnabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PatchAdminFitnessPlansByContentIdRequest other) {
    _$v = other as _$PatchAdminFitnessPlansByContentIdRequest;
  }

  @override
  void update(
      void Function(PatchAdminFitnessPlansByContentIdRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PatchAdminFitnessPlansByContentIdRequest build() => _build();

  _$PatchAdminFitnessPlansByContentIdRequest _build() {
    _$PatchAdminFitnessPlansByContentIdRequest _$result;
    try {
      _$result = _$v ??
          _$PatchAdminFitnessPlansByContentIdRequest._(
            version: BuiltValueNullFieldError.checkNotNull(version,
                r'PatchAdminFitnessPlansByContentIdRequest', 'version'),
            content: _content?.build(),
            isEnabled: isEnabled,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        _content?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PatchAdminFitnessPlansByContentIdRequest',
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
