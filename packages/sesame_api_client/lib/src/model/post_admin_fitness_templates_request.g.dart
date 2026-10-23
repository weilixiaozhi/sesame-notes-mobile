// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_fitness_templates_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminFitnessTemplatesRequest
    extends PostAdminFitnessTemplatesRequest {
  @override
  final PostAdminFitnessTemplatesRequestContent content;
  @override
  final bool? isEnabled;

  factory _$PostAdminFitnessTemplatesRequest(
          [void Function(PostAdminFitnessTemplatesRequestBuilder)? updates]) =>
      (PostAdminFitnessTemplatesRequestBuilder()..update(updates))._build();

  _$PostAdminFitnessTemplatesRequest._({required this.content, this.isEnabled})
      : super._();
  @override
  PostAdminFitnessTemplatesRequest rebuild(
          void Function(PostAdminFitnessTemplatesRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminFitnessTemplatesRequestBuilder toBuilder() =>
      PostAdminFitnessTemplatesRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminFitnessTemplatesRequest &&
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
    return (newBuiltValueToStringHelper(r'PostAdminFitnessTemplatesRequest')
          ..add('content', content)
          ..add('isEnabled', isEnabled))
        .toString();
  }
}

class PostAdminFitnessTemplatesRequestBuilder
    implements
        Builder<PostAdminFitnessTemplatesRequest,
            PostAdminFitnessTemplatesRequestBuilder> {
  _$PostAdminFitnessTemplatesRequest? _$v;

  PostAdminFitnessTemplatesRequestContentBuilder? _content;
  PostAdminFitnessTemplatesRequestContentBuilder get content =>
      _$this._content ??= PostAdminFitnessTemplatesRequestContentBuilder();
  set content(PostAdminFitnessTemplatesRequestContentBuilder? content) =>
      _$this._content = content;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  PostAdminFitnessTemplatesRequestBuilder() {
    PostAdminFitnessTemplatesRequest._defaults(this);
  }

  PostAdminFitnessTemplatesRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content.toBuilder();
      _isEnabled = $v.isEnabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminFitnessTemplatesRequest other) {
    _$v = other as _$PostAdminFitnessTemplatesRequest;
  }

  @override
  void update(void Function(PostAdminFitnessTemplatesRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminFitnessTemplatesRequest build() => _build();

  _$PostAdminFitnessTemplatesRequest _build() {
    _$PostAdminFitnessTemplatesRequest _$result;
    try {
      _$result = _$v ??
          _$PostAdminFitnessTemplatesRequest._(
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
            r'PostAdminFitnessTemplatesRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
