// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_memo_books_by_memo_book_id_calendar_counts200_response_days_inner.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner
    extends GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner {
  @override
  final String date;
  @override
  final int count;

  factory _$GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner(
          [void Function(
                  GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerBuilder)?
              updates]) =>
      (GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerBuilder()
            ..update(updates))
          ._build();

  _$GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner._(
      {required this.date, required this.count})
      : super._();
  @override
  GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner rebuild(
          void Function(
                  GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerBuilder
      toBuilder() =>
          GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerBuilder()
            ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other
            is GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner &&
        date == other.date &&
        count == other.count;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner')
          ..add('date', date)
          ..add('count', count))
        .toString();
  }
}

class GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerBuilder
    implements
        Builder<GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner,
            GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerBuilder> {
  _$GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner? _$v;

  String? _date;
  String? get date => _$this._date;
  set date(String? date) => _$this._date = date;

  int? _count;
  int? get count => _$this._count;
  set count(int? count) => _$this._count = count;

  GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerBuilder() {
    GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner._defaults(this);
  }

  GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _date = $v.date;
      _count = $v.count;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(
      GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner other) {
    _$v = other as _$GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner;
  }

  @override
  void update(
      void Function(
              GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInnerBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner build() =>
      _build();

  _$GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner _build() {
    final _$result = _$v ??
        _$GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner._(
          date: BuiltValueNullFieldError.checkNotNull(
              date,
              r'GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner',
              'date'),
          count: BuiltValueNullFieldError.checkNotNull(
              count,
              r'GetMemoBooksByMemoBookIdCalendarCounts200ResponseDaysInner',
              'count'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
