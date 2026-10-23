// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of3_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSyncPushRequestChangesInnerAnyOf3Payload
    extends PostSyncPushRequestChangesInnerAnyOf3Payload {
  @override
  final bool archived;

  factory _$PostSyncPushRequestChangesInnerAnyOf3Payload(
          [void Function(PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder()..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf3Payload._({required this.archived})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf3Payload rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf3Payload &&
        archived == other.archived;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, archived.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf3Payload')
          ..add('archived', archived))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf3Payload,
            PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf3Payload? _$v;

  bool? _archived;
  bool? get archived => _$this._archived;
  set archived(bool? archived) => _$this._archived = archived;

  PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf3Payload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _archived = $v.archived;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf3Payload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf3Payload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf3PayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf3Payload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf3Payload _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf3Payload._(
          archived: BuiltValueNullFieldError.checkNotNull(archived,
              r'PostSyncPushRequestChangesInnerAnyOf3Payload', 'archived'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
