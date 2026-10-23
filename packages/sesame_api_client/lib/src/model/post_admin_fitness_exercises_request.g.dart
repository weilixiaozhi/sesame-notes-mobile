// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_fitness_exercises_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminFitnessExercisesRequest
    extends PostAdminFitnessExercisesRequest {
  @override
  final PostAdminFitnessExercisesRequestContent content;
  @override
  final bool? isEnabled;

  factory _$PostAdminFitnessExercisesRequest(
          [void Function(PostAdminFitnessExercisesRequestBuilder)? updates]) =>
      (PostAdminFitnessExercisesRequestBuilder()..update(updates))._build();

  _$PostAdminFitnessExercisesRequest._({required this.content, this.isEnabled})
      : super._();
  @override
  PostAdminFitnessExercisesRequest rebuild(
          void Function(PostAdminFitnessExercisesRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminFitnessExercisesRequestBuilder toBuilder() =>
      PostAdminFitnessExercisesRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminFitnessExercisesRequest &&
        content == other.content &&
        isEnabled == other.isEnabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, isEnabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostAdminFitnessExercisesRequest')
          ..add('content', content)
          ..add('isEnabled', isEnabled))
        .toString();
  }
}

class PostAdminFitnessExercisesRequestBuilder
    implements
        Builder<PostAdminFitnessExercisesRequest,
            PostAdminFitnessExercisesRequestBuilder> {
  _$PostAdminFitnessExercisesRequest? _$v;

  PostAdminFitnessExercisesRequestContentBuilder? _content;
  PostAdminFitnessExercisesRequestContentBuilder get content =>
      _$this._content ??= PostAdminFitnessExercisesRequestContentBuilder();
  set content(PostAdminFitnessExercisesRequestContentBuilder? content) =>
      _$this._content = content;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  PostAdminFitnessExercisesRequestBuilder() {
    PostAdminFitnessExercisesRequest._defaults(this);
  }

  PostAdminFitnessExercisesRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content.toBuilder();
      _isEnabled = $v.isEnabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminFitnessExercisesRequest other) {
    _$v = other as _$PostAdminFitnessExercisesRequest;
  }

  @override
  void update(void Function(PostAdminFitnessExercisesRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminFitnessExercisesRequest build() => _build();

  _$PostAdminFitnessExercisesRequest _build() {
    _$PostAdminFitnessExercisesRequest _$result;
    try {
      _$result = _$v ??
          _$PostAdminFitnessExercisesRequest._(
            content: content.build(),
            isEnabled: isEnabled,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        content.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostAdminFitnessExercisesRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
