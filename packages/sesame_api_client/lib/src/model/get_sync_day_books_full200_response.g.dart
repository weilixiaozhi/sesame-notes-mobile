// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_sync_day_books_full200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetSyncDayBooksFull200Response extends GetSyncDayBooksFull200Response {
  @override
  final DayBook dayBook;
  @override
  final BuiltList<DayEvent> dayEvents;
  @override
  final String serverCursor;

  factory _$GetSyncDayBooksFull200Response(
          [void Function(GetSyncDayBooksFull200ResponseBuilder)? updates]) =>
      (GetSyncDayBooksFull200ResponseBuilder()..update(updates))._build();

  _$GetSyncDayBooksFull200Response._(
      {required this.dayBook,
      required this.dayEvents,
      required this.serverCursor})
      : super._();
  @override
  GetSyncDayBooksFull200Response rebuild(
          void Function(GetSyncDayBooksFull200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetSyncDayBooksFull200ResponseBuilder toBuilder() =>
      GetSyncDayBooksFull200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetSyncDayBooksFull200Response &&
        dayBook == other.dayBook &&
        dayEvents == other.dayEvents &&
        serverCursor == other.serverCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, dayBook.hashCode);
    _$hash = $jc(_$hash, dayEvents.hashCode);
    _$hash = $jc(_$hash, serverCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GetSyncDayBooksFull200Response')
          ..add('dayBook', dayBook)
          ..add('dayEvents', dayEvents)
          ..add('serverCursor', serverCursor))
        .toString();
  }
}

class GetSyncDayBooksFull200ResponseBuilder
    implements
        Builder<GetSyncDayBooksFull200Response,
            GetSyncDayBooksFull200ResponseBuilder> {
  _$GetSyncDayBooksFull200Response? _$v;

  DayBookBuilder? _dayBook;
  DayBookBuilder get dayBook => _$this._dayBook ??= DayBookBuilder();
  set dayBook(DayBookBuilder? dayBook) => _$this._dayBook = dayBook;

  ListBuilder<DayEvent>? _dayEvents;
  ListBuilder<DayEvent> get dayEvents =>
      _$this._dayEvents ??= ListBuilder<DayEvent>();
  set dayEvents(ListBuilder<DayEvent>? dayEvents) =>
      _$this._dayEvents = dayEvents;

  String? _serverCursor;
  String? get serverCursor => _$this._serverCursor;
  set serverCursor(String? serverCursor) => _$this._serverCursor = serverCursor;

  GetSyncDayBooksFull200ResponseBuilder() {
    GetSyncDayBooksFull200Response._defaults(this);
  }

  GetSyncDayBooksFull200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _dayBook = $v.dayBook.toBuilder();
      _dayEvents = $v.dayEvents.toBuilder();
      _serverCursor = $v.serverCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetSyncDayBooksFull200Response other) {
    _$v = other as _$GetSyncDayBooksFull200Response;
  }

  @override
  void update(void Function(GetSyncDayBooksFull200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetSyncDayBooksFull200Response build() => _build();

  _$GetSyncDayBooksFull200Response _build() {
    _$GetSyncDayBooksFull200Response _$result;
    try {
      _$result = _$v ??
          _$GetSyncDayBooksFull200Response._(
            dayBook: dayBook.build(),
            dayEvents: dayEvents.build(),
            serverCursor: BuiltValueNullFieldError.checkNotNull(serverCursor,
                r'GetSyncDayBooksFull200Response', 'serverCursor'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'dayBook';
        dayBook.build();
        _$failedField = 'dayEvents';
        dayEvents.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetSyncDayBooksFull200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
