// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_admin_fitness_templates_by_content_id_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatchAdminFitnessTemplatesByContentIdRequest
    extends PatchAdminFitnessTemplatesByContentIdRequest {
  @override
  final int version;
  @override
  final PostAdminFitnessTemplatesRequestContent? content;
  @override
  final bool? isEnabled;

  factory _$PatchAdminFitnessTemplatesByContentIdRequest(
          [void Function(PatchAdminFitnessTemplatesByContentIdRequestBuilder)?
              updates]) =>
      (PatchAdminFitnessTemplatesByContentIdRequestBuilder()..update(updates))
          ._build();

  _$PatchAdminFitnessTemplatesByContentIdRequest._(
      {required this.version, this.content, this.isEnabled})
      : super._();
  @override
  PatchAdminFitnessTemplatesByContentIdRequest rebuild(
          void Function(PatchAdminFitnessTemplatesByContentIdRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatchAdminFitnessTemplatesByContentIdRequestBuilder toBuilder() =>
      PatchAdminFitnessTemplatesByContentIdRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatchAdminFitnessTemplatesByContentIdRequest &&
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
            r'PatchAdminFitnessTemplatesByContentIdRequest')
          ..add('version', version)
          ..add('content', content)
          ..add('isEnabled', isEnabled))
        .toString();
  }
}

class PatchAdminFitnessTemplatesByContentIdRequestBuilder
    implements
        Builder<PatchAdminFitnessTemplatesByContentIdRequest,
            PatchAdminFitnessTemplatesByContentIdRequestBuilder> {
  _$PatchAdminFitnessTemplatesByContentIdRequest? _$v;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  PostAdminFitnessTemplatesRequestContentBuilder? _content;
  PostAdminFitnessTemplatesRequestContentBuilder get content =>
      _$this._content ??= PostAdminFitnessTemplatesRequestContentBuilder();
  set content(PostAdminFitnessTemplatesRequestContentBuilder? content) =>
      _$this._content = content;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  PatchAdminFitnessTemplatesByContentIdRequestBuilder() {
    PatchAdminFitnessTemplatesByContentIdRequest._defaults(this);
  }

  PatchAdminFitnessTemplatesByContentIdRequestBuilder get _$this {
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
  void replace(PatchAdminFitnessTemplatesByContentIdRequest other) {
    _$v = other as _$PatchAdminFitnessTemplatesByContentIdRequest;
  }

  @override
  void update(
      void Function(PatchAdminFitnessTemplatesByContentIdRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PatchAdminFitnessTemplatesByContentIdRequest build() => _build();

  _$PatchAdminFitnessTemplatesByContentIdRequest _build() {
    _$PatchAdminFitnessTemplatesByContentIdRequest _$result;
    try {
      _$result = _$v ??
          _$PatchAdminFitnessTemplatesByContentIdRequest._(
            version: BuiltValueNullFieldError.checkNotNull(version,
                r'PatchAdminFitnessTemplatesByContentIdRequest', 'version'),
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
            r'PatchAdminFitnessTemplatesByContentIdRequest',
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
