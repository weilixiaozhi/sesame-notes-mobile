// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSyncPushRequest extends PostSyncPushRequest {
  @override
  final String deviceId;
  @override
  final BuiltList<PostSyncPushRequestChangesInner> changes;

  factory _$PostSyncPushRequest(
          [void Function(PostSyncPushRequestBuilder)? updates]) =>
      (PostSyncPushRequestBuilder()..update(updates))._build();

  _$PostSyncPushRequest._({required this.deviceId, required this.changes})
      : super._();
  @override
  PostSyncPushRequest rebuild(
          void Function(PostSyncPushRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestBuilder toBuilder() =>
      PostSyncPushRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequest &&
        deviceId == other.deviceId &&
        changes == other.changes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, changes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PostSyncPushRequest')
          ..add('deviceId', deviceId)
          ..add('changes', changes))
        .toString();
  }
}

class PostSyncPushRequestBuilder
    implements Builder<PostSyncPushRequest, PostSyncPushRequestBuilder> {
  _$PostSyncPushRequest? _$v;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  ListBuilder<PostSyncPushRequestChangesInner>? _changes;
  ListBuilder<PostSyncPushRequestChangesInner> get changes =>
      _$this._changes ??= ListBuilder<PostSyncPushRequestChangesInner>();
  set changes(ListBuilder<PostSyncPushRequestChangesInner>? changes) =>
      _$this._changes = changes;

  PostSyncPushRequestBuilder() {
    PostSyncPushRequest._defaults(this);
  }

  PostSyncPushRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _deviceId = $v.deviceId;
      _changes = $v.changes.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequest other) {
    _$v = other as _$PostSyncPushRequest;
  }

  @override
  void update(void Function(PostSyncPushRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequest build() => _build();

  _$PostSyncPushRequest _build() {
    _$PostSyncPushRequest _$result;
    try {
      _$result = _$v ??
          _$PostSyncPushRequest._(
            deviceId: BuiltValueNullFieldError.checkNotNull(
                deviceId, r'PostSyncPushRequest', 'deviceId'),
            changes: changes.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'changes';
        changes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PostSyncPushRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
