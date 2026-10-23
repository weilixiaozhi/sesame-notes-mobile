// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_pull200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetSyncPull200Response extends GetSyncPull200Response {
  @override
  final BuiltList<GetSyncPull200ResponseChangesInner> changes;
  @override
  final String serverCursor;
  @override
  final bool hasMore;

  factory _$GetSyncPull200Response(
          [void Function(GetSyncPull200ResponseBuilder)? updates]) =>
      (GetSyncPull200ResponseBuilder()..update(updates))._build();

  _$GetSyncPull200Response._(
      {required this.changes,
      required this.serverCursor,
      required this.hasMore})
      : super._();
  @override
  GetSyncPull200Response rebuild(
          void Function(GetSyncPull200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncPull200ResponseBuilder toBuilder() =>
      GetSyncPull200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncPull200Response &&
        changes == other.changes &&
        serverCursor == other.serverCursor &&
        hasMore == other.hasMore;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, changes.hashCode);
    _$hash = $jc(_$hash, serverCursor.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetSyncPull200Response')
          ..add('changes', changes)
          ..add('serverCursor', serverCursor)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class GetSyncPull200ResponseBuilder
    implements Builder<GetSyncPull200Response, GetSyncPull200ResponseBuilder> {
  _$GetSyncPull200Response? _$v;

  ListBuilder<GetSyncPull200ResponseChangesInner>? _changes;
  ListBuilder<GetSyncPull200ResponseChangesInner> get changes =>
      _$this._changes ??= ListBuilder<GetSyncPull200ResponseChangesInner>();
  set changes(ListBuilder<GetSyncPull200ResponseChangesInner>? changes) =>
      _$this._changes = changes;

  String? _serverCursor;
  String? get serverCursor => _$this._serverCursor;
  set serverCursor(String? serverCursor) => _$this._serverCursor = serverCursor;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  GetSyncPull200ResponseBuilder() {
    GetSyncPull200Response._defaults(this);
  }

  GetSyncPull200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _changes = $v.changes.toBuilder();
      _serverCursor = $v.serverCursor;
      _hasMore = $v.hasMore;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncPull200Response other) {
    _$v = other as _$GetSyncPull200Response;
  }

  @override
  void update(void Function(GetSyncPull200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncPull200Response build() => _build();

  _$GetSyncPull200Response _build() {
    _$GetSyncPull200Response _$result;
    try {
      _$result = _$v ??
          _$GetSyncPull200Response._(
            changes: changes.build(),
            serverCursor: BuiltValueNullFieldError.checkNotNull(
                serverCursor, r'GetSyncPull200Response', 'serverCursor'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'GetSyncPull200Response', 'hasMore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'changes';
        changes.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetSyncPull200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
