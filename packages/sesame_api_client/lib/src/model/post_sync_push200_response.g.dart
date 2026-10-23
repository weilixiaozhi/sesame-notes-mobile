// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSyncPush200Response extends PostSyncPush200Response {
  @override
  final BuiltList<PostSyncPush200ResponseOutcomesInner> outcomes;
  @override
  final String serverCursor;

  factory _$PostSyncPush200Response(
          [void Function(PostSyncPush200ResponseBuilder)? updates]) =>
      (PostSyncPush200ResponseBuilder()..update(updates))._build();

  _$PostSyncPush200Response._(
      {required this.outcomes, required this.serverCursor})
      : super._();
  @override
  PostSyncPush200Response rebuild(
          void Function(PostSyncPush200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPush200ResponseBuilder toBuilder() =>
      PostSyncPush200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPush200Response &&
        outcomes == other.outcomes &&
        serverCursor == other.serverCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, outcomes.hashCode);
    _$hash = $jc(_$hash, serverCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostSyncPush200Response')
          ..add('outcomes', outcomes)
          ..add('serverCursor', serverCursor))
        .toString();
  }
}

class PostSyncPush200ResponseBuilder
    implements
        Builder<PostSyncPush200Response, PostSyncPush200ResponseBuilder> {
  _$PostSyncPush200Response? _$v;

  ListBuilder<PostSyncPush200ResponseOutcomesInner>? _outcomes;
  ListBuilder<PostSyncPush200ResponseOutcomesInner> get outcomes =>
      _$this._outcomes ??= ListBuilder<PostSyncPush200ResponseOutcomesInner>();
  set outcomes(ListBuilder<PostSyncPush200ResponseOutcomesInner>? outcomes) =>
      _$this._outcomes = outcomes;

  String? _serverCursor;
  String? get serverCursor => _$this._serverCursor;
  set serverCursor(String? serverCursor) => _$this._serverCursor = serverCursor;

  PostSyncPush200ResponseBuilder() {
    PostSyncPush200Response._defaults(this);
  }

  PostSyncPush200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _outcomes = $v.outcomes.toBuilder();
      _serverCursor = $v.serverCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPush200Response other) {
    _$v = other as _$PostSyncPush200Response;
  }

  @override
  void update(void Function(PostSyncPush200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPush200Response build() => _build();

  _$PostSyncPush200Response _build() {
    _$PostSyncPush200Response _$result;
    try {
      _$result = _$v ??
          _$PostSyncPush200Response._(
            outcomes: outcomes.build(),
            serverCursor: BuiltValueNullFieldError.checkNotNull(
                serverCursor, r'PostSyncPush200Response', 'serverCursor'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'outcomes';
        outcomes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPush200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
