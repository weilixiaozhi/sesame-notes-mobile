// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_admin_fitness_plans_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostAdminFitnessPlansRequest extends PostAdminFitnessPlansRequest {
  @override
  final PostAdminFitnessPlansRequestContent content;
  @override
  final bool? isEnabled;

  factory _$PostAdminFitnessPlansRequest(
          [void Function(PostAdminFitnessPlansRequestBuilder)? updates]) =>
      (PostAdminFitnessPlansRequestBuilder()..update(updates))._build();

  _$PostAdminFitnessPlansRequest._({required this.content, this.isEnabled})
      : super._();
  @override
  PostAdminFitnessPlansRequest rebuild(
          void Function(PostAdminFitnessPlansRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostAdminFitnessPlansRequestBuilder toBuilder() =>
      PostAdminFitnessPlansRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostAdminFitnessPlansRequest &&
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
    return (newBuiltValueToStringHelper(r'PostAdminFitnessPlansRequest')
          ..add('content', content)
          ..add('isEnabled', isEnabled))
        .toString();
  }
}

class PostAdminFitnessPlansRequestBuilder
    implements
        Builder<PostAdminFitnessPlansRequest,
            PostAdminFitnessPlansRequestBuilder> {
  _$PostAdminFitnessPlansRequest? _$v;

  PostAdminFitnessPlansRequestContentBuilder? _content;
  PostAdminFitnessPlansRequestContentBuilder get content =>
      _$this._content ??= PostAdminFitnessPlansRequestContentBuilder();
  set content(PostAdminFitnessPlansRequestContentBuilder? content) =>
      _$this._content = content;

  bool? _isEnabled;
  bool? get isEnabled => _$this._isEnabled;
  set isEnabled(bool? isEnabled) => _$this._isEnabled = isEnabled;

  PostAdminFitnessPlansRequestBuilder() {
    PostAdminFitnessPlansRequest._defaults(this);
  }

  PostAdminFitnessPlansRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content.toBuilder();
      _isEnabled = $v.isEnabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostAdminFitnessPlansRequest other) {
    _$v = other as _$PostAdminFitnessPlansRequest;
  }

  @override
  void update(void Function(PostAdminFitnessPlansRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostAdminFitnessPlansRequest build() => _build();

  _$PostAdminFitnessPlansRequest _build() {
    _$PostAdminFitnessPlansRequest _$result;
    try {
      _$result = _$v ??
          _$PostAdminFitnessPlansRequest._(
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
            r'PostAdminFitnessPlansRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
