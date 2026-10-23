// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_sync_push_request_changes_inner_any_of_any_of_payload.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayload
    extends PostSyncPushRequestChangesInnerAnyOfAnyOfPayload {
  @override
  final String name;
  @override
  final DateTime createdAt;

  factory _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayload(
          [void Function(
                  PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder)?
              updates]) =>
      (PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder()
            ..update(updates))
          ._build();

  _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayload._(
      {required this.name, required this.createdAt})
      : super._();
  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOfPayload rebuild(
          void Function(PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder toBuilder() =>
      PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PostSyncPushRequestChangesInnerAnyOfAnyOfPayload &&
        name == other.name &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'PostSyncPushRequestChangesInnerAnyOfAnyOfPayload')
          ..add('name', name)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder
    implements
        Builder<PostSyncPushRequestChangesInnerAnyOfAnyOfPayload,
            PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder> {
  _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayload? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder() {
    PostSyncPushRequestChangesInnerAnyOfAnyOfPayload._defaults(this);
  }

  PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PostSyncPushRequestChangesInnerAnyOfAnyOfPayload other) {
    _$v = other as _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayload;
  }

  @override
  void update(
      void Function(PostSyncPushRequestChangesInnerAnyOfAnyOfPayloadBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  PostSyncPushRequestChangesInnerAnyOfAnyOfPayload build() => _build();

  _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayload _build() {
    final _$result = _$v ??
        _$PostSyncPushRequestChangesInnerAnyOfAnyOfPayload._(
          name: BuiltValueNullFieldError.checkNotNull(name,
              r'PostSyncPushRequestChangesInnerAnyOfAnyOfPayload', 'name'),
          createdAt: BuiltValueNullFieldError.checkNotNull(createdAt,
              r'PostSyncPushRequestChangesInnerAnyOfAnyOfPayload', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
