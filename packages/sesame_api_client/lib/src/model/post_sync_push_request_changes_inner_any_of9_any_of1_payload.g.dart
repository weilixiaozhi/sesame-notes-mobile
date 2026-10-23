// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of9_any_of1_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload
    extends PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload {
  @override
  final String expectedFullCursor;

  factory _$PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload._(
      {required this.expectedFullCursor})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload rebuild(
          void Function(
                  PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload &&
        expectedFullCursor == other.expectedFullCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, expectedFullCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload')
          ..add('expectedFullCursor', expectedFullCursor))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload,
            PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload? _$v;

  String? _expectedFullCursor;
  String? get expectedFullCursor => _$this._expectedFullCursor;
  set expectedFullCursor(String? expectedFullCursor) =>
      _$this._expectedFullCursor = expectedFullCursor;

  PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _expectedFullCursor = $v.expectedFullCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOf9AnyOf1PayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload._(
          expectedFullCursor: BuiltValueNullFieldError.checkNotNull(
              expectedFullCursor,
              r'PostSyncPushRequestChangesInnerAnyOf9AnyOf1Payload',
              'expectedFullCursor'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
