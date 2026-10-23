// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_day_books200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetSyncDayBooks200Response extends GetSyncDayBooks200Response {
  @override
  final BuiltList<DayBook> dayBooks;
  @override
  final String serverCursor;

  factory _$GetSyncDayBooks200Response(
          [void Function(GetSyncDayBooks200ResponseBuilder)? updates]) =>
      (GetSyncDayBooks200ResponseBuilder()..update(updates))._build();

  _$GetSyncDayBooks200Response._(
      {required this.dayBooks, required this.serverCursor})
      : super._();
  @override
  GetSyncDayBooks200Response rebuild(
          void Function(GetSyncDayBooks200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncDayBooks200ResponseBuilder toBuilder() =>
      GetSyncDayBooks200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncDayBooks200Response &&
        dayBooks == other.dayBooks &&
        serverCursor == other.serverCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dayBooks.hashCode);
    _$hash = $jc(_$hash, serverCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetSyncDayBooks200Response')
          ..add('dayBooks', dayBooks)
          ..add('serverCursor', serverCursor))
        .toString();
  }
}

class GetSyncDayBooks200ResponseBuilder
    implements
        Builder<GetSyncDayBooks200Response, GetSyncDayBooks200ResponseBuilder> {
  _$GetSyncDayBooks200Response? _$v;

  ListBuilder<DayBook>? _dayBooks;
  ListBuilder<DayBook> get dayBooks =>
      _$this._dayBooks ??= ListBuilder<DayBook>();
  set dayBooks(ListBuilder<DayBook>? dayBooks) => _$this._dayBooks = dayBooks;

  String? _serverCursor;
  String? get serverCursor => _$this._serverCursor;
  set serverCursor(String? serverCursor) => _$this._serverCursor = serverCursor;

  GetSyncDayBooks200ResponseBuilder() {
    GetSyncDayBooks200Response._defaults(this);
  }

  GetSyncDayBooks200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dayBooks = $v.dayBooks.toBuilder();
      _serverCursor = $v.serverCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncDayBooks200Response other) {
    _$v = other as _$GetSyncDayBooks200Response;
  }

  @override
  void update(void Function(GetSyncDayBooks200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncDayBooks200Response build() => _build();

  _$GetSyncDayBooks200Response _build() {
    _$GetSyncDayBooks200Response _$result;
    try {
      _$result = _$v ??
          _$GetSyncDayBooks200Response._(
            dayBooks: dayBooks.build(),
            serverCursor: BuiltValueNullFieldError.checkNotNull(
                serverCursor, r'GetSyncDayBooks200Response', 'serverCursor'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dayBooks';
        dayBooks.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetSyncDayBooks200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
