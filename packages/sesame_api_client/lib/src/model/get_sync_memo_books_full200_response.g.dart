// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_memo_books_full200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetSyncMemoBooksFull200Response
    extends GetSyncMemoBooksFull200Response {
  @override
  final MemoBook memoBook;
  @override
  final BuiltList<MemoEntry> memoEntries;
  @override
  final String serverCursor;

  factory _$GetSyncMemoBooksFull200Response(
          [void Function(GetSyncMemoBooksFull200ResponseBuilder)? updates]) =>
      (GetSyncMemoBooksFull200ResponseBuilder()..update(updates))._build();

  _$GetSyncMemoBooksFull200Response._(
      {required this.memoBook,
      required this.memoEntries,
      required this.serverCursor})
      : super._();
  @override
  GetSyncMemoBooksFull200Response rebuild(
          void Function(GetSyncMemoBooksFull200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncMemoBooksFull200ResponseBuilder toBuilder() =>
      GetSyncMemoBooksFull200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncMemoBooksFull200Response &&
        memoBook == other.memoBook &&
        memoEntries == other.memoEntries &&
        serverCursor == other.serverCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, memoBook.hashCode);
    _$hash = $jc(_$hash, memoEntries.hashCode);
    _$hash = $jc(_$hash, serverCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetSyncMemoBooksFull200Response')
          ..add('memoBook', memoBook)
          ..add('memoEntries', memoEntries)
          ..add('serverCursor', serverCursor))
        .toString();
  }
}

class GetSyncMemoBooksFull200ResponseBuilder
    implements
        Builder<GetSyncMemoBooksFull200Response,
            GetSyncMemoBooksFull200ResponseBuilder> {
  _$GetSyncMemoBooksFull200Response? _$v;

  MemoBookBuilder? _memoBook;
  MemoBookBuilder get memoBook => _$this._memoBook ??= MemoBookBuilder();
  set memoBook(MemoBookBuilder? memoBook) => _$this._memoBook = memoBook;

  ListBuilder<MemoEntry>? _memoEntries;
  ListBuilder<MemoEntry> get memoEntries =>
      _$this._memoEntries ??= ListBuilder<MemoEntry>();
  set memoEntries(ListBuilder<MemoEntry>? memoEntries) =>
      _$this._memoEntries = memoEntries;

  String? _serverCursor;
  String? get serverCursor => _$this._serverCursor;
  set serverCursor(String? serverCursor) => _$this._serverCursor = serverCursor;

  GetSyncMemoBooksFull200ResponseBuilder() {
    GetSyncMemoBooksFull200Response._defaults(this);
  }

  GetSyncMemoBooksFull200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _memoBook = $v.memoBook.toBuilder();
      _memoEntries = $v.memoEntries.toBuilder();
      _serverCursor = $v.serverCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncMemoBooksFull200Response other) {
    _$v = other as _$GetSyncMemoBooksFull200Response;
  }

  @override
  void update(void Function(GetSyncMemoBooksFull200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncMemoBooksFull200Response build() => _build();

  _$GetSyncMemoBooksFull200Response _build() {
    _$GetSyncMemoBooksFull200Response _$result;
    try {
      _$result = _$v ??
          _$GetSyncMemoBooksFull200Response._(
            memoBook: memoBook.build(),
            memoEntries: memoEntries.build(),
            serverCursor: BuiltValueNullFieldError.checkNotNull(serverCursor,
                r'GetSyncMemoBooksFull200Response', 'serverCursor'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'memoBook';
        memoBook.build();
        _$failedField = 'memoEntries';
        memoEntries.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetSyncMemoBooksFull200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
