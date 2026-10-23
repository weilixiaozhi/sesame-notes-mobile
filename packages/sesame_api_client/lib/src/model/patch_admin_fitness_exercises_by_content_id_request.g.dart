// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patch_admin_fitness_exercises_by_content_id_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PatchAdminFitnessExercisesByContentIdRequest
    extends PatchAdminFitnessExercisesByContentIdRequest {
  @override
  final int version;
  @override
  final PostAdminFitnessExercisesRequestContent? content;
  @override
  final bool? isEnabled;

  factory _$PatchAdminFitnessExercisesByContentIdRequest(
          [void Function(PatchAdminFitnessExercisesByContentIdRequestBuilder)?
              updates]) =>
      (PatchAdminFitnessExercisesByContentIdRequestBuilder()..update(updates))
          ._build();

  _$PatchAdminFitnessExercisesByContentIdRequest._(
      {required this.version, this.content, this.isEnabled})
      : super._();
  @override
  PatchAdminFitnessExercisesByContentIdRequest rebuild(
          void Function(PatchAdminFitnessExercisesByContentIdRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PatchAdminFitnessExercisesByContentIdRequestBuilder toBuilder() =>
      PatchAdminFitnessExercisesByContentIdRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PatchAdminFitnessExercisesByContentIdRequest &&
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
            r'PatchAdminFitnessExercisesByContentIdRequest')
          ..add('version', version)
          ..add('content', content)
          ..add('isEnabled', isEnabled))
        .toString();
  }
}

class PatchAdminFitnessExercisesByContentIdRequestBuilder
    implements
        Builder<PatchAdminFitnessExercisesByContentIdRequest,
            PatchAdminFitnessExercisesByContentIdRequestBuilder> {
  _$PatchAdminFitnessExercisesByContentIdRequest? _$v;

  int? _version;
  int? get version => _$this._version;
  set version(int? version) => _$this._version = version;

  PostAdminFitnessExercisesRequestContentBuilder? _content;
  PostAdminFitnessExercisesRequestContentBuilder get content =>
      _$this._content ??= PostAdminFitnessExercisesRequestContentBuilder();
  set content(PostAdminFitnessExercisesRequestContentBuilder? content) =>
      _$this._content = content;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  PatchAdminFitnessExercisesByContentIdRequestBuilder() {
    PatchAdminFitnessExercisesByContentIdRequest._defaults(this);
  }

  PatchAdminFitnessExercisesByContentIdRequestBuilder get _$this {
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
  void replace(PatchAdminFitnessExercisesByContentIdRequest other) {
    _$v = other as _$PatchAdminFitnessExercisesByContentIdRequest;
  }

  @override
  void update(
      void Function(PatchAdminFitnessExercisesByContentIdRequestBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PatchAdminFitnessExercisesByContentIdRequest build() => _build();

  _$PatchAdminFitnessExercisesByContentIdRequest _build() {
    _$PatchAdminFitnessExercisesByContentIdRequest _$result;
    try {
      _$result = _$v ??
          _$PatchAdminFitnessExercisesByContentIdRequest._(
            version: BuiltValueNullFieldError.checkNotNull(version,
                r'PatchAdminFitnessExercisesByContentIdRequest', 'version'),
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
            r'PatchAdminFitnessExercisesByContentIdRequest',
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
