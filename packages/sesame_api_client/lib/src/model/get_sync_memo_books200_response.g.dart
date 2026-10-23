// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_memo_books200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetSyncMemoBooks200Response extends GetSyncMemoBooks200Response {
  @override
  final BuiltList<GetSyncMemoBooks200ResponseMemoBooksInner> memoBooks;
  @override
  final String serverCursor;

  factory _$GetSyncMemoBooks200Response(
          [void Function(GetSyncMemoBooks200ResponseBuilder)? updates]) =>
      (GetSyncMemoBooks200ResponseBuilder()..update(updates))._build();

  _$GetSyncMemoBooks200Response._(
      {required this.memoBooks, required this.serverCursor})
      : super._();
  @override
  GetSyncMemoBooks200Response rebuild(
          void Function(GetSyncMemoBooks200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncMemoBooks200ResponseBuilder toBuilder() =>
      GetSyncMemoBooks200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncMemoBooks200Response &&
        memoBooks == other.memoBooks &&
        serverCursor == other.serverCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, memoBooks.hashCode);
    _$hash = $jc(_$hash, serverCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetSyncMemoBooks200Response')
          ..add('memoBooks', memoBooks)
          ..add('serverCursor', serverCursor))
        .toString();
  }
}

class GetSyncMemoBooks200ResponseBuilder
    implements
        Builder<GetSyncMemoBooks200Response,
            GetSyncMemoBooks200ResponseBuilder> {
  _$GetSyncMemoBooks200Response? _$v;

  ListBuilder<GetSyncMemoBooks200ResponseMemoBooksInner>? _memoBooks;
  ListBuilder<GetSyncMemoBooks200ResponseMemoBooksInner> get memoBooks =>
      _$this._memoBooks ??=
          ListBuilder<GetSyncMemoBooks200ResponseMemoBooksInner>();
  set memoBooks(
          ListBuilder<GetSyncMemoBooks200ResponseMemoBooksInner>? memoBooks) =>
      _$this._memoBooks = memoBooks;

  String? _serverCursor;
  String? get serverCursor => _$this._serverCursor;
  set serverCursor(String? serverCursor) => _$this._serverCursor = serverCursor;

  GetSyncMemoBooks200ResponseBuilder() {
    GetSyncMemoBooks200Response._defaults(this);
  }

  GetSyncMemoBooks200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _memoBooks = $v.memoBooks.toBuilder();
      _serverCursor = $v.serverCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncMemoBooks200Response other) {
    _$v = other as _$GetSyncMemoBooks200Response;
  }

  @override
  void update(void Function(GetSyncMemoBooks200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncMemoBooks200Response build() => _build();

  _$GetSyncMemoBooks200Response _build() {
    _$GetSyncMemoBooks200Response _$result;
    try {
      _$result = _$v ??
          _$GetSyncMemoBooks200Response._(
            memoBooks: memoBooks.build(),
            serverCursor: BuiltValueNullFieldError.checkNotNull(
                serverCursor, r'GetSyncMemoBooks200Response', 'serverCursor'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'memoBooks';
        memoBooks.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetSyncMemoBooks200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
