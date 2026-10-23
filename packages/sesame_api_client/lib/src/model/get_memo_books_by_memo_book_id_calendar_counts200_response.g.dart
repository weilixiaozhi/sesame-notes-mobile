// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_memo_books_by_memo_book_id_calendar_counts200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetMemoBooksByMemoBookIdCalendarCounts200Response
    extends GetMemoBooksByMemoBookIdCalendarCounts200Response {
  @override
  final BuiltList<GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner>
      days;

  factory _$GetMemoBooksByMemoBookIdCalendarCounts200Response(
          [void Function(
                  GetMemoBooksByMemoBookIdCalendarCounts200ResponseBuilder)?
              updates]) =>
      (GetMemoBooksByMemoBookIdCalendarCounts200ResponseBuilder()
            ..update(updates))
          ._build();

  _$GetMemoBooksByMemoBookIdCalendarCounts200Response._({required this.days})
      : super._();
  @override
  GetMemoBooksByMemoBookIdCalendarCounts200Response rebuild(
          void Function(
                  GetMemoBooksByMemoBookIdCalendarCounts200ResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetMemoBooksByMemoBookIdCalendarCounts200ResponseBuilder toBuilder() =>
      GetMemoBooksByMemoBookIdCalendarCounts200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetMemoBooksByMemoBookIdCalendarCounts200Response &&
        days == other.days;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, days.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetMemoBooksByMemoBookIdCalendarCounts200Response')
          ..add('days', days))
        .toString();
  }
}

class GetMemoBooksByMemoBookIdCalendarCounts200ResponseBuilder
    implements
        Builder<GetMemoBooksByMemoBookIdCalendarCounts200Response,
            GetMemoBooksByMemoBookIdCalendarCounts200ResponseBuilder> {
  _$GetMemoBooksByMemoBookIdCalendarCounts200Response? _$v;

  ListBuilder<GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner>?
      _days;
  ListBuilder<GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner>
      get days => _$this._days ??= ListBuilder<
          GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner>();
  set days(
          ListBuilder<
                  GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner>?
              days) =>
      _$this._days = days;

  GetMemoBooksByMemoBookIdCalendarCounts200ResponseBuilder() {
    GetMemoBooksByMemoBookIdCalendarCounts200Response._defaults(this);
  }

  GetMemoBooksByMemoBookIdCalendarCounts200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _days = $v.days.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetMemoBooksByMemoBookIdCalendarCounts200Response other) {
    _$v = other as _$GetMemoBooksByMemoBookIdCalendarCounts200Response;
  }

  @override
  void update(
      void Function(GetMemoBooksByMemoBookIdCalendarCounts200ResponseBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetMemoBooksByMemoBookIdCalendarCounts200Response build() => _build();

  _$GetMemoBooksByMemoBookIdCalendarCounts200Response _build() {
    _$GetMemoBooksByMemoBookIdCalendarCounts200Response _$result;
    try {
      _$result = _$v ??
          _$GetMemoBooksByMemoBookIdCalendarCounts200Response._(
            days: days.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'days';
        days.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GetMemoBooksByMemoBookIdCalendarCounts200Response',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
